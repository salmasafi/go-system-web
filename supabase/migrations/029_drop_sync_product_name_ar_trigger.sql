-- Migration: Drop sync_product_name_ar trigger function and associated triggers
-- The ar_name column was dropped in migration 026 but this trigger was not removed
-- This causes ERROR: record "new" has no field "ar_name" when inserting products

-- Drop any triggers on products table that reference sync_product_name_ar
DO $$
DECLARE
    trg RECORD;
BEGIN
    FOR trg IN
        SELECT trigger_name, event_object_table
        FROM information_schema.triggers
        WHERE trigger_schema = 'public'
          AND (trigger_name ILIKE '%sync_product_name_ar%'
               OR action_statement ILIKE '%sync_product_name_ar%')
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS %I ON public.%I', trg.trigger_name, trg.event_object_table);
        RAISE NOTICE 'Dropped trigger % on table %', trg.trigger_name, trg.event_object_table;
    END LOOP;
END $$;

-- Drop the trigger function itself
DROP FUNCTION IF EXISTS public.sync_product_name_ar();

-- Also ensure name_ar column is dropped from products (in case migration 026 didn't fully apply)
ALTER TABLE public.products DROP COLUMN IF EXISTS name_ar;
