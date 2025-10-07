from sqlalchemy import text
from .. import db

def undelivered():
    with db.SessionLocal() as s:
        return [dict(r) for r in s.execute(text("SELECT * FROM v_undelivered ORDER BY order_time")).mappings().all()]

def top_pizzas_last_month():
    sql = """
      SELECT p.pizza_name, SUM(op.quantity) qty
      FROM orders o
      JOIN order_pizza op ON op.idorder=o.idorder
      JOIN pizza p ON p.idPizza=op.idpizza
      WHERE o.order_time >= DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH)
        AND o.status IN ('assigned','delivered')
      GROUP BY p.idPizza, p.pizza_name
      ORDER BY qty DESC
      LIMIT 3;
    """
    with db.SessionLocal() as s:
        return [dict(r) for r in s.execute(text(sql)).mappings().all()]

def earnings(by="postcode"):
    group = {
      "postcode": "c.postcode",
      "age": "TIMESTAMPDIFF(YEAR, c.birthdate, CURRENT_DATE())",
      "gender": "c.gender"  # if you add it
    }.get(by, "c.postcode")

    sql = f"""
      SELECT {group} AS bucket,
             ROUND(SUM(vp.price * op.quantity),2) AS gross_sales
      FROM orders o
      JOIN order_pizza op ON op.idorder=o.idorder
      JOIN v_pizza_price vp ON vp.idPizza=op.idpizza
      JOIN customer c ON c.idCustomer=o.idcustomer
      WHERE o.status IN ('assigned','delivered')
      GROUP BY bucket
      ORDER BY gross_sales DESC;
    """
    with db.SessionLocal() as s:
        return [dict(r) for r in s.execute(text(sql)).mappings().all()]
