-- Migration: Fix Duplicate Foreign Key for Expenses-ExpenseCategories
-- Problem: Two foreign keys pointing to the same relationship
-- Solution: Remove the auto-generated one, keep the explicit one

-- Drop the duplicate foreign key (the auto-generated one)
ALTER TABLE IF EXISTS expenses
DROP CONSTRAINT IF EXISTS expenses_category_id_fkey;
