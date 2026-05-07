-- Supabase Migration: Product Attributes Feature
-- Created for SysteGo ERP System
-- This script creates tables for the Product Attributes feature
-- Enables products to have selectable variations (colors, sizes, materials) without affecting pricing

-- ============================================
-- PRODUCT ATTRIBUTES TABLES
-- ============================================

-- Attribute Types: Define attribute categories (e.g., Color, Size, Material)
CREATE TABLE IF NOT EXISTS attribute_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    status BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE attribute_types IS 'Defines attribute categories like Color, Size, Material';
COMMENT ON COLUMN attribute_types.name IS 'Attribute type name (unique across system)';
COMMENT ON COLUMN attribute_types.status IS 'Active/Inactive flag';

-- Attribute Values: Define options for each attribute type (e.g., Red, Blue for Color)
CREATE TABLE IF NOT EXISTS attribute_values (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    attribute_type_id UUID NOT NULL REFERENCES attribute_types(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    status BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(attribute_type_id, name)
);

COMMENT ON TABLE attribute_values IS 'Defines values/options for each attribute type';
COMMENT ON COLUMN attribute_values.attribute_type_id IS 'Reference to parent attribute type';
COMMENT ON COLUMN attribute_values.name IS 'Attribute value name (unique within type)';

-- Product Attributes: Links products to their available attribute types and values
CREATE TABLE IF NOT EXISTS product_attributes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    attribute_type_id UUID NOT NULL REFERENCES attribute_types(id) ON DELETE CASCADE,
    attribute_value_ids UUID[] NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(product_id, attribute_type_id)
);

COMMENT ON TABLE product_attributes IS 'Links products to their available attributes and values';
COMMENT ON COLUMN product_attributes.product_id IS 'Reference to product';
COMMENT ON COLUMN product_attributes.attribute_type_id IS 'Reference to attribute type';
COMMENT ON COLUMN product_attributes.attribute_value_ids IS 'Array of available value IDs for this product';

-- Sale Item Attributes: Tracks selected attributes for each sale item (historical record)
CREATE TABLE IF NOT EXISTS sale_item_attributes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sale_item_id UUID NOT NULL REFERENCES sale_items(id) ON DELETE CASCADE,
    attribute_type_id UUID NOT NULL REFERENCES attribute_types(id),
    attribute_value_id UUID NOT NULL REFERENCES attribute_values(id),
    attribute_type_name VARCHAR(100) NOT NULL,
    attribute_value_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE sale_item_attributes IS 'Stores selected attributes for each sale item (denormalized for historical accuracy)';
COMMENT ON COLUMN sale_item_attributes.sale_item_id IS 'Reference to sale item';
COMMENT ON COLUMN sale_item_attributes.attribute_type_name IS 'Denormalized type name (historical snapshot)';
COMMENT ON COLUMN sale_item_attributes.attribute_value_name IS 'Denormalized value name (historical snapshot)';

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

-- Index for fetching values by attribute type
CREATE INDEX IF NOT EXISTS idx_attribute_values_type_id ON attribute_values(attribute_type_id);

-- Index for fetching attributes by product
CREATE INDEX IF NOT EXISTS idx_product_attributes_product_id ON product_attributes(product_id);

-- Index for fetching sale item attributes
CREATE INDEX IF NOT EXISTS idx_sale_item_attributes_sale_item_id ON sale_item_attributes(sale_item_id);

-- Index for reporting by attribute type
CREATE INDEX IF NOT EXISTS idx_sale_item_attributes_type_id ON sale_item_attributes(attribute_type_id);

-- ============================================
-- TRIGGERS FOR UPDATED_AT
-- ============================================

-- Apply updated_at trigger to new tables
CREATE TRIGGER update_attribute_types_updated_at BEFORE UPDATE ON attribute_types
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_attribute_values_updated_at BEFORE UPDATE ON attribute_values
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_product_attributes_updated_at BEFORE UPDATE ON product_attributes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- VALIDATION FUNCTION: Prevent attributes on products with different_price
-- ============================================

CREATE OR REPLACE FUNCTION check_product_attributes_eligibility()
RETURNS TRIGGER AS $$
DECLARE
    product_has_different_price BOOLEAN;
BEGIN
    -- Check if product has different_price enabled
    SELECT different_price INTO product_has_different_price
    FROM products
    WHERE id = NEW.product_id;

    IF product_has_different_price THEN
        RAISE EXCEPTION 'Cannot add attributes to product with different_price enabled';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply validation trigger
CREATE TRIGGER validate_product_attributes_eligibility
    BEFORE INSERT OR UPDATE ON product_attributes
    FOR EACH ROW
    EXECUTE FUNCTION check_product_attributes_eligibility();

-- ============================================
-- ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================

ALTER TABLE attribute_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE attribute_values ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_attributes ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_item_attributes ENABLE ROW LEVEL SECURITY;

-- Note: RLS policies should be defined in 002_rls_policies.sql
-- Basic policies will allow authenticated users full access

-- ============================================
-- GRANTS FOR SERVICE ROLE
-- ============================================

GRANT ALL ON attribute_types TO service_role;
GRANT ALL ON attribute_values TO service_role;
GRANT ALL ON product_attributes TO service_role;
GRANT ALL ON sale_item_attributes TO service_role;

-- ============================================
-- SEED DATA (Optional)
-- ============================================

-- Insert common attribute types (uncomment if needed)
-- INSERT INTO attribute_types (name) VALUES
--     ('Color'),
--     ('Size'),
--     ('Material');
