# Design Document: Product Attributes

## Overview

The Product Attributes system enables products to have selectable variations (such as colors, sizes, materials) that do not affect pricing. This feature provides customers with choice while maintaining price consistency across attribute combinations. The system is designed to be mutually exclusive with the existing Price Variation system and integrates across the Products module, Bundles module, and Point of Sale (POS) system.

### Key Design Principles

1. **Separation of Concerns**: Attributes are purely for selection; pricing remains independent
2. **Mutual Exclusivity**: Products cannot use both Attributes and Price Variations simultaneously
3. **Bilingual Support**: All attribute names and values support English and Arabic
4. **Backward Compatibility**: Existing products without attributes continue to function normally
5. **Consistent Data Model**: Unified attribute structure across Products, Bundles, and POS

### System Context

The Product Attributes system operates within the existing SysteGo architecture:
- **Backend**: Supabase PostgreSQL database with REST API
- **Frontend**: Flutter application with BLoC/Cubit state management
- **Data Access**: Generic SupabaseService for CRUD operations
- **Localization**: Existing Localizable interface for bilingual support

## Database Schema

### Tables

**attribute_types**
```sql
CREATE TABLE attribute_types (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,
  ar_name TEXT NOT NULL,
  status BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

**attribute_values**
```sql
CREATE TABLE attribute_values (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  attribute_type_id UUID NOT NULL REFERENCES attribute_types(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  ar_name TEXT NOT NULL,
  status BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(attribute_type_id, name)
);
```

**product_attributes**
```sql
CREATE TABLE product_attributes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  attribute_type_id UUID NOT NULL REFERENCES attribute_types(id) ON DELETE CASCADE,
  attribute_value_ids UUID[] NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(product_id, attribute_type_id)
);
```

**order_item_attributes**
```sql
CREATE TABLE order_item_attributes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_item_id UUID NOT NULL,
  attribute_type_id UUID NOT NULL REFERENCES attribute_types(id),
  attribute_value_id UUID NOT NULL REFERENCES attribute_values(id),
  attribute_type_name TEXT NOT NULL,
  attribute_type_ar_name TEXT NOT NULL,
  attribute_value_name TEXT NOT NULL,
  attribute_value_ar_name TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);
```

## Data Models

### AttributeType Model
```dart
class AttributeType implements Localizable {
  final String id;
  final String name;
  final String arName;
  final bool status;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### AttributeValue Model
```dart
class AttributeValue implements Localizable {
  final String id;
  final String attributeTypeId;
  final String name;
  final String arName;
  final bool status;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### ProductAttribute Model
```dart
class ProductAttribute {
  final String id;
  final String productId;
  final AttributeType attributeType;
  final List<AttributeValue> availableValues;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### SelectedAttribute Model
```dart
class SelectedAttribute {
  final String attributeTypeId;
  final String attributeTypeName;
  final String attributeTypeArName;
  final String attributeValueId;
  final String attributeValueName;
  final String attributeValueArName;
}
```

## API Endpoints

### Attribute Types
- `GET /rest/v1/attribute_types` - List all attribute types
- `POST /rest/v1/attribute_types` - Create new attribute type
- `PUT /rest/v1/attribute_types?id=eq.{id}` - Update attribute type
- `DELETE /rest/v1/attribute_types?id=eq.{id}` - Delete attribute type

### Attribute Values
- `GET /rest/v1/attribute_values?attribute_type_id=eq.{typeId}` - List values for type
- `POST /rest/v1/attribute_values` - Create new attribute value
- `PUT /rest/v1/attribute_values?id=eq.{id}` - Update attribute value
- `DELETE /rest/v1/attribute_values?id=eq.{id}` - Delete attribute value

### Product Attributes
- `GET /rest/v1/product_attributes?product_id=eq.{productId}` - Get product attributes
- `POST /rest/v1/product_attributes` - Assign attribute to product
- `PUT /rest/v1/product_attributes?id=eq.{id}` - Update product attribute
- `DELETE /rest/v1/product_attributes?id=eq.{id}` - Remove attribute from product

## UI Components

### Admin Panel
1. **AttributeTypeManagementScreen** - Manage attribute types
2. **AttributeValueManagementScreen** - Manage attribute values
3. **ProductAttributeAssignmentWidget** - Assign attributes to products

### POS
1. **AttributeSelectionDialog** - Select attributes when adding product to cart
2. **BundleAttributeSelectionDialog** - Select attributes for bundle products
3. **CartItemAttributeDisplay** - Display selected attributes in cart

## Integration Points

### Products Module
- Add `attributes` field to Product model
- Update product edit screen to include attribute assignment
- Validate mutual exclusivity with price variations

### Bundles Module
- Load attributes for products within bundles
- Handle attribute selection for each product in bundle

### POS Module
- Check `product.hasAttributes` before adding to cart
- Show attribute selection dialog when needed
- Track selected attributes in CartItem
- Compare attributes when checking for duplicate cart items

### Checkout
- Include selected attributes in order data
- Save to `order_item_attributes` table for historical record

## Testing Strategy

- Unit tests for all models
- Integration tests for database operations
- Widget tests for UI components
- End-to-end tests for complete workflows
- Property-based testing NOT recommended (UI-heavy feature)
