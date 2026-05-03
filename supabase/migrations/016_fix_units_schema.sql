-- Migration: Fix units table schema
-- Adds missing columns for base unit relationships

-- Add missing columns to units table
ALTER TABLE units 
    ADD COLUMN IF NOT EXISTS base_unit_id UUID REFERENCES units(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS operator VARCHAR(10) CHECK (operator IN ('*', '/')),
    ADD COLUMN IF NOT EXISTS operator_value DECIMAL(10,4) DEFAULT 1;

-- Ensure version column exists
ALTER TABLE units ADD COLUMN IF NOT EXISTS version INTEGER DEFAULT 1;
