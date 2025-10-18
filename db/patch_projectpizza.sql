-- === Use current db ==========================================================
USE projectpizza;

-- === 1) Fix the bad FK on order_product (idproduct must reference product) ===
SET FOREIGN_KEY_CHECKS=0;
ALTER TABLE order_product DROP FOREIGN KEY fk_orderproduct_product;
ALTER TABLE order_product
  ADD CONSTRAINT fk_orderproduct_product
  FOREIGN KEY (idproduct) REFERENCES product(idproduct)
  ON DELETE RESTRICT ON UPDATE CASCADE;
SET FOREIGN_KEY_CHECKS=1;

-- === 2) (Optional) Let orders be created before assignment ===================
-- If your Python inserts orders first, then assigns, make idemployee NULLable.
-- Comment this out if you prefer to keep it NOT NULL and ALWAYS assign immediately.
ALTER TABLE orders
  MODIFY idemployee INT NULL;

-- Also store timestamps as DATETIME (not VARCHAR) for sanity:
ALTER TABLE orders
  MODIFY assignedat   DATETIME NULL,
  MODIFY deliveredat  DATETIME NULL,
  MODIFY cancelledat  DATETIME NULL;

-- === 3) Pricing & Menu views (shape your app expects) ========================
-- Price = SUM(qty * unit_cost) * (1+margin%) * (1+vat%)
-- Uses per-ingredient rules from pricing_policy; falls back to a global row with ingredient=0 if present.
CREATE OR REPLACE VIEW v_pizza_price AS
SELECT
  p.idPizza,
  p.pizza_name,
  ROUND(
    SUM(
      pi.quantity * i.unit_cost
      * (1 + COALESCE(pp.margin, gp.margin, 0)/100.0)
      * (1 + COALESCE(pp.vat,    gp.vat,    0)/100.0)
    ), 2
  ) AS price
FROM pizza p
JOIN pizza_ingredients pi ON pi.idPizza = p.idPizza
JOIN ingredients i        ON i.idIngredients = pi.idIngredients
LEFT JOIN pricing_policy pp
  ON pp.ingredient = i.idIngredients
 AND CURDATE() >= pp.`from`
 AND (pp.`to` IS NULL OR CURDATE() < pp.`to`)
LEFT JOIN pricing_policy gp
  ON gp.ingredient = 0
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
SELECT pr.idPizza, pr.pizza_name, pr.price, ml.is_vegetarian, ml.is_vegan
FROM v_pizza_price pr
JOIN v_menu_labels ml USING (idPizza);

-- === 4) Undelivered orders view (for reports) ================================
CREATE OR REPLACE VIEW v_undelivered AS
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
WHERE o.deliveredat IS NULL
  AND o.status IN ('pending','assigned')
ORDER BY o.order_time;

-- === 5) Helper view: who can deliver right now (for demos / debugging) =======
CREATE OR REPLACE VIEW v_available_drivers_now AS
SELECT
  e.idEmployee,
  CONCAT(e.first_name,' ',e.last_name) AS driver_name,
  e.available,
  da.postal_code,
  COALESCE(act.active_orders, 0) AS active_orders
FROM employee e
JOIN delivery_area da ON da.idemployee = e.idEmployee
LEFT JOIN (
  SELECT idemployee, COUNT(*) AS active_orders
  FROM orders
  WHERE deliveredat IS NULL AND status IN ('pending','assigned')
  GROUP BY idemployee
) act ON act.idemployee = e.idEmployee
LEFT JOIN delivery_unavailable du
  ON du.idemployee = e.idEmployee
 AND NOW() BETWEEN du.start_time AND du.end_time
WHERE e.available = 1
  AND du.idemployee IS NULL;

-- === 6) Procedure: assign driver with cooldown ===============================
DROP PROCEDURE IF EXISTS assign_driver_for_order;
DELIMITER $$
CREATE PROCEDURE assign_driver_for_order(IN p_order_id INT)
BEGIN
  DECLARE v_postcode VARCHAR(45);
  DECLARE v_driver   INT;

  -- Find customer postcode for this order
  SELECT c.postcode
    INTO v_postcode
  FROM orders o
  JOIN customer c ON c.idCustomer = o.idcustomer
  WHERE o.idorder = p_order_id
  LIMIT 1;

  -- Pick the least-loaded eligible driver for that postcode
  SELECT e.idEmployee
    INTO v_driver
  FROM employee e
  JOIN delivery_area da
    ON da.idemployee = e.idEmployee
   AND da.postal_code = v_postcode
  LEFT JOIN delivery_unavailable du
    ON du.idemployee = e.idEmployee
   AND NOW() BETWEEN du.start_time AND du.end_time
  LEFT JOIN (
     SELECT idemployee, COUNT(*) AS active_orders
     FROM orders
     WHERE deliveredat IS NULL AND status IN ('pending','assigned')
     GROUP BY idemployee
  ) load ON load.idemployee = e.idEmployee
  WHERE e.available = 1
    AND du.idemployee IS NULL
  ORDER BY COALESCE(load.active_orders, 0) ASC, e.idEmployee ASC
  LIMIT 1;

  -- If someone is available, assign and soft-lock for 30 minutes
  IF v_driver IS NOT NULL THEN
    UPDATE orders
       SET idemployee = v_driver,
           status     = 'assigned',
           assignedat = NOW()
     WHERE idorder = p_order_id;

    INSERT INTO delivery_unavailable(idemployee, start_time, end_time)
    VALUES (v_driver, NOW(), NOW() + INTERVAL 30 MINUTE);
  END IF;
END$$
DELIMITER ;

-- === 7) Trigger: auto-assign after a new order is inserted ===================
DROP TRIGGER IF EXISTS trg_orders_after_insert_assign;
DELIMITER $$
CREATE TRIGGER trg_orders_after_insert_assign
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
  -- Auto-fill address fields from customer if they were left empty
  IF (NEW.street IS NULL OR NEW.city IS NULL OR NEW.number IS NULL) THEN
    UPDATE orders o
    JOIN customer c ON c.idCustomer = NEW.idcustomer
       SET o.street = COALESCE(NEW.street, c.street),
           o.city   = COALESCE(NEW.city,   c.city),
           o.`number`=COALESCE(NEW.`number`,c.`number`)
     WHERE o.idorder = NEW.idorder;
  END IF;

  -- Assign a driver right away (will be a no-op if none available)
  CALL assign_driver_for_order(NEW.idorder);
END$$
DELIMITER ;

-- === 8) Event: auto-deliver after 60 minutes =================================
-- turns 'assigned' -> 'delivered' if an hour passed since order_time
SET GLOBAL event_scheduler = ON;

DROP EVENT IF EXISTS ev_autodeliver_after_60m;
CREATE EVENT ev_autodeliver_after_60m
ON SCHEDULE EVERY 5 MINUTE
DO
  UPDATE orders
     SET status      = 'delivered',
         deliveredat = NOW()
   WHERE status = 'assigned'
     AND deliveredat IS NULL
     AND TIMESTAMPDIFF(MINUTE, order_time, NOW()) >= 60;
