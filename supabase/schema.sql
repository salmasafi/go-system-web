-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.adjustment_items (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  adjustment_id uuid,
  product_id uuid,
  quantity integer NOT NULL CHECK (quantity > 0),
  current_stock integer NOT NULL,
  new_stock integer NOT NULL,
  unit_cost numeric DEFAULT 0,
  total_cost numeric DEFAULT 0,
  reason text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT adjustment_items_pkey PRIMARY KEY (id),
  CONSTRAINT adjustment_items_adjustment_id_fkey FOREIGN KEY (adjustment_id) REFERENCES public.adjustments(id),
  CONSTRAINT adjustment_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);
CREATE TABLE public.adjustments (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  reference text NOT NULL UNIQUE,
  warehouse_id uuid NOT NULL,
  product_id uuid NOT NULL,
  type text NOT NULL,
  quantity integer NOT NULL,
  reason text,
  status text DEFAULT 'approved'::text,
  date date NOT NULL,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT adjustments_pkey PRIMARY KEY (id),
  CONSTRAINT adjustments_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id),
  CONSTRAINT adjustments_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.admins(id),
  CONSTRAINT adjustments_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);
CREATE TABLE public.admins (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  username text NOT NULL UNIQUE,
  email text NOT NULL UNIQUE,
  password_hash text NOT NULL,
  phone text,
  company_name text,
  role_id uuid,
  department_id uuid,
  status text DEFAULT 'active'::text,
  warehouse_id uuid,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT admins_pkey PRIMARY KEY (id),
  CONSTRAINT admins_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id),
  CONSTRAINT admins_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id),
  CONSTRAINT admins_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id),
  CONSTRAINT admins_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.admins(id)
);
CREATE TABLE public.attribute_types (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name character varying NOT NULL UNIQUE,
  ar_name character varying NOT NULL,
  status boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT attribute_types_pkey PRIMARY KEY (id)
);
CREATE TABLE public.attribute_values (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  attribute_type_id uuid NOT NULL,
  name character varying NOT NULL,
  ar_name character varying NOT NULL,
  status boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT attribute_values_pkey PRIMARY KEY (id),
  CONSTRAINT attribute_values_attribute_type_id_fkey FOREIGN KEY (attribute_type_id) REFERENCES public.attribute_types(id)
);
CREATE TABLE public.bank_accounts (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  ar_name text,
  account_number text,
  description text,
  image text,
  balance numeric NOT NULL DEFAULT 0,
  initial_balance numeric NOT NULL DEFAULT 0,
  is_default boolean DEFAULT false,
  status boolean DEFAULT true,
  in_pos boolean DEFAULT false,
  warehouse_id uuid,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  account_type character varying DEFAULT 'checking'::character varying CHECK (account_type::text = ANY (ARRAY['checking'::character varying, 'savings'::character varying, 'cash'::character varying, 'credit'::character varying]::text[])),
  is_active boolean DEFAULT true,
  CONSTRAINT bank_accounts_pkey PRIMARY KEY (id),
  CONSTRAINT bank_accounts_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id),
  CONSTRAINT bank_accounts_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.admins(id)
);
CREATE TABLE public.branches (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  ar_name text,
  warehouse_id uuid,
  address text,
  phone text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT branches_pkey PRIMARY KEY (id),
  CONSTRAINT branches_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id)
);
CREATE TABLE public.brands (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  ar_name text,
  logo text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT brands_pkey PRIMARY KEY (id)
);
CREATE TABLE public.bundle_products (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  bundle_id uuid NOT NULL,
  product_id uuid NOT NULL,
  quantity integer NOT NULL DEFAULT 1,
  CONSTRAINT bundle_products_pkey PRIMARY KEY (id),
  CONSTRAINT bundle_products_bundle_id_fkey FOREIGN KEY (bundle_id) REFERENCES public.bundles(id),
  CONSTRAINT bundle_products_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);
CREATE TABLE public.bundle_warehouses (
  bundle_id uuid NOT NULL,
  warehouse_id uuid NOT NULL,
  CONSTRAINT bundle_warehouses_pkey PRIMARY KEY (bundle_id, warehouse_id),
  CONSTRAINT bundle_warehouses_bundle_id_fkey FOREIGN KEY (bundle_id) REFERENCES public.bundles(id),
  CONSTRAINT bundle_warehouses_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id)
);
CREATE TABLE public.bundles (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  price numeric NOT NULL DEFAULT 0,
  start_date date NOT NULL,
  end_date date NOT NULL,
  status boolean DEFAULT true,
  images ARRAY DEFAULT '{}'::text[],
  all_warehouses boolean DEFAULT true,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  products jsonb DEFAULT '[]'::jsonb,
  CONSTRAINT bundles_pkey PRIMARY KEY (id),
  CONSTRAINT bundles_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.admins(id)
);
CREATE TABLE public.cashier_bank_accounts (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  cashier_id uuid NOT NULL,
  bank_account_id uuid NOT NULL,
  CONSTRAINT cashier_bank_accounts_pkey PRIMARY KEY (id),
  CONSTRAINT cashier_bank_accounts_cashier_id_fkey FOREIGN KEY (cashier_id) REFERENCES public.cashiers(id),
  CONSTRAINT cashier_bank_accounts_bank_account_id_fkey FOREIGN KEY (bank_account_id) REFERENCES public.bank_accounts(id)
);
CREATE TABLE public.cashier_users (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  cashier_id uuid NOT NULL,
  admin_id uuid NOT NULL,
  CONSTRAINT cashier_users_pkey PRIMARY KEY (id),
  CONSTRAINT cashier_users_cashier_id_fkey FOREIGN KEY (cashier_id) REFERENCES public.cashiers(id),
  CONSTRAINT cashier_users_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES public.admins(id)
);
CREATE TABLE public.cashiers (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  ar_name text,
  warehouse_id uuid NOT NULL,
  status boolean DEFAULT true,
  cashier_active boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT cashiers_pkey PRIMARY KEY (id),
  CONSTRAINT cashiers_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id)
);
CREATE TABLE public.categories (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  ar_name text,
  image text,
  parent_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT categories_pkey PRIMARY KEY (id),
  CONSTRAINT categories_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.categories(id)
);
CREATE TABLE public.cities (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  ar_name text,
  country_id uuid NOT NULL,
  shipping_cost numeric DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT cities_pkey PRIMARY KEY (id),
  CONSTRAINT cities_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.countries(id)
);
CREATE TABLE public.countries (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  ar_name text,
  is_default boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT countries_pkey PRIMARY KEY (id)
);
CREATE TABLE public.coupon_categories (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  coupon_id uuid NOT NULL,
  category_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT coupon_categories_pkey PRIMARY KEY (id),
  CONSTRAINT coupon_categories_coupon_id_fkey FOREIGN KEY (coupon_id) REFERENCES public.coupons(id),
  CONSTRAINT coupon_categories_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id)
);
CREATE TABLE public.coupon_products (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  coupon_id uuid NOT NULL,
  product_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT coupon_products_pkey PRIMARY KEY (id),
  CONSTRAINT coupon_products_coupon_id_fkey FOREIGN KEY (coupon_id) REFERENCES public.coupons(id),
  CONSTRAINT coupon_products_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);
CREATE TABLE public.coupons (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  discount_type text NOT NULL,
  discount_value numeric NOT NULL DEFAULT 0,
  min_purchase numeric DEFAULT 0,
  max_discount numeric,
  start_date date NOT NULL,
  end_date date NOT NULL,
  usage_limit integer,
  usage_count integer DEFAULT 0,
  status boolean DEFAULT true,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT coupons_pkey PRIMARY KEY (id),
  CONSTRAINT coupons_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.admins(id)
);
CREATE TABLE public.currencies (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  code text NOT NULL UNIQUE,
  symbol text,
  is_default boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT currencies_pkey PRIMARY KEY (id)
);
CREATE TABLE public.customer_groups (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  ar_name text,
  status boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT customer_groups_pkey PRIMARY KEY (id)
);
CREATE TABLE public.customers (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  email text,
  phone_number text,
  address text,
  city_id uuid,
  country_id uuid,
  customer_group_id uuid,
  is_due boolean DEFAULT false,
  amount_due numeric DEFAULT 0,
  total_points_earned integer DEFAULT 0,
  total_purchases numeric DEFAULT 0,
  status boolean DEFAULT true,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT customers_pkey PRIMARY KEY (id),
  CONSTRAINT customers_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.cities(id),
  CONSTRAINT customers_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.countries(id),
  CONSTRAINT customers_customer_group_id_fkey FOREIGN KEY (customer_group_id) REFERENCES public.customer_groups(id),
  CONSTRAINT customers_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.admins(id),
  CONSTRAINT fk_customer_group FOREIGN KEY (customer_group_id) REFERENCES public.customer_groups(id)
);
CREATE TABLE public.departments (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  ar_name text,
  description text,
  ar_description text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT departments_pkey PRIMARY KEY (id)
);
CREATE TABLE public.discount_categories (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  discount_id uuid NOT NULL,
  category_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT discount_categories_pkey PRIMARY KEY (id),
  CONSTRAINT discount_categories_discount_id_fkey FOREIGN KEY (discount_id) REFERENCES public.discounts(id),
  CONSTRAINT discount_categories_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id)
);
CREATE TABLE public.discount_products (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  discount_id uuid NOT NULL,
  product_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT discount_products_pkey PRIMARY KEY (id),
  CONSTRAINT discount_products_discount_id_fkey FOREIGN KEY (discount_id) REFERENCES public.discounts(id),
  CONSTRAINT discount_products_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);
CREATE TABLE public.discounts (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  ar_name text,
  amount numeric NOT NULL DEFAULT 0,
  type text NOT NULL DEFAULT 'percentage'::text,
  status boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT discounts_pkey PRIMARY KEY (id)
);
CREATE TABLE public.due_payments (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  purchase_id uuid,
  sale_id uuid,
  amount numeric NOT NULL,
  date date NOT NULL,
  financial_account_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  version integer DEFAULT 1,
  CONSTRAINT due_payments_pkey PRIMARY KEY (id),
  CONSTRAINT due_payments_purchase_id_fkey FOREIGN KEY (purchase_id) REFERENCES public.purchases(id),
  CONSTRAINT due_payments_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id)
);
CREATE TABLE public.exchange_rates (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  from_currency_id uuid NOT NULL,
  to_currency_id uuid NOT NULL,
  rate numeric NOT NULL,
  date date NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT exchange_rates_pkey PRIMARY KEY (id),
  CONSTRAINT exchange_rates_from_currency_id_fkey FOREIGN KEY (from_currency_id) REFERENCES public.currencies(id),
  CONSTRAINT exchange_rates_to_currency_id_fkey FOREIGN KEY (to_currency_id) REFERENCES public.currencies(id)
);
CREATE TABLE public.expense_categories (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  ar_name text,
  status boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  description text,
  color character varying DEFAULT '#666666'::character varying,
  CONSTRAINT expense_categories_pkey PRIMARY KEY (id)
);
CREATE TABLE public.expenses (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  amount numeric NOT NULL,
  category_id uuid,
  bank_account_id uuid NOT NULL,
  shift_id uuid,
  note text,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  description text,
  date date DEFAULT CURRENT_DATE,
  receipt_image text,
  status boolean DEFAULT true,
  CONSTRAINT expenses_pkey PRIMARY KEY (id),
  CONSTRAINT expenses_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.expense_categories(id),
  CONSTRAINT expenses_bank_account_id_fkey FOREIGN KEY (bank_account_id) REFERENCES public.bank_accounts(id),
  CONSTRAINT expenses_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.admins(id),
  CONSTRAINT fk_expenses_shift FOREIGN KEY (shift_id) REFERENCES public.shifts(id),
  CONSTRAINT fk_expense_category FOREIGN KEY (category_id) REFERENCES public.expense_categories(id)
);
CREATE TABLE public.financial_transactions (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  bank_account_id uuid NOT NULL,
  type text NOT NULL,
  amount numeric NOT NULL,
  reference_type text NOT NULL,
  reference_id uuid NOT NULL,
  description text,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT financial_transactions_pkey PRIMARY KEY (id),
  CONSTRAINT financial_transactions_bank_account_id_fkey FOREIGN KEY (bank_account_id) REFERENCES public.bank_accounts(id),
  CONSTRAINT financial_transactions_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.admins(id)
);
CREATE TABLE public.invoices (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  purchase_id uuid,
  amount numeric NOT NULL,
  date date NOT NULL,
  reference character varying,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT invoices_pkey PRIMARY KEY (id),
  CONSTRAINT invoices_purchase_id_fkey FOREIGN KEY (purchase_id) REFERENCES public.purchases(id)
);
CREATE TABLE public.migration_logs (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  feature_name character varying NOT NULL,
  data_source character varying NOT NULL CHECK (data_source::text = ANY (ARRAY['dio'::character varying, 'supabase'::character varying]::text[])),
  migrated_at timestamp with time zone DEFAULT now(),
  migrated_by uuid,
  rollback_available boolean DEFAULT true,
  notes text,
  CONSTRAINT migration_logs_pkey PRIMARY KEY (id)
);
CREATE TABLE public.notifications (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  title text NOT NULL,
  message text NOT NULL,
  type text,
  is_read boolean DEFAULT false,
  admin_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  product_id uuid,
  severity text DEFAULT 'info'::text,
  notification_key text,
  updated_at timestamp with time zone DEFAULT now(),
  user_id uuid,
  body text,
  related_id uuid,
  CONSTRAINT notifications_pkey PRIMARY KEY (id),
  CONSTRAINT notifications_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES public.admins(id),
  CONSTRAINT notifications_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id),
  CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_profiles(id)
);
CREATE TABLE public.online_order_items (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  online_order_id uuid NOT NULL,
  product_id uuid NOT NULL,
  quantity integer NOT NULL,
  price numeric NOT NULL,
  whole_price numeric,
  subtotal numeric NOT NULL,
  CONSTRAINT online_order_items_pkey PRIMARY KEY (id),
  CONSTRAINT online_order_items_online_order_id_fkey FOREIGN KEY (online_order_id) REFERENCES public.online_orders(id),
  CONSTRAINT online_order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);
CREATE TABLE public.online_orders (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  order_number text NOT NULL UNIQUE,
  customer_id uuid,
  branch_id uuid,
  total_amount numeric DEFAULT 0,
  grand_total numeric DEFAULT 0,
  status text DEFAULT 'pending'::text,
  type text,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  currency_id uuid,
  CONSTRAINT online_orders_pkey PRIMARY KEY (id),
  CONSTRAINT online_orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id),
  CONSTRAINT online_orders_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id),
  CONSTRAINT online_orders_currency_id_fkey FOREIGN KEY (currency_id) REFERENCES public.currencies(id)
);
CREATE TABLE public.payment_methods (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  ar_name text,
  type text,
  description text,
  icon text,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  code character varying,
  is_default boolean DEFAULT false,
  CONSTRAINT payment_methods_pkey PRIMARY KEY (id)
);
CREATE TABLE public.permissions (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  module text NOT NULL,
  action text NOT NULL,
  role_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT permissions_pkey PRIMARY KEY (id),
  CONSTRAINT permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id)
);
CREATE TABLE public.points_rules (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  amount numeric NOT NULL,
  points integer NOT NULL,
  status boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT points_rules_pkey PRIMARY KEY (id)
);
CREATE TABLE public.points_transactions (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  customer_id uuid,
  type character varying CHECK (type::text = ANY (ARRAY['earned'::character varying, 'redeemed'::character varying]::text[])),
  points integer NOT NULL,
  reference_type character varying,
  reference_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT points_transactions_pkey PRIMARY KEY (id),
  CONSTRAINT points_transactions_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id)
);
CREATE TABLE public.product_attributes (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  product_id uuid NOT NULL,
  attribute_type_id uuid NOT NULL,
  attribute_value_ids ARRAY NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT product_attributes_pkey PRIMARY KEY (id),
  CONSTRAINT product_attributes_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id),
  CONSTRAINT product_attributes_attribute_type_id_fkey FOREIGN KEY (attribute_type_id) REFERENCES public.attribute_types(id)
);
CREATE TABLE public.product_categories (
  product_id uuid NOT NULL,
  category_id uuid NOT NULL,
  CONSTRAINT product_categories_pkey PRIMARY KEY (product_id, category_id),
  CONSTRAINT product_categories_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id),
  CONSTRAINT product_categories_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id)
);
CREATE TABLE public.product_warehouses (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  product_id uuid NOT NULL,
  warehouse_id uuid NOT NULL,
  quantity integer NOT NULL DEFAULT 0,
  low_stock integer DEFAULT 0,
  CONSTRAINT product_warehouses_pkey PRIMARY KEY (id),
  CONSTRAINT product_warehouses_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id),
  CONSTRAINT product_warehouses_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id)
);
CREATE TABLE public.products (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  ar_name text,
  code text NOT NULL UNIQUE,
  description text,
  ar_description text,
  image text,
  gallery_product ARRAY DEFAULT '{}'::text[],
  price numeric NOT NULL DEFAULT 0,
  whole_price numeric DEFAULT 0,
  start_quantity integer DEFAULT 0,
  cost numeric DEFAULT 0,
  unit_id uuid,
  brand_id uuid,
  tax_id uuid,
  exp_ability boolean DEFAULT false,
  date_of_expiry date,
  minimum_quantity_sale integer DEFAULT 0,
  low_stock integer DEFAULT 0,
  product_has_imei boolean DEFAULT false,
  different_price boolean DEFAULT false,
  show_quantity boolean DEFAULT true,
  maximum_to_show integer DEFAULT 0,
  is_featured boolean DEFAULT false,
  status boolean DEFAULT true,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  name_ar text,
  product_unit character varying,
  purchase_unit character varying,
  sale_unit character varying,
  CONSTRAINT products_pkey PRIMARY KEY (id),
  CONSTRAINT products_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.units(id),
  CONSTRAINT products_tax_id_fkey FOREIGN KEY (tax_id) REFERENCES public.taxes(id),
  CONSTRAINT products_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.admins(id),
  CONSTRAINT products_brand_id_fkey FOREIGN KEY (brand_id) REFERENCES public.brands(id)
);
CREATE TABLE public.purchase_due_payments (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  purchase_id uuid NOT NULL,
  amount numeric NOT NULL,
  date date NOT NULL,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT purchase_due_payments_pkey PRIMARY KEY (id),
  CONSTRAINT purchase_due_payments_purchase_id_fkey FOREIGN KEY (purchase_id) REFERENCES public.purchases(id),
  CONSTRAINT purchase_due_payments_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.admins(id)
);
CREATE TABLE public.purchase_invoices (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  purchase_id uuid NOT NULL,
  bank_account_id uuid NOT NULL,
  amount numeric NOT NULL,
  date date NOT NULL,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  currency_id uuid,
  CONSTRAINT purchase_invoices_pkey PRIMARY KEY (id),
  CONSTRAINT purchase_invoices_purchase_id_fkey FOREIGN KEY (purchase_id) REFERENCES public.purchases(id),
  CONSTRAINT purchase_invoices_bank_account_id_fkey FOREIGN KEY (bank_account_id) REFERENCES public.bank_accounts(id),
  CONSTRAINT purchase_invoices_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.admins(id),
  CONSTRAINT purchase_invoices_currency_id_fkey FOREIGN KEY (currency_id) REFERENCES public.currencies(id)
);
CREATE TABLE public.purchase_item_options (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  purchase_item_id uuid NOT NULL,
  option_id uuid,
  quantity integer NOT NULL,
  CONSTRAINT purchase_item_options_pkey PRIMARY KEY (id),
  CONSTRAINT purchase_item_options_purchase_item_id_fkey FOREIGN KEY (purchase_item_id) REFERENCES public.purchase_items(id),
  CONSTRAINT purchase_item_options_option_id_fkey FOREIGN KEY (option_id) REFERENCES public.variation_options(id)
);
CREATE TABLE public.purchase_items (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  purchase_id uuid NOT NULL,
  product_id uuid NOT NULL,
  category_id uuid,
  warehouse_id uuid NOT NULL,
  quantity integer NOT NULL,
  unit_cost numeric NOT NULL,
  subtotal numeric NOT NULL,
  discount_share numeric DEFAULT 0,
  unit_cost_after_discount numeric NOT NULL,
  tax numeric DEFAULT 0,
  item_type text DEFAULT 'product'::text,
  date_of_expiry date,
  patch_number text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT purchase_items_pkey PRIMARY KEY (id),
  CONSTRAINT purchase_items_purchase_id_fkey FOREIGN KEY (purchase_id) REFERENCES public.purchases(id),
  CONSTRAINT purchase_items_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id),
  CONSTRAINT purchase_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id),
  CONSTRAINT purchase_items_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id)
);
CREATE TABLE public.purchase_return_items (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  return_id uuid NOT NULL,
  product_id uuid NOT NULL,
  purchase_item_id uuid,
  original_quantity integer NOT NULL,
  returned_quantity integer NOT NULL,
  price numeric NOT NULL,
  subtotal numeric NOT NULL,
  reason text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT purchase_return_items_pkey PRIMARY KEY (id),
  CONSTRAINT purchase_return_items_return_id_fkey FOREIGN KEY (return_id) REFERENCES public.purchase_returns(id),
  CONSTRAINT purchase_return_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id),
  CONSTRAINT purchase_return_items_purchase_item_id_fkey FOREIGN KEY (purchase_item_id) REFERENCES public.purchase_items(id)
);
CREATE TABLE public.purchase_returns (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  purchase_id uuid NOT NULL,
  reference text NOT NULL UNIQUE,
  supplier_id uuid,
  warehouse_id uuid,
  total_amount numeric NOT NULL,
  refund_method text DEFAULT 'cash'::text,
  status text DEFAULT 'completed'::text CHECK (status = ANY (ARRAY['pending'::text, 'completed'::text, 'cancelled'::text])),
  note text,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT purchase_returns_pkey PRIMARY KEY (id),
  CONSTRAINT purchase_returns_purchase_id_fkey FOREIGN KEY (purchase_id) REFERENCES public.purchases(id),
  CONSTRAINT purchase_returns_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id),
  CONSTRAINT purchase_returns_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id),
  CONSTRAINT purchase_returns_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.admins(id)
);
CREATE TABLE public.purchases (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  reference text NOT NULL UNIQUE,
  date date NOT NULL,
  warehouse_id uuid NOT NULL,
  supplier_id uuid,
  tax_id uuid,
  currency_id uuid,
  exchange_rate numeric DEFAULT 1,
  receipt_img text,
  payment_status text DEFAULT 'later'::text,
  total numeric DEFAULT 0,
  discount numeric DEFAULT 0,
  shipping_cost numeric DEFAULT 0,
  grand_total numeric DEFAULT 0,
  note text,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT purchases_pkey PRIMARY KEY (id),
  CONSTRAINT purchases_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id),
  CONSTRAINT purchases_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id),
  CONSTRAINT purchases_tax_id_fkey FOREIGN KEY (tax_id) REFERENCES public.taxes(id),
  CONSTRAINT purchases_currency_id_fkey FOREIGN KEY (currency_id) REFERENCES public.currencies(id),
  CONSTRAINT purchases_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.admins(id)
);
CREATE TABLE public.reasons (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  ar_name text,
  type text NOT NULL,
  status boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT reasons_pkey PRIMARY KEY (id)
);
CREATE TABLE public.revenue_categories (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  ar_name text,
  status boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  description text,
  color character varying DEFAULT '#666666'::character varying,
  CONSTRAINT revenue_categories_pkey PRIMARY KEY (id)
);
CREATE TABLE public.revenues (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  amount numeric NOT NULL,
  category_id uuid,
  bank_account_id uuid NOT NULL,
  note text,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT revenues_pkey PRIMARY KEY (id),
  CONSTRAINT revenues_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.revenue_categories(id),
  CONSTRAINT revenues_bank_account_id_fkey FOREIGN KEY (bank_account_id) REFERENCES public.bank_accounts(id),
  CONSTRAINT revenues_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.admins(id),
  CONSTRAINT fk_revenue_category FOREIGN KEY (category_id) REFERENCES public.revenue_categories(id)
);
CREATE TABLE public.role_permissions (
  role_id uuid NOT NULL,
  permission_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT role_permissions_pkey PRIMARY KEY (role_id, permission_id),
  CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id),
  CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permissions(id)
);
CREATE TABLE public.roles (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL UNIQUE,
  ar_name text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  permissions jsonb DEFAULT '[]'::jsonb,
  status boolean DEFAULT true,
  description text,
  CONSTRAINT roles_pkey PRIMARY KEY (id)
);
CREATE TABLE public.sale_item_attributes (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  sale_item_id uuid NOT NULL,
  attribute_type_id uuid NOT NULL,
  attribute_value_id uuid NOT NULL,
  attribute_type_name character varying NOT NULL,
  attribute_type_ar_name character varying NOT NULL,
  attribute_value_name character varying NOT NULL,
  attribute_value_ar_name character varying NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT sale_item_attributes_pkey PRIMARY KEY (id),
  CONSTRAINT sale_item_attributes_sale_item_id_fkey FOREIGN KEY (sale_item_id) REFERENCES public.sale_items(id),
  CONSTRAINT sale_item_attributes_attribute_type_id_fkey FOREIGN KEY (attribute_type_id) REFERENCES public.attribute_types(id),
  CONSTRAINT sale_item_attributes_attribute_value_id_fkey FOREIGN KEY (attribute_value_id) REFERENCES public.attribute_values(id)
);
CREATE TABLE public.sale_items (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  sale_id uuid NOT NULL,
  product_id uuid NOT NULL,
  quantity integer NOT NULL,
  price numeric NOT NULL,
  whole_price numeric,
  subtotal numeric NOT NULL,
  is_bundle boolean DEFAULT false,
  bundle_id uuid,
  CONSTRAINT sale_items_pkey PRIMARY KEY (id),
  CONSTRAINT sale_items_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id),
  CONSTRAINT sale_items_bundle_id_fkey FOREIGN KEY (bundle_id) REFERENCES public.bundles(id),
  CONSTRAINT sale_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);
CREATE TABLE public.sale_payments (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  sale_id uuid NOT NULL,
  payment_method_id uuid NOT NULL,
  bank_account_id uuid NOT NULL,
  amount numeric NOT NULL,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  currency_id uuid,
  CONSTRAINT sale_payments_pkey PRIMARY KEY (id),
  CONSTRAINT sale_payments_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id),
  CONSTRAINT sale_payments_payment_method_id_fkey FOREIGN KEY (payment_method_id) REFERENCES public.payment_methods(id),
  CONSTRAINT sale_payments_bank_account_id_fkey FOREIGN KEY (bank_account_id) REFERENCES public.bank_accounts(id),
  CONSTRAINT sale_payments_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.admins(id),
  CONSTRAINT sale_payments_currency_id_fkey FOREIGN KEY (currency_id) REFERENCES public.currencies(id)
);
CREATE TABLE public.sale_return_items (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  return_id uuid NOT NULL,
  product_id uuid NOT NULL,
  sale_item_id uuid,
  original_quantity integer NOT NULL,
  returned_quantity integer NOT NULL,
  price numeric NOT NULL,
  subtotal numeric NOT NULL,
  reason text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT sale_return_items_pkey PRIMARY KEY (id),
  CONSTRAINT sale_return_items_return_id_fkey FOREIGN KEY (return_id) REFERENCES public.sale_returns(id),
  CONSTRAINT sale_return_items_sale_item_id_fkey FOREIGN KEY (sale_item_id) REFERENCES public.sale_items(id),
  CONSTRAINT sale_return_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);
CREATE TABLE public.sale_returns (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  sale_id uuid NOT NULL,
  reference text NOT NULL UNIQUE,
  customer_id uuid,
  warehouse_id uuid,
  total_amount numeric NOT NULL,
  refund_method text DEFAULT 'cash'::text,
  note text,
  status text DEFAULT 'completed'::text CHECK (status = ANY (ARRAY['pending'::text, 'completed'::text, 'cancelled'::text])),
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT sale_returns_pkey PRIMARY KEY (id),
  CONSTRAINT sale_returns_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id),
  CONSTRAINT sale_returns_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id),
  CONSTRAINT sale_returns_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id),
  CONSTRAINT sale_returns_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.admins(id)
);
CREATE TABLE public.sales (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  reference text NOT NULL UNIQUE,
  date date NOT NULL,
  customer_id uuid,
  warehouse_id uuid NOT NULL,
  shift_id uuid,
  cashier_id uuid,
  tax_id uuid,
  discount_id uuid,
  coupon_id uuid,
  tax_amount numeric DEFAULT 0,
  discount_amount numeric DEFAULT 0,
  grand_total numeric NOT NULL DEFAULT 0,
  paid_amount numeric DEFAULT 0,
  remaining_amount numeric DEFAULT 0,
  sale_status text DEFAULT 'completed'::text,
  is_pending boolean DEFAULT false,
  is_due boolean DEFAULT false,
  notes text,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  currency_id uuid,
  CONSTRAINT sales_pkey PRIMARY KEY (id),
  CONSTRAINT sales_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id),
  CONSTRAINT sales_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id),
  CONSTRAINT sales_shift_id_fkey FOREIGN KEY (shift_id) REFERENCES public.shifts(id),
  CONSTRAINT sales_cashier_id_fkey FOREIGN KEY (cashier_id) REFERENCES public.cashiers(id),
  CONSTRAINT sales_tax_id_fkey FOREIGN KEY (tax_id) REFERENCES public.taxes(id),
  CONSTRAINT sales_discount_id_fkey FOREIGN KEY (discount_id) REFERENCES public.discounts(id),
  CONSTRAINT sales_coupon_id_fkey FOREIGN KEY (coupon_id) REFERENCES public.coupons(id),
  CONSTRAINT sales_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.admins(id),
  CONSTRAINT sales_currency_id_fkey FOREIGN KEY (currency_id) REFERENCES public.currencies(id)
);
CREATE TABLE public.shifts (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  cashier_id uuid NOT NULL,
  cashierman_id uuid,
  bank_account_id uuid,
  start_time timestamp with time zone NOT NULL,
  end_time timestamp with time zone,
  status text DEFAULT 'open'::text,
  total_sale_amount numeric DEFAULT 0,
  net_cash_in_drawer numeric DEFAULT 0,
  total_expenses numeric DEFAULT 0,
  opening_balance numeric DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  currency_id uuid,
  CONSTRAINT shifts_pkey PRIMARY KEY (id),
  CONSTRAINT shifts_cashier_id_fkey FOREIGN KEY (cashier_id) REFERENCES public.cashiers(id),
  CONSTRAINT shifts_cashierman_id_fkey FOREIGN KEY (cashierman_id) REFERENCES public.admins(id),
  CONSTRAINT shifts_bank_account_id_fkey FOREIGN KEY (bank_account_id) REFERENCES public.bank_accounts(id),
  CONSTRAINT shifts_currency_id_fkey FOREIGN KEY (currency_id) REFERENCES public.currencies(id)
);
CREATE TABLE public.suppliers (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  username text NOT NULL,
  email text,
  phone_number text,
  address text,
  company_name text,
  image text,
  city_id uuid,
  country_id uuid,
  status boolean DEFAULT true,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT suppliers_pkey PRIMARY KEY (id),
  CONSTRAINT suppliers_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.cities(id),
  CONSTRAINT suppliers_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.countries(id),
  CONSTRAINT suppliers_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.admins(id)
);
CREATE TABLE public.taxes (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  ar_name text,
  amount numeric NOT NULL DEFAULT 0,
  type text NOT NULL DEFAULT 'fixed'::text,
  status boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT taxes_pkey PRIMARY KEY (id)
);
CREATE TABLE public.transfer_items (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  transfer_id uuid,
  product_id uuid,
  quantity integer NOT NULL CHECK (quantity > 0),
  received_quantity integer DEFAULT 0,
  status character varying DEFAULT 'pending'::character varying CHECK (status::text = ANY (ARRAY['pending'::character varying, 'received'::character varying, 'partial'::character varying, 'rejected'::character varying]::text[])),
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT transfer_items_pkey PRIMARY KEY (id),
  CONSTRAINT transfer_items_transfer_id_fkey FOREIGN KEY (transfer_id) REFERENCES public.transfers(id),
  CONSTRAINT transfer_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);
CREATE TABLE public.transfer_products (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  transfer_id uuid NOT NULL,
  product_id uuid NOT NULL,
  quantity integer NOT NULL,
  CONSTRAINT transfer_products_pkey PRIMARY KEY (id),
  CONSTRAINT transfer_products_transfer_id_fkey FOREIGN KEY (transfer_id) REFERENCES public.transfers(id),
  CONSTRAINT transfer_products_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);
CREATE TABLE public.transfers (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  reference text NOT NULL UNIQUE,
  from_warehouse_id uuid NOT NULL,
  to_warehouse_id uuid NOT NULL,
  status text NOT NULL DEFAULT 'pending'::text,
  date date NOT NULL,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT transfers_pkey PRIMARY KEY (id),
  CONSTRAINT transfers_from_warehouse_id_fkey FOREIGN KEY (from_warehouse_id) REFERENCES public.warehouses(id),
  CONSTRAINT transfers_to_warehouse_id_fkey FOREIGN KEY (to_warehouse_id) REFERENCES public.warehouses(id),
  CONSTRAINT transfers_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.admins(id)
);
CREATE TABLE public.units (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  ar_name text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  status boolean NOT NULL DEFAULT true,
  code character varying,
  CONSTRAINT units_pkey PRIMARY KEY (id)
);
CREATE TABLE public.user_profiles (
  id uuid NOT NULL,
  username character varying,
  full_name character varying,
  phone character varying,
  avatar_url text,
  role character varying DEFAULT 'user'::character varying,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  role_id uuid,
  warehouse_id uuid,
  is_active boolean DEFAULT true,
  CONSTRAINT user_profiles_pkey PRIMARY KEY (id),
  CONSTRAINT user_profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id),
  CONSTRAINT user_profiles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id),
  CONSTRAINT user_profiles_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id)
);
CREATE TABLE public.users (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  email text NOT NULL UNIQUE,
  full_name text,
  phone text,
  role_id uuid,
  warehouse_id uuid,
  status boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT users_pkey PRIMARY KEY (id),
  CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id),
  CONSTRAINT users_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id)
);
CREATE TABLE public.variation_options (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  variation_id uuid NOT NULL,
  name text NOT NULL,
  ar_name text,
  status boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT variation_options_pkey PRIMARY KEY (id),
  CONSTRAINT variation_options_variation_id_fkey FOREIGN KEY (variation_id) REFERENCES public.variations(id)
);
CREATE TABLE public.variations (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  ar_name text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT variations_pkey PRIMARY KEY (id)
);
CREATE TABLE public.warehouse_products (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  warehouse_id uuid,
  product_id uuid,
  quantity integer DEFAULT 0,
  low_stock integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT warehouse_products_pkey PRIMARY KEY (id),
  CONSTRAINT warehouse_products_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id),
  CONSTRAINT warehouse_products_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);
CREATE TABLE public.warehouses (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  ar_name text,
  address text,
  phone text,
  email text,
  is_online boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  currency_id uuid,
  CONSTRAINT warehouses_pkey PRIMARY KEY (id),
  CONSTRAINT warehouses_currency_id_fkey FOREIGN KEY (currency_id) REFERENCES public.currencies(id)
);
CREATE TABLE public.zones (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  ar_name text,
  city_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT zones_pkey PRIMARY KEY (id),
  CONSTRAINT zones_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.cities(id)
);