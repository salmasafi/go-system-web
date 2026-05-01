-- Migration: Remove different_price concept
-- Products now have a single price. Attributes & options remain for display/selection only.
-- product_prices table is dropped. Sale items, purchase items, etc. reference the product directly.

-- ============================================
-- 1. Remove different_price column from products
-- ============================================
ALTER TABLE products DROP COLUMN IF EXISTS different_price;

-- ============================================
-- 2. Update sale_items: make product_price_id nullable and eventually remove
-- ============================================
-- First, drop the foreign key constraint
ALTER TABLE sale_items DROP CONSTRAINT IF EXISTS sale_items_product_price_id_fkey;
-- Make the column nullable (it may already be)
ALTER TABLE sale_items ALTER COLUMN product_price_id DROP NOT NULL;

-- ============================================
-- 3. Update purchase_item_options: remove product_price_id reference
-- ============================================
ALTER TABLE purchase_item_options DROP CONSTRAINT IF EXISTS purchase_item_options_product_price_id_fkey;
ALTER TABLE purchase_item_options DROP COLUMN IF EXISTS product_price_id;

-- ============================================
-- 4. Update online_order_items: remove product_price_id reference
-- ============================================
ALTER TABLE online_order_items DROP CONSTRAINT IF EXISTS online_order_items_product_price_id_fkey;
ALTER TABLE online_order_items DROP COLUMN IF EXISTS product_price_id;

-- ============================================
-- 5. Update bundle_products: remove product_price_id reference
-- ============================================
ALTER TABLE bundle_products DROP CONSTRAINT IF EXISTS bundle_products_product_price_id_fkey;
ALTER TABLE bundle_products DROP COLUMN IF EXISTS product_price_id;

-- ============================================
-- 6. Drop product_price_options table (junction between prices and variation options)
-- ============================================
DROP TABLE IF EXISTS product_price_options;

-- ============================================
-- 7. Drop product_prices table
-- ============================================
DROP TABLE IF EXISTS product_prices;

-- ============================================
-- 8. Update the attribute eligibility trigger function
-- (No longer need to check different_price since it's removed)
-- ============================================
CREATE OR REPLACE FUNCTION check_product_attributes_eligibility()
RETURNS TRIGGER AS $$
BEGIN
    -- Attributes are always allowed now that different_price is removed
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 9. Remove RLS policy for product_prices (table no longer exists)
-- ============================================
-- (Automatically removed when table is dropped)
