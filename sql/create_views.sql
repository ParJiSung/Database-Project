USE databaseproject;

-- now run your create_views.sql content
CREATE OR REPLACE VIEW v_pizza_price AS
SELECT
  p.idPizza,
  p.pizza_name,
  SUM(pi.quantity * i.unit_cost) AS base_cost,
  (SELECT margin FROM pricing_policy WHERE `to` IS NULL ORDER BY `from` DESC LIMIT 1) AS margin_pct,
  (SELECT vat    FROM pricing_policy WHERE `to` IS NULL ORDER BY `from` DESC LIMIT 1) AS vat_pct,
  ROUND(
    SUM(pi.quantity * i.unit_cost)
    * (1 + (SELECT margin FROM pricing_policy WHERE `to` IS NULL ORDER BY `from` DESC LIMIT 1)/100.0)
    * (1 + (SELECT vat    FROM pricing_policy WHERE `to` IS NULL ORDER BY `from` DESC LIMIT 1)/100.0)
  , 2) AS price
FROM pizza p
JOIN pizza_ingredients pi ON pi.idPizza = p.idPizza
JOIN ingredients i        ON i.idIngredients = pi.idIngredients
GROUP BY p.idPizza, p.pizza_name;

CREATE OR REPLACE VIEW v_menu_labels AS
SELECT
  p.idPizza,
  p.pizza_name,
  CASE WHEN MIN(i.vegetarian) = 1 THEN 1 ELSE 0 END AS is_vegetarian,
  CASE WHEN MIN(i.vegan)       = 1 THEN 1 ELSE 0 END AS is_vegan
FROM pizza p
JOIN pizza_ingredients pi ON pi.idPizza = p.idPizza
JOIN ingredients i        ON i.idIngredients = pi.idIngredients
GROUP BY p.idPizza, p.pizza_name;

CREATE OR REPLACE VIEW v_menu AS
SELECT
  pr.idPizza,
  pr.pizza_name,
  pr.price,
  ml.is_vegetarian,
  ml.is_vegan
FROM v_pizza_price pr
JOIN v_menu_labels ml USING (idPizza);

CREATE OR REPLACE VIEW v_undelivered AS
SELECT o.*
FROM orders o
WHERE o.status IN ('pending','assigned') AND o.deliveredat IS NULL;
