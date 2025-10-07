from sqlalchemy import text
from .. import db
from .pricing import price_for_pizza
from .discounts import is_birthday, pizzas_bought_total, redeem_one_time_code
from datetime import date

def place(payload: dict):
    """
    payload = {
      "customer_id": 1,
      "pizzas":   [{"id":1,"qty":1}, {"id":4,"qty":2}],
      "products": [{"id":3,"qty":1}],          # optional
      "discount_code": 1234                    # optional
    }
    """
    if not payload.get("pizzas"):
        return {"ok": False, "msg": "At least one pizza required"}

    try:
        with db.SessionLocal() as s, s.begin():
            # 1) load customer
            cust = s.execute(
                text("SELECT * FROM customer WHERE idCustomer=:c"),
                {"c": payload["customer_id"]},
            ).mappings().first()
            if not cust:
                return {"ok": False, "msg": f"Customer {payload['customer_id']} not found"}

            # 2) driver (simple: by postcode; fallback to lowest id)
            drv = s.execute(
                text("""
                    SELECT e.idEmployee
                    FROM employee e
                    JOIN delivery_area da ON da.idemployee = e.idEmployee
                    WHERE da.postal_code = :pc
                    ORDER BY e.idEmployee
                    LIMIT 1
                """),
                {"pc": cust["postcode"]},
            ).scalar()
            if drv is None:
                drv = s.execute(text("SELECT MIN(idEmployee) FROM employee")).scalar()
            if drv is None:
                return {"ok": False, "msg": "No delivery employees in DB"}

            # 3) new order id (schema not auto-inc)
            oid = s.execute(text("SELECT COALESCE(MAX(idorder),1000)+1 FROM orders")).scalar_one()

            # 4) order header
            s.execute(
                text("""
                    INSERT INTO orders
                      (idorder, idcustomer, idemployee, street, city, number,
                       status, order_time, assignedat)
                    VALUES
                      (:o, :c, :e, :st, :ct, :nr,
                       'assigned',
                       DATE_FORMAT(UTC_TIMESTAMP(), '%Y-%m-%d %H:%i:%s'),
                       DATE_FORMAT(UTC_TIMESTAMP(), '%Y-%m-%d %H:%i:%s'))
                """),
                {
                    "o": oid,
                    "c": cust["idCustomer"],
                    "e": drv,
                    "st": cust["street"],
                    "ct": cust["city"],
                    "nr": cust["number"],
                },
            )

            # 5) lines + subtotal using price view
            subtotal = 0.0
            line_prices = []  # keep for "cheapest pizza" calc
            for it in payload["pizzas"]:
                # ensure pizza exists
                exists = s.execute(
                    text("SELECT 1 FROM pizza WHERE idPizza=:p"), {"p": it["id"]}
                ).scalar()
                if not exists:
                    raise ValueError(f"Pizza id {it['id']} not found")

                s.execute(
                    text("INSERT INTO order_pizza (idorder, idpizza, quantity) VALUES (:o,:p,:q)"),
                    {"o": oid, "p": it["id"], "q": it["qty"]},
                )
                unit = s.execute(
                    text("SELECT price FROM v_pizza_price WHERE idPizza=:p"),
                    {"p": it["id"]},
                ).scalar_one()
                unit = float(unit)
                qty  = int(it["qty"])
                subtotal += unit * qty
                line_prices.extend([unit] * qty)  # expand for accurate “cheapest one” on birthday

            for it in payload.get("products", []):
                s.execute(
                    text("INSERT INTO order_product (idorder, idproduct, quantity) VALUES (:o,:p,:q)"),
                    {"o": oid, "p": it["id"], "q": it["qty"]},
                )

            # 6) discounts
            total = subtotal
            discounts_applied = []

            # Loyalty: 10% off after 10 pizzas lifetime
            pizzas_done = pizzas_bought_total(cust["idCustomer"])
            if pizzas_done >= 10:
                old = total
                total *= 0.9
                discounts_applied.append({"type": "loyalty_10_after_10", "amount": round(old - total, 2)})

            # Birthday: free cheapest pizza (+ optional free drink)
            if is_birthday(cust["idCustomer"]) and line_prices:
                cheapest = min(line_prices)
                total -= cheapest
                discounts_applied.append({"type": "birthday_free_cheapest_pizza", "amount": round(cheapest, 2)})

                # Optional: if any product present, free drink (flat €2.50 demo)
                if payload.get("products"):
                    total -= 2.50
                    discounts_applied.append({"type": "birthday_free_drink", "amount": 2.50})

            # One-time discount code
            code = payload.get("discount_code")
            if code is not None:
                res = redeem_one_time_code(code, cust["idCustomer"])
                if res.get("ok"):
                    row = res["data"]
                    # percent then fixed
                    if row.get("percent"):
                        before = total
                        total *= (1 - row["percent"] / 100.0)
                        discounts_applied.append(
                            {"type": f"code_percent_{row['percent']}", "amount": round(before - total, 2)}
                        )
                    if row.get("fixed_discount"):
                        total -= float(row["fixed_discount"])
                        discounts_applied.append({"type": "code_fixed", "amount": float(row["fixed_discount"])})
                else:
                    # don’t fail the whole order; just report the reason
                    discounts_applied.append({"type": "code_rejected", "reason": res.get("msg", "invalid")})

            if total < 0:
                total = 0.0

            return {
                "ok": True,
                "order_id": oid,
                "driver_id": drv,
                "subtotal": round(subtotal, 2),
                "total": round(total, 2),
                "discounts": discounts_applied,
            }

    except Exception as e:
        return {"ok": False, "msg": f"order failed: {e}"}
