// lib/features/admin/product/models/sale_item_attribute_model.dart
// Model for historical record of selected attributes in sale items
// This is the database representation of sale_item_attributes table

class SaleItemAttribute {
  final String id;
  final String saleItemId;
  final String attributeTypeId;
  final String attributeValueId;
  final String attributeTypeName;
  final String attributeTypeArName;
  final String attributeValueName;
  final String attributeValueArName;
  final DateTime createdAt;

  SaleItemAttribute({
    required this.id,
    required this.saleItemId,
    required this.attributeTypeId,
    required this.attributeValueId,
    required this.attributeTypeName,
    required this.attributeTypeArName,
    required this.attributeValueName,
    required this.attributeValueArName,
    required this.createdAt,
  });

  factory SaleItemAttribute.fromJson(Map<String, dynamic> json) {
    return SaleItemAttribute(
      id: json['id'] ?? json['_id'] ?? '',
      saleItemId: json['sale_item_id'] ?? '',
      attributeTypeId: json['attribute_type_id'] ?? '',
      attributeValueId: json['attribute_value_id'] ?? '',
      attributeTypeName: json['attribute_type_name'] ?? '',
      attributeTypeArName: json['attribute_type_ar_name'] ?? '',
      attributeValueName: json['attribute_value_name'] ?? '',
      attributeValueArName: json['attribute_value_ar_name'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sale_item_id': saleItemId,
      'attribute_type_id': attributeTypeId,
      'attribute_value_id': attributeValueId,
      'attribute_type_name': attributeTypeName,
      'attribute_type_ar_name': attributeTypeArName,
      'attribute_value_name': attributeValueName,
      'attribute_value_ar_name': attributeValueArName,
      'created_at': createdAt.toIso8601String(),
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

  SaleItemAttribute copyWith({
    String? id,
    String? saleItemId,
    String? attributeTypeId,
    String? attributeValueId,
    String? attributeTypeName,
    String? attributeTypeArName,
    String? attributeValueName,
    String? attributeValueArName,
    DateTime? createdAt,
  }) {
    return SaleItemAttribute(
      id: id ?? this.id,
      saleItemId: saleItemId ?? this.saleItemId,
      attributeTypeId: attributeTypeId ?? this.attributeTypeId,
      attributeValueId: attributeValueId ?? this.attributeValueId,
      attributeTypeName: attributeTypeName ?? this.attributeTypeName,
      attributeTypeArName: attributeTypeArName ?? this.attributeTypeArName,
      attributeValueName: attributeValueName ?? this.attributeValueName,
      attributeValueArName: attributeValueArName ?? this.attributeValueArName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 
      'SaleItemAttribute(saleItemId: $saleItemId, type: $attributeTypeName, value: $attributeValueName)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SaleItemAttribute && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Response wrapper for API calls
class SaleItemAttributeResponse {
  final bool success;
  final List<SaleItemAttribute> data;
  final String? message;

  SaleItemAttributeResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory SaleItemAttributeResponse.fromJson(Map<String, dynamic> json) {
    return SaleItemAttributeResponse(
      success: json['success'] ?? true,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => SaleItemAttribute.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      message: json['message'],
    );
  }
}

// Batch insert helper for creating multiple sale item attributes
class SaleItemAttributeBatch {
  final String saleItemId;
  final List<Map<String, dynamic>> attributes;

  SaleItemAttributeBatch({
    required this.saleItemId,
    required this.attributes,
  });

  Map<String, dynamic> toJson() {
    return {
      'sale_item_id': saleItemId,
      'attributes': attributes,
    };
  }
}
