-- Migration: Remove product unit (وحدة المنتج) from products table
-- Keep only sale_unit and purchase_unit

-- Drop the foreign key constraint first
ALTER TABLE public.products
DROP CONSTRAINT IF EXISTS products_unit_id_fkey;

-- Drop the unit_id column
ALTER TABLE public.products
DROP COLUMN IF EXISTS unit_id;

-- Drop the product_unit column
ALTER TABLE public.products
DROP COLUMN IF EXISTS product_unit;
