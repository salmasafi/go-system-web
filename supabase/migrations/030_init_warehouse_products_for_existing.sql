-- Backfill warehouse_products for all existing products that have no inventory entry.
-- Sets initial quantity to 0; update manually after running if needed.
-- Safe to run multiple times (ON CONFLICT DO NOTHING).

INSERT INTO warehouse_products (warehouse_id, product_id, quantity)
SELECT
  w.id AS warehouse_id,
  p.id AS product_id,
  COALESCE(p.start_quantity, 0) AS quantity
FROM warehouses w
CROSS JOIN products p
WHERE NOT EXISTS (
  SELECT 1
  FROM warehouse_products wp
  WHERE wp.warehouse_id = w.id
    AND wp.product_id   = p.id
)
ON CONFLICT (warehouse_id, product_id) DO NOTHING;
