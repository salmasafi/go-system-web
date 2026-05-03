-- ============================================
-- Migration: Remove different_price concept
-- ============================================
-- Products now have a single price. Attributes & options remain for display/selection only.
-- product_prices table is dropped. Sale items, purchase items, etc. reference the product directly.
-- This migration ensures all products use a single price with optional attributes for variations.

-- ============================================
-- 1. Remove different_price column from products
-- ============================================
ALTER TABLE products DROP COLUMN IF EXISTS different_price;

COMMENT ON TABLE products IS 'Products table - each product has a single price with optional attributes for variations';

-- ============================================
-- 2. Drop product_prices table and all references
-- ============================================
-- Drop the table (CASCADE will remove all foreign key constraints automatically)
DROP TABLE IF EXISTS product_prices CASCADE;

-- ============================================
-- 3. Update sale_items: remove product_price_id column
-- ============================================
ALTER TABLE sale_items DROP COLUMN IF EXISTS product_price_id;

COMMENT ON TABLE sale_items IS 'Sale items reference products directly. Attributes are stored in sale_item_attributes table';

-- ============================================
-- 4. Update purchase_item_options: remove product_price_id reference (if exists)
-- ============================================
ALTER TABLE purchase_item_options DROP COLUMN IF EXISTS product_price_id;

-- ============================================
-- 5. Update online_order_items: remove product_price_id reference (if exists)
-- ============================================
ALTER TABLE online_order_items DROP COLUMN IF EXISTS product_price_id;

-- ============================================
-- 6. Update bundle_products: remove product_price_id reference (if exists)
-- ============================================
ALTER TABLE bundle_products DROP COLUMN IF EXISTS product_price_id;

-- ============================================
-- 7. Update sale_return_items: remove product_price_id reference (if exists)
-- ============================================
ALTER TABLE sale_return_items DROP COLUMN IF EXISTS product_price_id;

-- ============================================
-- 8. Update purchase_return_items: remove product_price_id reference (if exists)
-- ============================================
ALTER TABLE purchase_return_items DROP COLUMN IF EXISTS product_price_id;

-- ============================================
-- 9. Drop product_price_options table (junction between prices and variation options)
-- ============================================
DROP TABLE IF EXISTS product_price_options CASCADE;

-- ============================================
-- 10. Update the attribute eligibility trigger function
-- ============================================
-- Attributes are now always allowed since different_price is removed
CREATE OR REPLACE FUNCTION check_product_attributes_eligibility()
RETURNS TRIGGER AS $$
BEGIN
    -- Attributes are always allowed now that different_price is removed
    -- This function is kept for future validation if needed
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 11. Update RLS policies (product_prices policies are auto-removed with table)
-- ============================================
-- No action needed - policies are automatically removed when table is dropped

-- ============================================
-- 12. Update comments for clarity
-- ============================================
COMMENT ON TABLE product_attributes IS 'Links products to their available attributes and values. All products can have attributes regardless of pricing model.';
COMMENT ON TABLE sale_item_attributes IS 'Stores selected attributes for each sale item. Attributes are for display/selection only and do not affect pricing.';

-- ============================================
-- Migration Complete
-- ============================================
-- All products now use a single price (products.price)
-- Attributes can be assigned to any product for variations (color, size, etc.)
-- Attributes do not affect pricing - they are for display and selection only
