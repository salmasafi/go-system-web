// lib/features/admin/product/models/product_attribute_model.dart
// Model for linking Products to their available Attribute Types and Values

import 'attribute_type_model.dart';
import 'attribute_value_model.dart';

class ProductAttribute {
  final String id;
  final String productId;
  final String attributeTypeId;
  final AttributeType? attributeType;
  final List<String> attributeValueIds;
  final List<AttributeValue>? availableValues;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductAttribute({
    required this.id,
    required this.productId,
    required this.attributeTypeId,
    this.attributeType,
    required this.attributeValueIds,
    this.availableValues,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    return ProductAttribute(
      id: json['id'] ?? json['_id'] ?? '',
      productId: json['product_id'] ?? '',
      attributeTypeId: json['attribute_type_id'] ?? '',
      attributeType: json['attribute_type'] != null
          ? AttributeType.fromJson(json['attribute_type'] as Map<String, dynamic>)
          : null,
      attributeValueIds: (json['attribute_value_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      availableValues: (json['available_values'] as List<dynamic>?)
              ?.map((e) => AttributeValue.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'attribute_type_id': attributeTypeId,
      'attribute_type': attributeType?.toJson(),
      'attribute_value_ids': attributeValueIds,
      'available_values': availableValues?.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'product_id': productId,
      'attribute_type_id': attributeTypeId,
      'attribute_value_ids': attributeValueIds,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'attribute_value_ids': attributeValueIds,
    };
  }

  ProductAttribute copyWith({
    String? id,
    String? productId,
    String? attributeTypeId,
    AttributeType? attributeType,
    List<String>? attributeValueIds,
    List<AttributeValue>? availableValues,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductAttribute(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      attributeTypeId: attributeTypeId ?? this.attributeTypeId,
      attributeType: attributeType ?? this.attributeType,
      attributeValueIds: attributeValueIds ?? this.attributeValueIds,
      availableValues: availableValues ?? this.availableValues,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if a specific value ID is available for this product
  bool hasValue(String valueId) {
    return attributeValueIds.contains(valueId);
  }

  /// Get localized attribute type name
  String getLocalizedTypeName({bool isArabic = false}) {
    return attributeType?.getLocalizedName(isArabic: isArabic) ?? '';
  }

  /// Get available values as localized strings
  List<String> getLocalizedValueNames({bool isArabic = false}) {
    if (availableValues == null) return [];
    return availableValues!
        .where((v) => attributeValueIds.contains(v.id))
        .map((v) => v.getLocalizedName(isArabic: isArabic))
        .toList();
  }

  @override
  String toString() => 
      'ProductAttribute(id: $id, productId: $productId, typeId: $attributeTypeId)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductAttribute && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Response wrapper for API calls
class ProductAttributeResponse {
  final bool success;
  final List<ProductAttribute> data;
  final String? message;

  ProductAttributeResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory ProductAttributeResponse.fromJson(Map<String, dynamic> json) {
    return ProductAttributeResponse(
      success: json['success'] ?? true,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => ProductAttribute.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      message: json['message'],
    );
  }
}
