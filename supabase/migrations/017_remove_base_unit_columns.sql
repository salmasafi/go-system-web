-- ============================================
-- Migration: Remove base unit columns
-- ============================================
-- Remove base unit functionality from units table

-- Drop the base_unit_id column (if it exists)
ALTER TABLE units DROP COLUMN IF EXISTS base_unit_id;

-- Update comment to reflect that base unit functionality has been removed
COMMENT ON TABLE units IS 'Units table - simplified without base unit relationships';

-- Migration Complete
-- All units now operate independently without base unit relationships
-- The operator and operator_value columns remain for unit conversions
