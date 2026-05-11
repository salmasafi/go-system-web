-- Ensure warehouses.stock_quantity exists (some deployments might be missing it)
ALTER TABLE public.warehouses
ADD COLUMN IF NOT EXISTS stock_quantity INTEGER DEFAULT 0;

-- Backfill stock_quantity based on current warehouse_products quantities
UPDATE public.warehouses w
SET stock_quantity = COALESCE(x.total_quantity, 0),
    updated_at = NOW()
FROM (
  SELECT warehouse_id, COALESCE(SUM(quantity), 0) AS total_quantity
  FROM public.warehouse_products
  GROUP BY warehouse_id
) x
WHERE w.id = x.warehouse_id;

-- Warehouses with no warehouse_products rows
UPDATE public.warehouses
SET stock_quantity = 0,
    updated_at = NOW()
WHERE stock_quantity IS NULL;
