# Implementation Plan: Product Attributes

## Overview

This implementation plan breaks down the Product Attributes feature into discrete coding tasks. The feature enables products to have selectable variations (colors, sizes, materials) that don't affect pricing. Implementation follows a bottom-up approach: database schema → backend API → data models → admin UI → POS integration → testing.

## Tasks

- [x] 1. Set up database schema and constraints (supabase/migrations/004_product_attributes.sql)
  - [x] Create `attribute_types` table (id, name, ar_name, status, created_at, updated_at)
  - [x] Create `attribute_values` table (id, attribute_type_id, name, ar_name, status, created_at, updated_at)
  - [x] Create `product_attributes` table (id, product_id, attribute_type_id, attribute_value_ids UUID[], created_at, updated_at)
  - [x] Create `sale_item_attributes` table (sale_item_id, attribute_type_id, attribute_value_id, denormalized names)
  - [x] Add constraint: products with `different_price = true` cannot have attributes (validation trigger)
  - [x] Create triggers for automatic `updated_at` timestamp updates
  - [x] Add indexes for performance optimization
  - [x] Add RLS policies for all tables (supabase/migrations/002_rls_policies.sql)
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 2.5, 6.7_

- [x] 2. Create data models for attributes
  - [x] 2.1 Implement `AttributeType` model (lib/features/admin/product/models/attribute_type_model.dart)
    - Add `fromJson()` and `toJson()` methods with snake_case/camelCase mapping
    - Implement bilingual name support (name, arName)
    - Add status field for active/inactive
    - Add `getLocalizedName()` helper
    - _Requirements: 1.1, 1.2_
  
  - [x] 2.2 Implement `AttributeValue` model (lib/features/admin/product/models/attribute_value_model.dart)
    - Add `fromJson()` and `toJson()` methods
    - Link to parent attribute type via `attributeTypeId`
    - Implement bilingual name support
    - Add `getLocalizedName()` helper
    - _Requirements: 1.3, 1.4_
  
  - [x] 2.3 Implement `ProductAttribute` model (lib/features/admin/product/models/product_attribute_model.dart)
    - Link product to attribute type
    - Store list of available attribute values (attributeValueIds)
    - Support nested loading of attributeType and availableValues
    - Add `fromJson()` and `toJson()` methods
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  
  - [x] 2.4 Implement `SelectedAttribute` model (lib/features/admin/product/models/selected_attribute_model.dart)
    - Store selected attribute type and value information
    - Denormalize names (typeName, typeArName, valueName, valueArName) for historical accuracy
    - Implement equality operator for cart item comparison
    - Add `CartItemAttributes` helper for comparing cart items
    - Add `fromJson()` and `toJson()` methods
    - _Requirements: 4.1, 4.2, 4.5_
  
  - [x] 2.5 Implement `SaleItemAttribute` model (lib/features/admin/product/models/sale_item_attribute_model.dart)
    - Historical record model for database storage
    - All denormalized fields for sale_item_attributes table
    - Batch insert helper for checkout flow
    - _Requirements: 4.5, 6.7, 10.1_

- [x] 3. Update existing Product and CartItem models
  - [x] 3.1 Add `attributes` field to Product model (lib/features/admin/product/models/product_model.dart)
    - Add `List<ProductAttribute> attributes` field
    - Update `fromJson()` to parse nested attributes from 'attributes' key
    - Update `toJson()` to serialize attributes
    - Add `hasAttributes` getter
    - _Requirements: 2.1, 2.2, 6.4_
  
  - [x] 3.2 Add attribute tracking to CartItem model (lib/features/pos/checkout/model/checkout_models.dart)
    - Add `List<SelectedAttribute> selectedAttributes` field for regular products
    - Add `Map<String, List<SelectedAttribute>> bundleProductAttributes` for bundle products
    - Add `hasSelectedAttributes` and `hasBundleAttributes` getters
    - Implement `isSameAs()` method comparing attributes (uses CartItemAttributes helper)
    - Add `getAttributesDisplay()` for UI display
    - Add `selectedAttributesToJson()` for storage
    - Add `CartItem.withAttributes()` factory for restoring from storage
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 5.4_

- [x] 4. Implement SupabaseService methods for attributes (lib/features/admin/product/data/repositories/attribute_repository.dart)
  - [x] 4.1 Add method to fetch all attribute types
    - Query with status filter and ordering
    - Handle error responses
    - _Requirements: 1.1, 6.1_
  
  - [x] 4.2 Add method to create attribute type
    - Validate unique name (via DB constraint)
    - Handle error responses
    - _Requirements: 1.2, 6.2_
  
  - [x] 4.3 Add method to update attribute type
    - Handle partial updates
    - _Requirements: 1.2, 6.3_
  
  - [x] 4.4 Add method to delete attribute type
    - Handle cascade to values (via DB CASCADE DELETE)
    - _Requirements: 1.2, 6.4_
  
  - [x] 4.5 Add methods for attribute values (AttributeValueRepository)
    - Fetch values by type
    - Create/update/delete values
    - _Requirements: 1.3, 1.4, 6.5, 6.6_
  
  - [x] 4.6 Add methods for product attributes (ProductAttributeRepository)
    - Fetch attributes by product with nested loading
    - Assign attributes to product
    - Update/remove product attributes
    - Remove all attributes by product
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 5. Implement SupabaseService methods for sale item attributes (lib/features/admin/product/data/repositories/attribute_repository.dart)
  - [x] 5.1 Add method to save selected attributes for sale items
    - Batch insert sale_item_attributes records
    - Denormalize attribute names for historical record (attribute_type_name, attribute_type_ar_name, attribute_value_name, attribute_value_ar_name)
    - _Requirements: 4.5, 6.7, 10.1_

  - [x] 5.2 Add method to fetch sale item attributes
    - Query by sale_item_id
    - Used for order history and reporting
    - _Requirements: 10.1, 10.2_

- [x] 8. Create AttributeTypeCubit for state management (lib/features/admin/product/cubit/attribute_type_cubit/)
  - [x] 8.1 Implement state classes (Initial, Loading, Loaded, Error)
    - Define state hierarchy
    - Include data and error messages in states
    - _Requirements: 1.1_
  
  - [x] 8.2 Implement loadAttributeTypes method
    - Fetch from repository
    - Emit Loading → Loaded/Error states
    - _Requirements: 1.1, 6.1_
  
  - [x] 8.3 Implement createAttributeType method
    - Call repository method
    - Handle validation errors
    - Reload list on success
    - _Requirements: 1.1, 1.2, 1.5, 6.1_
  
  - [x] 8.4 Implement updateAttributeType method
    - Call repository method
    - Reload list on success
    - _Requirements: 1.1, 1.2, 6.1_
  
  - [x] 8.5 Implement deleteAttributeType method
    - Call repository method
    - Handle foreign key constraint errors
    - Reload list on success
    - _Requirements: 6.1_

- [x] 9. Create AttributeValueCubit for state management (lib/features/admin/product/cubit/attribute_value_cubit/)
  - [x] 9.1 Implement state classes (Initial, Loading, Loaded, Error)
    - Define state hierarchy
    - Include attribute type context
    - _Requirements: 1.3_
  
  - [x] 9.2 Implement loadAttributeValues method
    - Fetch values for specific attribute type
    - Emit Loading → Loaded/Error states
    - _Requirements: 1.3, 6.2_
  
  - [x] 9.3 Implement createAttributeValue method
    - Call repository method
    - Handle uniqueness validation
    - Reload list on success
    - _Requirements: 1.3, 1.4, 1.6, 6.2_
  
  - [x] 9.4 Implement updateAttributeValue method
    - Call repository method
    - Reload list on success
    - _Requirements: 1.3, 1.4, 6.2_
  
  - [x] 9.5 Implement deleteAttributeValue method
    - Call repository method
    - Reload list on success
    - _Requirements: 6.2_

- [x] 10. Create ProductAttributeCubit for state management (lib/features/admin/product/cubit/product_attribute_cubit/)
  - [x] 10.1 Implement state classes for product attribute management
    - Define states for loading, loaded, error
    - Include product context
    - _Requirements: 2.1_
  
  - [x] 10.2 Implement loadProductAttributes method
    - Fetch attributes for specific product
    - Include nested attribute types and values
    - _Requirements: 2.1, 2.2, 6.3, 6.4_
  
  - [x] 10.3 Implement assignAttributeToProduct method
    - Validate product doesn't have price variations
    - Call repository method
    - Handle constraint errors
    - Reload on success
    - _Requirements: 2.3, 2.4, 2.5, 2.7, 6.3, 6.6_
  
  - [x] 10.4 Implement updateProductAttribute method
    - Update available values for attribute
    - _Requirements: 2.4, 6.3_
  
  - [x] 10.5 Implement removeAttributeFromProduct method
    - Call repository method
    - Reload on success
    - _Requirements: 6.3_

- [x] 11. Build AttributeTypeManagementScreen for admin panel (lib/features/admin/product/presentation/)
  - [x] 11.1 Create screen layout with list view
    - Display attribute types in list
    - Show name, arName, and status
    - Add floating action button for creating new type
    - _Requirements: 1.1_
  
  - [x] 11.2 Implement create attribute type dialog (widgets/create_attribute_type_dialog.dart)
    - Form with name and arName fields
    - Validation for required fields
    - Call AttributeTypeCubit.createAttributeType
    - Display success/error messages
    - _Requirements: 1.1, 1.2, 1.5_
  
  - [x] 11.3 Implement edit attribute type dialog
    - Pre-populate form with existing data
    - Call AttributeTypeCubit.updateAttributeType
    - _Requirements: 1.1, 1.2_
  
  - [x] 11.4 Implement delete confirmation dialog (widgets/delete_attribute_type_dialog.dart)
    - Warn about cascade delete of values
    - Call AttributeTypeCubit.deleteAttributeType
    - _Requirements: 6.1_
  
  - [x] 11.5 Add status toggle functionality
    - Switch widget for active/inactive
    - Update via cubit
    - _Requirements: 1.1_

- [x] 12. Build AttributeValueManagementScreen for admin panel (lib/features/admin/product/presentation/)
  - [x] 12.1 Create screen layout with list view
    - Display values for selected attribute type
    - Show name, arName, and status
    - Add floating action button for creating new value
    - _Requirements: 1.3_
  
  - [x] 12.2 Implement create attribute value dialog (widgets/create_attribute_value_dialog.dart)
    - Form with name and arName fields
    - Validation for required fields and uniqueness
    - Call AttributeValueCubit.createAttributeValue
    - Display success/error messages
    - _Requirements: 1.3, 1.4, 1.6_
  
  - [x] 12.3 Implement edit attribute value dialog
    - Pre-populate form with existing data
    - Call AttributeValueCubit.updateAttributeValue
    - _Requirements: 1.3, 1.4_
  
  - [x] 12.4 Implement delete confirmation dialog (widgets/delete_attribute_value_dialog.dart)
    - Warn about removal from products
    - Call AttributeValueCubit.deleteAttributeValue
    - _Requirements: 6.2_
  
  - [x] 12.5 Add status toggle functionality
    - Switch widget for active/inactive
    - Update via cubit
    - _Requirements: 1.3_

- [ ] 13. Build ProductAttributeAssignmentWidget for product edit screen
  - [ ] 13.1 Create widget layout
    - Check product.differentPrice field
    - Display warning banner if price variations enabled
    - Show multi-select for attribute types
    - _Requirements: 2.1, 2.7_
  
  - [ ] 13.2 Implement attribute type selection
    - Multi-select dropdown for attribute types
    - Load available types from AttributeTypeCubit
    - _Requirements: 2.1, 2.2_
  
  - [ ] 13.3 Implement attribute value selection
    - For each selected type, show multi-select for values
    - Load values from AttributeValueCubit
    - _Requirements: 2.3, 2.4_
  
  - [ ] 13.4 Implement save functionality
    - Validate selections
    - Call ProductAttributeCubit.assignAttributeToProduct
    - Display success/error messages
    - _Requirements: 2.5, 6.3_
  
  - [ ] 13.5 Add remove attribute functionality
    - Button to remove attribute assignment
    - Confirmation dialog
    - _Requirements: 6.3_

- [ ] 14. Build AttributeSelectionDialog for POS
  - [ ] 14.1 Create dialog layout
    - Display product name and image
    - Show all attribute types for product
    - Add dropdown/button group for each attribute
    - _Requirements: 3.1, 3.2_
  
  - [ ] 14.2 Implement attribute value selection UI
    - Dropdown or button group for each attribute type
    - Display localized names
    - Track selections in local state
    - _Requirements: 3.2, 3.3_
  
  - [ ] 14.3 Implement validation logic
    - Disable "Add to Cart" until all attributes selected
    - Highlight missing selections
    - Display validation error messages
    - _Requirements: 3.3, 9.1, 9.2_
  
  - [ ] 14.4 Implement Add to Cart functionality
    - Create SelectedAttribute objects
    - Return selections to caller
    - Close dialog
    - _Requirements: 3.4, 4.1_

- [ ] 15. Build BundleAttributeSelectionDialog for POS
  - [ ] 15.1 Create dialog layout for bundle products
    - Display bundle name
    - Show each product in bundle
    - For products with attributes, show selection UI
    - _Requirements: 5.1, 5.2_
  
  - [ ] 15.2 Implement attribute selection for each product
    - Reuse attribute selection logic from AttributeSelectionDialog
    - Track selections per product
    - _Requirements: 5.2_
  
  - [ ] 15.3 Implement validation for bundle
    - Validate all required attributes across all products
    - Disable "Add Bundle to Cart" until complete
    - _Requirements: 5.2, 9.1_
  
  - [ ] 15.4 Implement Add Bundle to Cart functionality
    - Create map of productId → List<SelectedAttribute>
    - Return to caller
    - _Requirements: 5.4_

- [ ] 16. Build CartItemAttributeDisplay widget
  - [ ] 16.1 Create compact display widget
    - Show selected attributes below product name
    - Format: "Color: Red, Size: Large" (localized)
    - Handle both regular products and bundle products
    - _Requirements: 4.2, 5.5_
  
  - [ ] 16.2 Implement localization
    - Use current locale to display names
    - Switch between name and arName
    - _Requirements: 4.2_

- [ ] 17. Update POS product selection flow
  - [ ] 17.1 Modify product selection handler
    - Check product.hasAttributes
    - If true, show AttributeSelectionDialog
    - If false, add directly to cart
    - _Requirements: 3.1, 3.2, 8.1_
  
  - [ ] 17.2 Update bundle selection handler
    - Check if any products in bundle have attributes
    - If yes, show BundleAttributeSelectionDialog
    - If no, add bundle directly to cart
    - _Requirements: 5.1, 5.2_
  
  - [ ] 17.3 Update cart addition logic
    - Create CartItem with selectedAttributes
    - For bundles, include bundleProductAttributes map
    - _Requirements: 4.1, 5.4_

- [ ] 18. Update cart management logic
  - [ ] 18.1 Modify cart item comparison logic
    - Use CartItem.isSameAs() to compare items
    - Compare product ID and selected attributes
    - _Requirements: 4.3, 4.4_
  
  - [ ] 18.2 Update quantity increment logic
    - If identical item exists (same attributes), increment quantity
    - If different attributes, add as separate item
    - _Requirements: 4.4_
  
  - [ ] 18.3 Update cart display
    - Integrate CartItemAttributeDisplay widget
    - Show selected attributes for each item
    - _Requirements: 4.2_

- [ ] 19. Update checkout flow to save attribute selections
  - [ ] 19.1 Modify sale creation logic
    - Include selectedAttributes in sale item data
    - For bundles, include bundleProductAttributes
    - _Requirements: 4.5, 5.4_
  
  - [ ] 19.2 Implement sale item attribute persistence
    - After creating sale items, insert sale_item_attributes records
    - Batch insert for efficiency
    - Denormalize attribute names (name/ar_name for both type and value) for historical accuracy
    - _Requirements: 4.5, 6.7, 10.1_
  
  - [ ] 19.3 Add error handling for attribute persistence
    - Handle database errors
    - Rollback sale if attribute save fails
    - _Requirements: 6.7_

- [ ] 20. Final testing and verification
  - [ ] 20.1 Test attribute type management
    - Create, update, delete attribute types
    - Verify bilingual support
    - Test validation
    - _Requirements: 1.1, 1.2, 1.5, 1.6_
  
  - [ ] 20.2 Test attribute value management
    - Create, update, delete attribute values
    - Verify uniqueness within type
    - Test cascade delete
    - _Requirements: 1.3, 1.4, 1.6_
  
  - [ ] 20.3 Test product attribute assignment
    - Assign attributes to products
    - Verify mutual exclusivity with price variations
    - Test warning messages
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.7_
  
  - [ ] 20.4 Test POS attribute selection
    - Select attributes for products
    - Select attributes for bundle products
    - Verify cart display
    - Test validation
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 5.1, 5.2_
  
  - [ ] 20.5 Test cart management
    - Add products with different attributes
    - Add products with same attributes
    - Verify quantity increment logic
    - _Requirements: 4.1, 4.2, 4.3, 4.4_
  
  - [ ] 20.6 Test checkout and sale persistence
    - Complete checkout with attributed products
    - Verify sale_item_attributes records
    - Check denormalized data
    - _Requirements: 4.5, 6.7, 10.1_
  
  - [ ] 20.7 Test backward compatibility
    - Verify products without attributes work normally
    - Test products with price variations
    - Ensure existing workflows unchanged
    - _Requirements: 8.1, 8.2, 8.3, 8.4_

## Schema Reference

### Database Table Definitions

**attribute_types**
| Column | Type | Notes |
|--------|------|-------|
| id | UUID | Primary key, auto-generated |
| name | TEXT | Unique, English name |
| ar_name | TEXT | Arabic name |
| status | BOOLEAN | Default: true |
| created_at | TIMESTAMP | Auto-generated |
| updated_at | TIMESTAMP | Auto-updated via trigger |

**attribute_values**
| Column | Type | Notes |
|--------|------|-------|
| id | UUID | Primary key |
| attribute_type_id | UUID | FK → attribute_types(id), CASCADE DELETE |
| name | TEXT | Unique within type |
| ar_name | TEXT | Arabic name |
| status | BOOLEAN | Default: true |
| created_at | TIMESTAMP | Auto-generated |
| updated_at | TIMESTAMP | Auto-updated via trigger |
| UNIQUE(attribute_type_id, name) | | Composite unique constraint |

**product_attributes**
| Column | Type | Notes |
|--------|------|-------|
| id | UUID | Primary key |
| product_id | UUID | FK → products(id), CASCADE DELETE |
| attribute_type_id | UUID | FK → attribute_types(id), CASCADE DELETE |
| attribute_value_ids | UUID[] | Array of selected value IDs |
| created_at | TIMESTAMP | Auto-generated |
| updated_at | TIMESTAMP | Auto-updated via trigger |
| UNIQUE(product_id, attribute_type_id) | | One attribute type per product |

**sale_item_attributes** (tracks selections in orders)
| Column | Type | Notes |
|--------|------|-------|
| id | UUID | Primary key |
| sale_item_id | UUID | FK → sale_items(id) |
| attribute_type_id | UUID | FK → attribute_types(id) |
| attribute_value_id | UUID | FK → attribute_values(id) |
| attribute_type_name | TEXT | Denormalized (historical) |
| attribute_type_ar_name | TEXT | Denormalized (historical) |
| attribute_value_name | TEXT | Denormalized (historical) |
| attribute_value_ar_name | TEXT | Denormalized (historical) |
| created_at | TIMESTAMP | Auto-generated |

### Field Naming Convention

- **Database columns**: `snake_case` (e.g., `ar_name`, `attribute_type_id`, `sale_item_id`)
- **Dart model fields**: `camelCase` (e.g., `arName`, `attributeTypeId`, `saleItemId`)
- **Serialization**: Use `@JsonKey(name: 'db_column_name')` annotation

Example:
```dart
@JsonKey(name: 'attribute_type_id')
final String attributeTypeId;

@JsonKey(name: 'ar_name')
final String arName;
```

### Integration with Existing Schema

- Links to `products` table via `product_id` (products.different_price must be false)
- Links to `sale_items` table via `sale_item_id` for order tracking
- Compatible with `bundles` system (bundle products can have attributes)

## Notes

- Each task references specific requirements for traceability
- The implementation follows a bottom-up approach: database → models → services → state management → UI
- All code should follow existing SysteGo patterns (BLoC/Cubit, SupabaseService, Localizable interface)
- Bilingual support (English/Arabic) must be maintained throughout
- The feature is designed to be mutually exclusive with the existing Price Variation system
