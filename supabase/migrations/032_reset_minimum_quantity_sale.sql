-- Migration 032: Reset minimum_quantity_sale to 1 for all existing products
-- Root cause: add_product_screen had a default of 50 instead of 1,
-- so all products created via the UI have minimum_quantity_sale = 50.

-- Fix the trigger function first: it unconditionally sets NEW.version = OLD.version + 1,
-- but many tables don't have a version column, causing UPDATE to fail with:
-- "record 'new' has no field 'version'"
-- Solution: Remove version handling from the shared function.
-- Tables that need version tracking get their own dedicated trigger.
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a separate function for tables that DO have a version column
CREATE OR REPLACE FUNCTION update_updated_at_and_version()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    NEW.version = OLD.version + 1;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Switch tables that HAVE a version column to use the new function
-- Products
DROP TRIGGER IF EXISTS update_products_updated_at ON products;
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_and_version();

-- Customers
DROP TRIGGER IF EXISTS update_customers_updated_at ON customers;
CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_and_version();

-- Suppliers
DROP TRIGGER IF EXISTS update_suppliers_updated_at ON suppliers;
CREATE TRIGGER update_suppliers_updated_at BEFORE UPDATE ON suppliers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_and_version();

-- Warehouses
DROP TRIGGER IF EXISTS update_warehouses_updated_at ON warehouses;
CREATE TRIGGER update_warehouses_updated_at BEFORE UPDATE ON warehouses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_and_version();

-- Sales
DROP TRIGGER IF EXISTS update_sales_updated_at ON sales;
CREATE TRIGGER update_sales_updated_at BEFORE UPDATE ON sales
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_and_version();

-- Purchases
DROP TRIGGER IF EXISTS update_purchases_updated_at ON purchases;
CREATE TRIGGER update_purchases_updated_at BEFORE UPDATE ON purchases
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_and_version();

-- Online orders
DROP TRIGGER IF EXISTS update_online_orders_updated_at ON online_orders;
CREATE TRIGGER update_online_orders_updated_at BEFORE UPDATE ON online_orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_and_version();

-- Taxes
DROP TRIGGER IF EXISTS update_taxes_updated_at ON taxes;
CREATE TRIGGER update_taxes_updated_at BEFORE UPDATE ON taxes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_and_version();

-- Discounts
DROP TRIGGER IF EXISTS update_discounts_updated_at ON discounts;
CREATE TRIGGER update_discounts_updated_at BEFORE UPDATE ON discounts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_and_version();

-- Coupons
DROP TRIGGER IF EXISTS update_coupons_updated_at ON coupons;
CREATE TRIGGER update_coupons_updated_at BEFORE UPDATE ON coupons
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_and_version();

-- Units
DROP TRIGGER IF EXISTS update_units_updated_at ON units;
CREATE TRIGGER update_units_updated_at BEFORE UPDATE ON units
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_and_version();

-- Switch shifts back to the unified function (migration 023 created a separate one)
DROP TRIGGER IF EXISTS update_shifts_updated_at ON shifts;
CREATE TRIGGER update_shifts_updated_at BEFORE UPDATE ON shifts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Clean up the now-unnecessary separate function from migration 023
DROP FUNCTION IF EXISTS update_updated_at_only();

-- Now safe to UPDATE products
UPDATE products
SET    minimum_quantity_sale = 1,
       updated_at = NOW()
WHERE  minimum_quantity_sale <> 1;
