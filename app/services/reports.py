# app/services/reports.py
from sqlalchemy import text
from .. import db

def undelivered():
    sql = """
    SELECT
      o.idorder,
      o.order_time,
      o.status,
      o.idcustomer,
      CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
      c.postcode,
      o.street, o.number, o.city,
      o.idemployee,
      o.assignedat, o.deliveredat
    FROM orders o
    JOIN customer c ON c.idCustomer = o.idcustomer
    WHERE o.deliveredat IS NULL AND o.status IN ('pending','assigned')
    ORDER BY o.order_time
    """
    with db.SessionLocal() as s:
        return [dict(r) for r in s.execute(text(sql)).mappings().all()]

def top_pizzas_last_month(limit=3):
    # Sum quantities in the last 30 days; join name from pizza
    sql = """
    SELECT p.idPizza, p.pizza_name, SUM(op.quantity) AS qty
    FROM orders o
    JOIN order_pizza op ON op.idorder = o.idorder
    JOIN pizza p        ON p.idPizza = op.idpizza
    WHERE o.order_time >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    GROUP BY p.idPizza, p.pizza_name
    ORDER BY qty DESC, p.pizza_name
    LIMIT :lim
    """
    with db.SessionLocal() as s:
        return [dict(r) for r in s.execute(text(sql), {"lim": limit}).mappings().all()]

def earnings(by="postcode"):
    """
    Compute earnings from current prices:
      - pizzas: quantity * v_pizza_price.price
      - products: quantity * product.price
    Group by:
      - 'postcode' (customer.postcode), or
      - 'age' for age buckets
    """
    if by not in ("postcode", "age", "age_group"):
        by = "postcode"

    group_expr = "c.postcode"
    label = "group_key"
    if by in ("age", "age_group"):
        group_expr = """
        CASE
          WHEN TIMESTAMPDIFF(YEAR, c.birthdate, CURDATE()) < 18 THEN '<18'
          WHEN TIMESTAMPDIFF(YEAR, c.birthdate, CURDATE()) BETWEEN 18 AND 24 THEN '18-24'
          WHEN TIMESTAMPDIFF(YEAR, c.birthdate, CURDATE()) BETWEEN 25 AND 34 THEN '25-34'
          WHEN TIMESTAMPDIFF(YEAR, c.birthdate, CURDATE()) BETWEEN 35 AND 44 THEN '35-44'
          WHEN TIMESTAMPDIFF(YEAR, c.birthdate, CURDATE()) BETWEEN 45 AND 64 THEN '45-64'
          ELSE '65+'
        END
        """

    sql = f"""
    WITH
    pizza_rev AS (
      SELECT
        {group_expr} AS {label},
        SUM(op.quantity * v.price) AS amount
      FROM orders o
      JOIN order_pizza op   ON op.idorder = o.idorder
      JOIN customer c       ON c.idCustomer = o.idcustomer
      JOIN v_pizza_price v  ON v.idPizza   = op.idpizza
      GROUP BY {label}
    ),
    product_rev AS (
      SELECT
        {group_expr} AS {label},
        SUM(oo.quantity * pr.price) AS amount
      FROM orders o
      JOIN order_product oo ON oo.idorder  = o.idorder
      JOIN customer c       ON c.idCustomer = o.idcustomer
      JOIN product pr       ON pr.idproduct = oo.idproduct
      GROUP BY {label}
    )
    SELECT x.{label} AS group_key,
           COALESCE(p.amount, 0)   AS pizza_amount,
           COALESCE(pr.amount, 0)  AS product_amount,
           COALESCE(p.amount, 0) + COALESCE(pr.amount, 0) AS total_amount
    FROM (
      SELECT {label} FROM pizza_rev
      UNION
      SELECT {label} FROM product_rev
    ) x
    LEFT JOIN pizza_rev   p  ON p.{label}  = x.{label}
    LEFT JOIN product_rev pr ON pr.{label} = x.{label}
    ORDER BY total_amount DESC
    """
    with db.SessionLocal() as s:
        return [dict(r) for r in s.execute(text(sql)).mappings().all()]

def top_products_last_month(limit=10):
    sql = """
    SELECT pr.idproduct, pr.name, SUM(op.quantity) AS qty
    FROM orders o
    JOIN order_product op ON op.idorder = o.idorder
    JOIN product pr       ON pr.idproduct = op.idproduct
    WHERE o.order_time >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    GROUP BY pr.idproduct, pr.name
    ORDER BY qty DESC, pr.name
    LIMIT :lim
    """
    with db.SessionLocal() as s:
        return [dict(r) for r in s.execute(text(sql), {"lim": limit}).mappings().all()
        ]
