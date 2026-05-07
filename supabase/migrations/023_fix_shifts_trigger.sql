-- Migration 023: Fix shifts table trigger
-- The update_updated_at_column() function references NEW.version which does not
-- exist on the shifts table, causing any UPDATE on shifts to fail.
-- This migration drops that trigger and replaces it with one that only updates updated_at.

CREATE OR REPLACE FUNCTION update_updated_at_only()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_shifts_updated_at ON shifts;

CREATE TRIGGER update_shifts_updated_at
    BEFORE UPDATE ON shifts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_only();
