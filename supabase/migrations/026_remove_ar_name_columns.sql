-- Migration: Remove ar_name and ar_description columns from all tables
-- This consolidates bilingual name fields into a single `name` field
-- Date: 2026-05-07

-- attribute_types
ALTER TABLE public.attribute_types ALTER COLUMN ar_name DROP NOT NULL;
ALTER TABLE public.attribute_types DROP COLUMN IF EXISTS ar_name;

-- attribute_values
ALTER TABLE public.attribute_values ALTER COLUMN ar_name DROP NOT NULL;
ALTER TABLE public.attribute_values DROP COLUMN IF EXISTS ar_name;

-- bank_accounts
ALTER TABLE public.bank_accounts DROP COLUMN IF EXISTS ar_name;

-- branches
ALTER TABLE public.branches DROP COLUMN IF EXISTS ar_name;

-- brands
ALTER TABLE public.brands DROP COLUMN IF EXISTS ar_name;

-- cashiers
ALTER TABLE public.cashiers DROP COLUMN IF EXISTS ar_name;

-- categories
ALTER TABLE public.categories DROP COLUMN IF EXISTS ar_name;

-- cities
ALTER TABLE public.cities DROP COLUMN IF EXISTS ar_name;

-- countries
ALTER TABLE public.countries DROP COLUMN IF EXISTS ar_name;

-- customer_groups
ALTER TABLE public.customer_groups DROP COLUMN IF EXISTS ar_name;

-- departments
ALTER TABLE public.departments DROP COLUMN IF EXISTS ar_name;
ALTER TABLE public.departments DROP COLUMN IF EXISTS ar_description;

-- discounts
ALTER TABLE public.discounts DROP COLUMN IF EXISTS ar_name;

-- expense_categories
ALTER TABLE public.expense_categories DROP COLUMN IF EXISTS ar_name;

-- payment_methods
ALTER TABLE public.payment_methods DROP COLUMN IF EXISTS ar_name;

-- products
ALTER TABLE public.products DROP COLUMN IF EXISTS ar_name;
ALTER TABLE public.products DROP COLUMN IF EXISTS ar_description;

-- reasons
ALTER TABLE public.reasons DROP COLUMN IF EXISTS ar_name;

-- revenue_categories
ALTER TABLE public.revenue_categories DROP COLUMN IF EXISTS ar_name;

-- roles
ALTER TABLE public.roles DROP COLUMN IF EXISTS ar_name;

-- sale_item_attributes
ALTER TABLE public.sale_item_attributes DROP COLUMN IF EXISTS attribute_type_ar_name;
ALTER TABLE public.sale_item_attributes DROP COLUMN IF EXISTS attribute_value_ar_name;

-- taxes
ALTER TABLE public.taxes DROP COLUMN IF EXISTS ar_name;

-- units
ALTER TABLE public.units DROP COLUMN IF EXISTS ar_name;

-- variation_options
ALTER TABLE public.variation_options DROP COLUMN IF EXISTS ar_name;

-- variations
ALTER TABLE public.variations DROP COLUMN IF EXISTS ar_name;

-- warehouses
ALTER TABLE public.warehouses DROP COLUMN IF EXISTS ar_name;

-- zones
ALTER TABLE public.zones DROP COLUMN IF EXISTS ar_name;
