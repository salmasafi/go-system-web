-- Migration 035: Fix update_updated_at_column() trigger function
-- The function unconditionally sets NEW.version = OLD.version + 1,
-- but many tables (bank_accounts, expenses, expense_categories, revenues,
-- revenue_categories, sale_returns, purchase_returns, adjustments,
-- transfer_items, attribute_types, attribute_values, product_attributes)
-- don't have a version column, causing UPDATE operations to fail with:
-- "record 'new' has no field 'version'"
--
-- This migration rewrites the function to conditionally increment version
-- only when the column exists on the target table.

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();

    -- Only increment version if the column exists on this table
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = TG_TABLE_SCHEMA
          AND table_name = TG_TABLE_NAME
          AND column_name = 'version'
    ) THEN
        NEW.version = OLD.version + 1;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Switch shifts back to the unified function now that it handles missing version gracefully
DROP TRIGGER IF EXISTS update_shifts_updated_at ON shifts;
CREATE TRIGGER update_shifts_updated_at
    BEFORE UPDATE ON shifts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Clean up the now-unnecessary separate function
DROP FUNCTION IF EXISTS update_updated_at_only();
