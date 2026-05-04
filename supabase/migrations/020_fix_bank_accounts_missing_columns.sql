-- Fix: Add missing current_balance and opening_balance columns to bank_accounts
-- This migration ensures these columns exist even if the table was created before they were defined

-- Add opening_balance column if it doesn't exist
ALTER TABLE bank_accounts 
ADD COLUMN IF NOT EXISTS opening_balance DECIMAL(12,2) DEFAULT 0;

-- Add current_balance column if it doesn't exist
ALTER TABLE bank_accounts 
ADD COLUMN IF NOT EXISTS current_balance DECIMAL(12,2) DEFAULT 0;

-- Refresh the schema cache comment for Supabase
COMMENT ON COLUMN bank_accounts.opening_balance IS 'Initial balance when account was created';
COMMENT ON COLUMN bank_accounts.current_balance IS 'Current account balance (calculated from transactions)';
