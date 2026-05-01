-- Supabase Migration: Financial Tables (Phase 6)

-- ============================================
-- BANK ACCOUNTS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS bank_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    account_number VARCHAR(100),
    bank_name VARCHAR(200),
    branch VARCHAR(200),
    
    -- Account details
    account_type VARCHAR(50) DEFAULT 'checking' CHECK (account_type IN ('checking', 'savings', 'cash', 'credit')),
    currency VARCHAR(10) DEFAULT 'SAR',
    
    -- Financial
    opening_balance DECIMAL(12,2) DEFAULT 0,
    current_balance DECIMAL(12,2) DEFAULT 0,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    is_default BOOLEAN DEFAULT FALSE,
    
    -- Notes
    notes TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES user_profiles(id)
);

-- ============================================
-- EXPENSES TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference VARCHAR(100) UNIQUE,
    
    -- Relations
    category_id UUID, -- Will create expense_categories table
    bank_account_id UUID REFERENCES bank_accounts(id) ON DELETE RESTRICT,
    shift_id UUID, -- Optional shift reference
    
    -- Financial details
    amount DECIMAL(12,2) NOT NULL,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    
    -- Expense details
    description TEXT NOT NULL,
    receipt_number VARCHAR(100),
    receipt_image TEXT,
    
    -- Status
    status VARCHAR(20) DEFAULT 'approved' CHECK (status IN ('pending', 'approved', 'rejected')),
    
    -- Approval
    approved_by UUID REFERENCES user_profiles(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES user_profiles(id)
);

-- ============================================
-- EXPENSE CATEGORIES TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS expense_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    color VARCHAR(20) DEFAULT '#666666',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add FK to expenses
ALTER TABLE expenses 
    ADD CONSTRAINT fk_expense_category 
    FOREIGN KEY (category_id) 
    REFERENCES expense_categories(id) 
    ON DELETE SET NULL;

-- ============================================
-- REVENUES TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS revenues (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference VARCHAR(100) UNIQUE,
    
    -- Relations
    category_id UUID, -- Will create revenue_categories table
    bank_account_id UUID REFERENCES bank_accounts(id) ON DELETE RESTRICT,
    shift_id UUID, -- Optional shift reference
    
    -- Financial details
    amount DECIMAL(12,2) NOT NULL,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    
    -- Revenue details
    description TEXT NOT NULL,
    receipt_number VARCHAR(100),
    receipt_image TEXT,
    
    -- Status
    status VARCHAR(20) DEFAULT 'approved' CHECK (status IN ('pending', 'approved', 'rejected')),
    
    -- Approval
    approved_by UUID REFERENCES user_profiles(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES user_profiles(id)
);

-- ============================================
-- REVENUE CATEGORIES TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS revenue_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    color VARCHAR(20) DEFAULT '#666666',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add FK to revenues
ALTER TABLE revenues 
    ADD CONSTRAINT fk_revenue_category 
    FOREIGN KEY (category_id) 
    REFERENCES revenue_categories(id) 
    ON DELETE SET NULL;

-- ============================================
-- FINANCIAL TRANSACTIONS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS financial_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference VARCHAR(100) UNIQUE,
    
    -- Transaction type
    transaction_type VARCHAR(50) NOT NULL CHECK (transaction_type IN (
        'expense', 'revenue', 'sale_payment', 'purchase_payment', 
        'transfer', 'adjustment', 'refund'
    )),
    
    -- Related entity
    related_id UUID, -- Generic reference to sale, purchase, expense, etc.
    related_type VARCHAR(50), -- 'sale', 'purchase', 'expense', 'revenue'
    
    -- Bank account
    bank_account_id UUID REFERENCES bank_accounts(id) ON DELETE RESTRICT,
    
    -- Financial
    amount DECIMAL(12,2) NOT NULL,
    previous_balance DECIMAL(12,2) NOT NULL,
    new_balance DECIMAL(12,2) NOT NULL,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    
    -- Details
    description TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES user_profiles(id)
);

-- ============================================
-- SHIFTS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS shifts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference VARCHAR(100) UNIQUE,
    
    -- Cashier and management
    cashier_id UUID REFERENCES user_profiles(id) ON DELETE RESTRICT,
    cashier_man_id UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    
    -- Shift times
    start_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    end_time TIMESTAMP WITH TIME ZONE,
    
    -- Opening amounts
    opening_amount DECIMAL(12,2) DEFAULT 0,
    
    -- Closing amounts (calculated)
    expected_amount DECIMAL(12,2) DEFAULT 0,
    actual_amount DECIMAL(12,2),
    difference DECIMAL(12,2),
    
    -- Sales summary
    total_sales DECIMAL(12,2) DEFAULT 0,
    total_returns DECIMAL(12,2) DEFAULT 0,
    total_discounts DECIMAL(12,2) DEFAULT 0,
    
    -- Expenses during shift
    total_expenses DECIMAL(12,2) DEFAULT 0,
    
    -- Status
    status VARCHAR(20) DEFAULT 'open' CHECK (status IN ('open', 'closed', 'approved')),
    
    -- Notes
    opening_note TEXT,
    closing_note TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- RLS POLICIES FOR FINANCIAL TABLES
-- ============================================

ALTER TABLE bank_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE expense_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE revenues ENABLE ROW LEVEL SECURITY;
ALTER TABLE revenue_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE financial_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE shifts ENABLE ROW LEVEL SECURITY;

-- Bank Accounts policies
CREATE POLICY "Authenticated users can view bank accounts" ON bank_accounts
    FOR SELECT TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager', 'cashier'))
    );

CREATE POLICY "Admins can manage bank accounts" ON bank_accounts
    FOR ALL TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

-- Expenses policies
CREATE POLICY "Authenticated users can view expenses" ON expenses
    FOR SELECT TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

CREATE POLICY "Cashiers can create expenses" ON expenses
    FOR INSERT TO authenticated WITH CHECK (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager', 'cashier'))
    );

CREATE POLICY "Managers can approve expenses" ON expenses
    FOR UPDATE TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

-- Expense Categories policies
CREATE POLICY "Authenticated users can view expense categories" ON expense_categories
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Admins can manage expense categories" ON expense_categories
    FOR ALL TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

-- Revenues policies
CREATE POLICY "Authenticated users can view revenues" ON revenues
    FOR SELECT TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

CREATE POLICY "Managers can manage revenues" ON revenues
    FOR ALL TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

-- Revenue Categories policies
CREATE POLICY "Authenticated users can view revenue categories" ON revenue_categories
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Admins can manage revenue categories" ON revenue_categories
    FOR ALL TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

-- Financial Transactions policies
CREATE POLICY "Authenticated users can view financial transactions" ON financial_transactions
    FOR SELECT TO authenticated USING (
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

CREATE POLICY "System can create financial transactions" ON financial_transactions
    FOR INSERT TO authenticated WITH CHECK (true);

-- Shifts policies
CREATE POLICY "Cashiers can view their shifts" ON shifts
    FOR SELECT TO authenticated USING (
        cashier_id = auth.uid() OR 
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

CREATE POLICY "Cashiers can manage their shifts" ON shifts
    FOR ALL TO authenticated USING (
        (cashier_id = auth.uid() AND status = 'open') OR 
        EXISTS (SELECT 1 FROM user_profiles WHERE id = auth.uid() AND role IN ('admin', 'manager'))
    );

-- ============================================
-- SEED DATA
-- ============================================

-- Ensure expense_categories columns exist (for reruns)
ALTER TABLE expense_categories ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE expense_categories ADD COLUMN IF NOT EXISTS color VARCHAR(20) DEFAULT '#666666';

-- Ensure revenue_categories columns exist (for reruns)
ALTER TABLE revenue_categories ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE revenue_categories ADD COLUMN IF NOT EXISTS color VARCHAR(20) DEFAULT '#666666';

-- Default expense categories
INSERT INTO expense_categories (name, description, color) VALUES
    ('Utilities', 'Electricity, water, internet', '#FF5722'),
    ('Rent', 'Office and warehouse rent', '#9C27B0'),
    ('Salaries', 'Employee salaries', '#2196F3'),
    ('Maintenance', 'Equipment maintenance', '#4CAF50'),
    ('Marketing', 'Advertising and promotions', '#FF9800'),
    ('Transportation', 'Shipping and delivery', '#795548'),
    ('Miscellaneous', 'Other expenses', '#607D8B')
ON CONFLICT DO NOTHING;

-- Default revenue categories
INSERT INTO revenue_categories (name, description, color) VALUES
    ('Sales', 'Product sales revenue', '#4CAF50'),
    ('Services', 'Service revenue', '#2196F3'),
    ('Investments', 'Investment returns', '#9C27B0'),
    ('Other', 'Other revenue sources', '#607D8B')
ON CONFLICT DO NOTHING;

-- Default bank accounts
INSERT INTO bank_accounts (name, account_type, is_default, is_active) VALUES
    ('Cash Account', 'cash', TRUE, TRUE),
    ('Main Bank Account', 'checking', FALSE, TRUE)
ON CONFLICT DO NOTHING;

-- ============================================
-- TRIGGERS
-- ============================================

CREATE TRIGGER update_bank_accounts_updated_at BEFORE UPDATE ON bank_accounts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_expenses_updated_at BEFORE UPDATE ON expenses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_expense_categories_updated_at BEFORE UPDATE ON expense_categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_revenues_updated_at BEFORE UPDATE ON revenues
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_revenue_categories_updated_at BEFORE UPDATE ON revenue_categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_shifts_updated_at BEFORE UPDATE ON shifts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
