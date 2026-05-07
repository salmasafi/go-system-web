-- Add reason_id column to expenses table to link expenses with reasons
ALTER TABLE public.expenses
ADD COLUMN IF NOT EXISTS reason_id uuid;

-- Add foreign key constraint
ALTER TABLE public.expenses
DROP CONSTRAINT IF EXISTS fk_expenses_reason;

ALTER TABLE public.expenses
ADD CONSTRAINT fk_expenses_reason
FOREIGN KEY (reason_id) REFERENCES public.reasons(id)
ON DELETE SET NULL;
