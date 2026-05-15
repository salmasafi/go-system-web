-- Migration 041: Fix sale_items RLS policy
--
-- Problem:
--   The old policy checked `s.cashier_id = auth.uid()` but cashier_id references
--   the cashiers table (not auth.users), so this condition was always FALSE for
--   cashier-role users. Only admin/manager could ever see sale_items, causing
--   the products list to appear empty for every other role.
--
-- Fix:
--   Replace the broken cashier check with a subquery that resolves the parent
--   sale through the sales RLS. Because Supabase applies the sales RLS when the
--   sale_items policy queries the sales table, this effectively means
--   "you may see an item if you may see its parent sale" — no separate role
--   list needed.

DROP POLICY IF EXISTS "Authenticated users can view sale items" ON sale_items;

CREATE POLICY "Authenticated users can view sale items" ON sale_items
    FOR SELECT TO authenticated USING (
        EXISTS (
            SELECT 1 FROM sales s WHERE s.id = sale_id
        )
    );
