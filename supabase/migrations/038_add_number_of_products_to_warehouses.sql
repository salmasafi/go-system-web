-- Add missing number_of_products column to warehouses table
ALTER TABLE warehouses
ADD COLUMN IF NOT EXISTS number_of_products INTEGER DEFAULT 0;

-- Backfill existing rows with correct counts
UPDATE warehouses w
SET number_of_products = (
    SELECT COUNT(*) FROM warehouse_products WHERE warehouse_id = w.id
);
