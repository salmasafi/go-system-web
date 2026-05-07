// lib/features/admin/product/models/sale_item_attribute_model.dart
// Model for historical record of selected attributes in sale items
// This is the database representation of sale_item_attributes table

class SaleItemAttribute {
  final String id;
  final String saleItemId;
  final String attributeTypeId;
  final String attributeValueId;
  final String attributeTypeName;
  final String attributeValueName;
  final DateTime createdAt;

  SaleItemAttribute({
    required this.id,
    required this.saleItemId,
    required this.attributeTypeId,
    required this.attributeValueId,
    required this.attributeTypeName,
    required this.attributeValueName,
    required this.createdAt,
  });

  factory SaleItemAttribute.fromJson(Map<String, dynamic> json) {
    return SaleItemAttribute(
      id: json['id'] ?? json['_id'] ?? '',
      saleItemId: json['sale_item_id'] ?? '',
      attributeTypeId: json['attribute_type_id'] ?? '',
      attributeValueId: json['attribute_value_id'] ?? '',
      attributeTypeName: json['attribute_type_name'] ?? '',
      attributeValueName: json['attribute_value_name'] ?? '',
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
      'attribute_value_name': attributeValueName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Returns display string like "Color: Red"
  String getDisplayString() {
    return '$attributeTypeName: $attributeValueName';
  }

  SaleItemAttribute copyWith({
    String? id,
    String? saleItemId,
    String? attributeTypeId,
    String? attributeValueId,
    String? attributeTypeName,
    String? attributeValueName,
    DateTime? createdAt,
  }) {
    return SaleItemAttribute(
      id: id ?? this.id,
      saleItemId: saleItemId ?? this.saleItemId,
      attributeTypeId: attributeTypeId ?? this.attributeTypeId,
      attributeValueId: attributeValueId ?? this.attributeValueId,
      attributeTypeName: attributeTypeName ?? this.attributeTypeName,
      attributeValueName: attributeValueName ?? this.attributeValueName,
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
