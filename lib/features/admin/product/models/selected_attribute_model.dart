// lib/features/admin/product/models/selected_attribute_model.dart
// Model for storing selected attribute in cart/checkout
// Contains denormalized names for display purposes

class SelectedAttribute {
  final String attributeTypeId;
  final String attributeTypeName;
  final String attributeTypeArName;
  final String attributeValueId;
  final String attributeValueName;
  final String attributeValueArName;

  SelectedAttribute({
    required this.attributeTypeId,
    required this.attributeTypeName,
    required this.attributeTypeArName,
    required this.attributeValueId,
    required this.attributeValueName,
    required this.attributeValueArName,
  });

  factory SelectedAttribute.fromJson(Map<String, dynamic> json) {
    return SelectedAttribute(
      attributeTypeId: json['attribute_type_id'] ?? '',
      attributeTypeName: json['attribute_type_name'] ?? '',
      attributeTypeArName: json['attribute_type_ar_name'] ?? '',
      attributeValueId: json['attribute_value_id'] ?? '',
      attributeValueName: json['attribute_value_name'] ?? '',
      attributeValueArName: json['attribute_value_ar_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attribute_type_id': attributeTypeId,
      'attribute_type_name': attributeTypeName,
      'attribute_type_ar_name': attributeTypeArName,
      'attribute_value_id': attributeValueId,
      'attribute_value_name': attributeValueName,
      'attribute_value_ar_name': attributeValueArName,
    };
  }

  /// Convert to database format for sale_item_attributes table
  Map<String, dynamic> toDbJson(String saleItemId) {
    return {
      'sale_item_id': saleItemId,
      'attribute_type_id': attributeTypeId,
      'attribute_type_name': attributeTypeName,
      'attribute_type_ar_name': attributeTypeArName,
      'attribute_value_id': attributeValueId,
      'attribute_value_name': attributeValueName,
      'attribute_value_ar_name': attributeValueArName,
    };
  }

  /// Returns localized type name
  String getLocalizedTypeName({bool isArabic = false}) {
    return isArabic && attributeTypeArName.isNotEmpty 
        ? attributeTypeArName 
        : attributeTypeName;
  }

  /// Returns localized value name
  String getLocalizedValueName({bool isArabic = false}) {
    return isArabic && attributeValueArName.isNotEmpty 
        ? attributeValueArName 
        : attributeValueName;
  }

  /// Returns display string like "Color: Red"
  String getDisplayString({bool isArabic = false}) {
    final typeName = getLocalizedTypeName(isArabic: isArabic);
    final valueName = getLocalizedValueName(isArabic: isArabic);
    return '$typeName: $valueName';
  }

  SelectedAttribute copyWith({
    String? attributeTypeId,
    String? attributeTypeName,
    String? attributeTypeArName,
    String? attributeValueId,
    String? attributeValueName,
    String? attributeValueArName,
  }) {
    return SelectedAttribute(
      attributeTypeId: attributeTypeId ?? this.attributeTypeId,
      attributeTypeName: attributeTypeName ?? this.attributeTypeName,
      attributeTypeArName: attributeTypeArName ?? this.attributeTypeArName,
      attributeValueId: attributeValueId ?? this.attributeValueId,
      attributeValueName: attributeValueName ?? this.attributeValueName,
      attributeValueArName: attributeValueArName ?? this.attributeValueArName,
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
  String getDisplayString({bool isArabic = false}) {
    if (attributes.isEmpty) return '';
    return attributes
        .map((a) => a.getDisplayString(isArabic: isArabic))
        .join(', ');
  }
}
