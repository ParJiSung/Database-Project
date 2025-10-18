# app/services/orders.py
from decimal import Decimal
from sqlalchemy import text
from .. import db

def _to_float(x):
    if isinstance(x, Decimal):
        return float(x)
    return float(x) if x is not None else 0.0

def place_order(payload: dict) -> dict:
    """
    payload = {
      "customer_id": int,
      "pizzas":   [{"id": int, "qty": int}, ...],   # pizza ids from pizza.idPizza
      "products": [{"id": int, "qty": int}, ...],   # product ids from product.idproduct
      "discount_code": Optional[int]
    }
    Returns { ok, order_id, driver_id, subtotal, discounts[], total }
    """
    cust_id = int(payload["customer_id"])
    pizzas  = payload.get("pizzas", []) or []
    prods   = payload.get("products", []) or []
    disc    = payload.get("discount_code")

    if not pizzas:
        return {"ok": False, "msg": "Order must include at least one pizza."}

    with db.SessionLocal() as s, s.begin():
        # --- 1) fetch customer address to store on order row (helps reporting) ---
        c = s.execute(text("""
            SELECT postcode, city, street, `number`
            FROM customer WHERE idCustomer = :cid
        """), {"cid": cust_id}).mappings().first()
        if not c:
            return {"ok": False, "msg": f"Customer {cust_id} not found."}

        # --- 2) price lookups ----------------------------------------------------
        # pizzas via v_pizza_price
        pizza_ids = [p["id"] for p in pizzas]
        price_map_pizza = {}
        rows = s.execute(text("""
            SELECT idPizza, price
            FROM v_pizza_price
            WHERE idPizza IN :ids
        """), {"ids": tuple(pizza_ids)}).mappings().all()
        for r in rows: price_map_pizza[r["idPizza"]] = _to_float(r["price"])

        # products via product table
        prod_ids = [p["id"] for p in prods] if prods else []
        price_map_prod = {}
        if prod_ids:
            rows = s.execute(text("""
                SELECT idproduct, price
                FROM product
                WHERE idproduct IN :ids
            """), {"ids": tuple(prod_ids)}).mappings().all()
            for r in rows: price_map_prod[r["idproduct"]] = _to_float(r["price"])

        # --- 3) compute line totals ---------------------------------------------
        line_total_pizzas = 0.0
        for p in pizzas:
            pid, qty = int(p["id"]), int(p["qty"])
            price = price_map_pizza.get(pid)
            if price is None:
                return {"ok": False, "msg": f"Pizza {pid} has no price."}
            line_total_pizzas += price * qty

        line_total_products = 0.0
        for p in prods:
            pid, qty = int(p["id"]), int(p["qty"])
            price = price_map_prod.get(pid, 0.0)
            line_total_products += price * qty

        subtotal = line_total_pizzas + line_total_products

        # --- 4) create new order id ---------------------------------------------
        order_id = s.execute(text("SELECT COALESCE(MAX(idorder),1000)+1 FROM orders")).scalar_one()

        # --- 5) insert order (idemployee NULL; DB trigger/proc will assign) -----
        s.execute(text("""
            INSERT INTO orders
              (idorder, idcustomer, idemployee, order_time, status,
               street, city, `number`, assignedat, deliveredat, cancelledat)
            VALUES
              (:id, :cid, NULL, NOW(), 'pending',
               :st, :ct, :nr, NULL, NULL, NULL)
        """), {
            "id": order_id, "cid": cust_id,
            "st": c["street"], "ct": c["city"], "nr": c["number"]
        })

        # --- 6) insert line items -----------------------------------------------
        for p in pizzas:
            s.execute(text("""
                INSERT INTO order_pizza (idorder, idpizza, quantity)
                VALUES (:o, :p, :q)
            """), {"o": order_id, "p": int(p["id"]), "q": int(p["qty"])})

        for p in prods:
            s.execute(text("""
                INSERT INTO order_product (idorder, idproduct, quantity)
                VALUES (:o, :p, :q)
            """), {"o": order_id, "p": int(p["id"]), "q": int(p["qty"])})

        # --- 7) apply discount code (percent + optional free item) --------------
        discounts = []
        total = subtotal

        if disc is not None:
            d = s.execute(text("""
                SELECT discount_code, percent, free_product, free_pizza, is_redeemed
                FROM discount WHERE discount_code = :code
                FOR UPDATE
            """), {"code": int(disc)}).mappings().first()

            if d and not d["is_redeemed"]:
                # percent off
                pct = int(d["percent"] or 0)
                if pct > 0:
                    amt = round(total * (pct/100.0), 2)
                    total -= amt
                    discounts.append({"type": f"{pct}% off", "amount": amt})

                # free pizza (one cheapest matching in order)
                if d["free_pizza"]:
                    pid = int(d["free_pizza"])
                    # find its unit price from map and see if present
                    unit = price_map_pizza.get(pid)
                    if unit and any(x["id"] == pid and x["qty"] > 0 for x in pizzas):
                        total -= unit
                        discounts.append({"type": "free pizza", "amount": unit, "reason": f"id {pid}"})

                # free product
                if d["free_product"]:
                    prid = int(d["free_product"])
                    unit = price_map_prod.get(prid)
                    if unit and any(x["id"] == prid and x["qty"] > 0 for x in prods):
                        total -= unit
                        discounts.append({"type": "free product", "amount": unit, "reason": f"id {prid}"})

                # mark redeemed
                s.execute(text("""
                    UPDATE discount
                       SET is_redeemed = 1, reedemedby = :cust
                     WHERE discount_code = :code
                """), {"cust": cust_id, "code": int(disc)})
            else:
                discounts.append({"type": "invalid_or_used_code", "amount": 0.0})

        # Never go negative
        if total < 0:
            total = 0.0

        # --- 8) driver assignment is DB-side (trigger/procedure); read it back --
        drv = s.execute(text("""
            SELECT idemployee FROM orders WHERE idorder = :o
        """), {"o": order_id}).scalar_one_or_none()

        # Build result; cast to float for templates/JSON
        result = {
            "ok": True,
            "order_id": order_id,
            "driver_id": drv,
            "subtotal": round(float(subtotal), 2),
            "discounts": discounts,
            "total": round(float(total), 2),
        }
        return result
