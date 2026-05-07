// lib/features/admin/product/models/selected_attribute_model.dart
// Model for storing selected attribute in cart/checkout
// Contains denormalized names for display purposes

class SelectedAttribute {
  final String attributeTypeId;
  final String attributeTypeName;
  final String attributeValueId;
  final String attributeValueName;

  SelectedAttribute({
    required this.attributeTypeId,
    required this.attributeTypeName,
    required this.attributeValueId,
    required this.attributeValueName,
  });

  factory SelectedAttribute.fromJson(Map<String, dynamic> json) {
    return SelectedAttribute(
      attributeTypeId: json['attribute_type_id'] ?? '',
      attributeTypeName: json['attribute_type_name'] ?? '',
      attributeValueId: json['attribute_value_id'] ?? '',
      attributeValueName: json['attribute_value_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attribute_type_id': attributeTypeId,
      'attribute_type_name': attributeTypeName,
      'attribute_value_id': attributeValueId,
      'attribute_value_name': attributeValueName,
    };
  }

  /// Convert to database format for sale_item_attributes table
  Map<String, dynamic> toDbJson(String saleItemId) {
    return {
      'sale_item_id': saleItemId,
      'attribute_type_id': attributeTypeId,
      'attribute_type_name': attributeTypeName,
      'attribute_value_id': attributeValueId,
      'attribute_value_name': attributeValueName,
    };
  }

  /// Returns display string like "Color: Red"
  String getDisplayString() {
    return '$attributeTypeName: $attributeValueName';
  }

  SelectedAttribute copyWith({
    String? attributeTypeId,
    String? attributeTypeName,
    String? attributeValueId,
    String? attributeValueName,
  }) {
    return SelectedAttribute(
      attributeTypeId: attributeTypeId ?? this.attributeTypeId,
      attributeTypeName: attributeTypeName ?? this.attributeTypeName,
      attributeValueId: attributeValueId ?? this.attributeValueId,
      attributeValueName: attributeValueName ?? this.attributeValueName,
    );
  }

  @override
  String toString() => 
      'SelectedAttribute(type: $attributeTypeName, value: $attributeValueName)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SelectedAttribute &&
        other.attributeTypeId == attributeTypeId &&
        other.attributeValueId == attributeValueId;
  }

  @override
  int get hashCode => 
      attributeTypeId.hashCode ^ attributeValueId.hashCode;
}

// Helper class for cart item attribute comparison
class CartItemAttributes {
  final List<SelectedAttribute> attributes;

  CartItemAttributes({required this.attributes});

  /// Check if two cart items have the same attributes
  bool isSameAs(CartItemAttributes other) {
    if (attributes.length != other.attributes.length) return false;
    
    // Sort both lists by type ID for comparison
    final sortedThis = List<SelectedAttribute>.from(attributes)
      ..sort((a, b) => a.attributeTypeId.compareTo(b.attributeTypeId));
    final sortedOther = List<SelectedAttribute>.from(other.attributes)
      ..sort((a, b) => a.attributeTypeId.compareTo(b.attributeTypeId));
    
    for (int i = 0; i < sortedThis.length; i++) {
      if (sortedThis[i].attributeTypeId != sortedOther[i].attributeTypeId ||
          sortedThis[i].attributeValueId != sortedOther[i].attributeValueId) {
        return false;
      }
    }
    return true;
  }

  /// Convert to JSON for storage
  List<Map<String, dynamic>> toJson() {
    return attributes.map((a) => a.toJson()).toList();
  }

  /// Create from JSON
  factory CartItemAttributes.fromJson(List<dynamic> json) {
    return CartItemAttributes(
      attributes: json
          .map((e) => SelectedAttribute.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get display string for all attributes
  String getDisplayString() {
    if (attributes.isEmpty) return '';
    return attributes
        .map((a) => a.getDisplayString())
        .join(', ');
  }
}
