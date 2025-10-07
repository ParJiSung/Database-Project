from datetime import date
from sqlalchemy import text
from ..db import get_session

def is_birthday(customer_id:int)->bool:
    sql = "SELECT birthdate FROM customer WHERE idCustomer=:c"
    with get_session() as s:
        b = s.execute(text(sql), {"c": customer_id}).scalar_one()
    return (b.month, b.day) == (date.today().month, date.today().day)

def pizzas_bought_total(customer_id:int)->int:
    sql = """
    SELECT COALESCE(SUM(op.quantity),0)
    FROM orders o
    JOIN order_pizza op ON op.idorder = o.idorder
    WHERE o.idcustomer=:c
    """
    with get_session() as s:
        return int(s.execute(text(sql), {"c": customer_id}).scalar() or 0)

def redeem_one_time_code(code:int, customer_id:int):
    # discount.is_redeemed must be false; set true + reedemedby=customer_id
    # schema: discount(discount_code, typediscount, percent, fixed_discount, free_product, free_pizza, is_redeemed, reedemedby)
    sql_get = "SELECT * FROM discount WHERE discount_code=:code AND is_redeemed=0 FOR UPDATE"
    with get_session() as s:
        trans = s.begin()
        row = s.execute(text(sql_get), {"code": code}).mappings().first()
        if not row:
            trans.rollback()
            return {"ok": False, "msg": "Invalid or already used"}
        s.execute(text("UPDATE discount SET is_redeemed=1, reedemedby=:c WHERE discount_code=:code"),
                  {"c": customer_id, "code": code})
        trans.commit()
        return {"ok": True, "data": dict(row)}
