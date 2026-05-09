-- Migration 036: Fix "record 'new' has no field 'version'" error on sales/customers UPDATE
--
-- Root cause: Migration 032 assigned update_updated_at_and_version() trigger to tables
-- (sales, customers, suppliers, warehouses, etc.) that do NOT have a "version" column.
-- That function unconditionally sets NEW.version = OLD.version + 1, which fails with:
--   "record 'new' has no field 'version'"
--
-- Migration 035 already fixed update_updated_at_column() to conditionally check for
-- the version column before incrementing. So the fix is to switch ALL tables to use
-- the safe update_updated_at_column() function and drop the broken one.

-- Switch all tables that were assigned update_updated_at_and_version() in migration 032
-- to use the safe update_updated_at_column() instead.

-- Products
DROP TRIGGER IF EXISTS update_products_updated_at ON products;
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Customers
DROP TRIGGER IF EXISTS update_customers_updated_at ON customers;
CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Suppliers
DROP TRIGGER IF EXISTS update_suppliers_updated_at ON suppliers;
CREATE TRIGGER update_suppliers_updated_at BEFORE UPDATE ON suppliers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Warehouses
DROP TRIGGER IF EXISTS update_warehouses_updated_at ON warehouses;
CREATE TRIGGER update_warehouses_updated_at BEFORE UPDATE ON warehouses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Sales
DROP TRIGGER IF EXISTS update_sales_updated_at ON sales;
CREATE TRIGGER update_sales_updated_at BEFORE UPDATE ON sales
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Purchases
DROP TRIGGER IF EXISTS update_purchases_updated_at ON purchases;
CREATE TRIGGER update_purchases_updated_at BEFORE UPDATE ON purchases
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Online orders
DROP TRIGGER IF EXISTS update_online_orders_updated_at ON online_orders;
CREATE TRIGGER update_online_orders_updated_at BEFORE UPDATE ON online_orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Taxes
DROP TRIGGER IF EXISTS update_taxes_updated_at ON taxes;
CREATE TRIGGER update_taxes_updated_at BEFORE UPDATE ON taxes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Discounts
DROP TRIGGER IF EXISTS update_discounts_updated_at ON discounts;
CREATE TRIGGER update_discounts_updated_at BEFORE UPDATE ON discounts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Coupons
DROP TRIGGER IF EXISTS update_coupons_updated_at ON coupons;
CREATE TRIGGER update_coupons_updated_at BEFORE UPDATE ON coupons
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Units
DROP TRIGGER IF EXISTS update_units_updated_at ON units;
CREATE TRIGGER update_units_updated_at BEFORE UPDATE ON units
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Drop the now-unnecessary update_updated_at_and_version() function
-- update_updated_at_column() already handles version increment conditionally
DROP FUNCTION IF EXISTS update_updated_at_and_version();
