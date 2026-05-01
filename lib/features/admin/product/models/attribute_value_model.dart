// lib/features/admin/product/models/attribute_value_model.dart
// Model for Attribute Values (e.g., Red, Blue for Color attribute)

class AttributeValue {
  final String id;
  final String attributeTypeId;
  final String name;
  final String arName;
  final bool status;
  final DateTime createdAt;
  final DateTime updatedAt;

  AttributeValue({
    required this.id,
    required this.attributeTypeId,
    required this.name,
    required this.arName,
    this.status = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AttributeValue.fromJson(Map<String, dynamic> json) {
    return AttributeValue(
      id: json['id'] ?? json['_id'] ?? '',
      attributeTypeId: json['attribute_type_id'] ?? '',
      name: json['name'] ?? '',
      arName: json['ar_name'] ?? '',
      status: json['status'] is bool 
          ? json['status'] 
          : (json['status'] == 1 || json['status'] == '1' || json['status'] == true),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attribute_type_id': attributeTypeId,
      'name': name,
      'ar_name': arName,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'attribute_type_id': attributeTypeId,
      'name': name,
      'ar_name': arName,
      'status': status,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'ar_name': arName,
      'status': status,
    };
  }

  AttributeValue copyWith({
    String? id,
    String? attributeTypeId,
    String? name,
    String? arName,
    bool? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttributeValue(
      id: id ?? this.id,
      attributeTypeId: attributeTypeId ?? this.attributeTypeId,
      name: name ?? this.name,
      arName: arName ?? this.arName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Returns localized name based on locale
  String getLocalizedName({bool isArabic = false}) {
    return isArabic && arName.isNotEmpty ? arName : name;
  }

  @override
  String toString() => 'AttributeValue(id: $id, name: $name, typeId: $attributeTypeId)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttributeValue && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Response wrapper for API calls
class AttributeValueResponse {
  final bool success;
  final List<AttributeValue> data;
  final String? message;

  AttributeValueResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory AttributeValueResponse.fromJson(Map<String, dynamic> json) {
    return AttributeValueResponse(
      success: json['success'] ?? true,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => AttributeValue.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      message: json['message'],
    );
  }
}
