INSERT INTO products (id, name, code, price, is_featured, status)
VALUES (
  '76000000-0000-4000-8000-000000000001',
  'Test Product',
  'TEST-001',
  10.00,
  true,
  true
) ON CONFLICT (code) DO NOTHING;

INSERT INTO warehouse_products (warehouse_id, product_id, quantity)
SELECT w.id, '76000000-0000-4000-8000-000000000001', 9999
FROM warehouses w
WHERE NOT EXISTS (
  SELECT 1 FROM warehouse_products wp
  WHERE wp.warehouse_id = w.id AND wp.product_id = '76000000-0000-4000-8000-000000000001'
);
