from decimal import Decimal
from sqlalchemy import text
from .. import db

def _to_f(x):
    return float(x) if isinstance(x, Decimal) else float(x or 0)

def place_order(payload: dict) -> dict:
    customer_id = int(payload["customer_id"])
    pizzas = payload.get("pizzas", [])
    products  = payload.get("products", [])
    dis_code   = payload.get("discount_code")

    if not pizzas:
        return {"ok": False, "msg": "Order must contain at least one pizza."}

    with db.SessionLocal() as s, s.begin():
        # prices for pizzas
        pizza_ids = tuple({p["id"] for p in pizzas})
        price_rows = s.execute(
            text("SELECT idPizza, price FROM v_pizza_price WHERE idPizza IN :ids"),
            {"ids": pizza_ids},
        ).all()
        price_map = {int(r[0]): _to_f(r[1]) for r in price_rows}

        subtotal = 0.0
        for p in pizzas:
            pizza_id, quantity = int(p["id"]), int(p["qty"])
            if pizza_id not in price_map:
                raise RuntimeError(f"Unknown pizza id {pizza_id} for pricing.")
            subtotal += price_map[pizza_id] * quantity

        # product prices
        prod_sub = 0.0
        prod_map = {}
        if products:
            prod_ids = tuple({pr["id"] for pr in products})
            rows = s.execute(
                text("SELECT idproduct, price FROM product WHERE idproduct IN :ids"),
                {"ids": prod_ids},
            ).all()
            prod_map = {int(r[0]): _to_f(r[1]) for r in rows}
            for pr in products:
                prid, quantity = int(pr["id"]), int(pr["qty"])
                if prid not in prod_map:
                    raise RuntimeError(f"Unknown product id {prid} for pricing.")
                prod_sub += prod_map[prid] * quantity

        subtotal += prod_sub
        discounts = []
        total = subtotal

        # PRE-CHECK discount but do not mark redeemed yet
        discount_row = None
        if dis_code is not None:
            discount_row = s.execute(
                text("""
                    SELECT discount_code, percent, free_product, free_pizza, is_redeemed, reedemedby
                    FROM discount
                    WHERE discount_code = :c
                    FOR UPDATE
                """),
                {"c": int(dis_code)}
            ).mappings().first()

            if not discount_row:
                discounts.append({"type": "invalid_or_used_code", "amount": 0.0, "reason": "code not found"})
            elif int(discount_row["is_redeemed"]) == 1:
                discounts.append({"type": "invalid_or_used_code", "amount": 0.0, "reason": "already redeemed"})
            else:
                prct = int(discount_row["percent"] or 0)
                if prct > 0:
                    amount = round(total * (prct / 100.0), 2)
                    total -= amount
                    discounts.append({"type": f"{prct}% off", "amount": amount})

                free_pizza = discount_row["free_pizza"]
                if free_pizza:
                    free_pizza = int(free_pizza)
                    in_cart = next((p for p in pizzas if int(p["id"]) == free_pizza and int(p["qty"]) > 0), None)
                    if in_cart and free_pizza in price_map:
                        amount = price_map[free_pizza]
                        total -= amount
                        discounts.append({"type": "free_pizza", "amount": amount, "reason": f"idPizza={free_pizza}"})

                free_product = discount_row["free_product"]
                if free_product:
                    free_product = int(free_product)
                    in_cart = next((p for p in products if int(p["id"]) == free_product and int(p["qty"]) > 0), None)
                    if in_cart:
                        pr_price = prod_map.get(free_product)
                        if pr_price is None:
                            pr_price = s.execute(
                                text("SELECT price FROM product WHERE idproduct=:pid"),
                                {"pid": free_product}
                            ).scalar()
                            pr_price = _to_f(pr_price) if pr_price is not None else 0.0
                        amount = pr_price
                        total -= amount
                        discounts.append({"type": "free_product", "amount": amount, "reason": f"idproduct={free_product}"})

        # find customer + driver
        customer = s.execute(
            text("SELECT postcode, street, city, `number` FROM customer WHERE idCustomer=:id"),
            {"id": customer_id}
        ).mappings().one()

        postcode = (customer["postcode"] or "").replace(" ", "")
        driver = s.execute(text("""
            SELECT e.idEmployee
            FROM employee e
            JOIN delivery_area da ON da.idemployee = e.idEmployee
            WHERE REPLACE(da.postal_code,' ','') = :pc
            ORDER BY e.idEmployee
            LIMIT 1
        """), {"pc": postcode}).scalar()

        if driver is None:
            driver = s.execute(text("""
                SELECT e.idEmployee
                FROM employee e
                JOIN delivery_area da ON da.idemployee = e.idEmployee
                WHERE LEFT(REPLACE(da.postal_code,' ',''),4) = :d
                ORDER BY e.idEmployee
                LIMIT 1
            """), {"d": postcode[:4]}).scalar()

        if driver is None:
            driver = s.execute(text("SELECT idEmployee FROM employee ORDER BY idEmployee LIMIT 1")).scalar()

        if driver is None:
            raise RuntimeError(f"No driver covers postcode {customer['postcode']}")
        new_oid = s.execute(text("SELECT COALESCE(MAX(idorder), 1000) + 1 FROM orders")).scalar_one()

        s.execute(text("""
            INSERT INTO orders (idorder, idcustomer, idemployee, status, street, city, `number`, assignedat)
            VALUES (:oid, :cid, :eid, 'assigned', :st, :ct, :nr, NOW())
        """), {
            "oid": new_oid, "cid": customer_id, "eid": int(driver),
            "st": customer["street"], "ct": customer["city"], "nr": customer["number"],
        })

        for p in pizzas:
            s.execute(text("""
                INSERT INTO order_pizza (idorder, idpizza, quantity)
                VALUES (:oid, :pid, :q)
            """), {"oid": new_oid, "pid": int(p["id"]), "q": int(p["qty"])})

        for pr in products:
            s.execute(text("""
                INSERT INTO order_product (idorder, idproduct, quantity)
                VALUES (:oid, :pid, :q)
            """), {"oid": new_oid, "pid": int(pr["id"]), "q": int(pr["qty"])})

        # NOW safely mark the code as redeemed (only if it was valid & applied)
        if dis_code is not None and discount_row and int(discount_row["is_redeemed"]) == 0:
            s.execute(text("""
                UPDATE discount
                SET is_redeemed = 1, reedemedby = :cid
                WHERE discount_code = :c AND is_redeemed = 0
            """), {"c": int(dis_code), "cid": customer_id})

        return {
            "ok": True,
            "order_id": int(new_oid),
            "driver_id": int(driver),
            "subtotal": round(subtotal, 2),
            "discounts": discounts,
            "total": round(total, 2),
        }
