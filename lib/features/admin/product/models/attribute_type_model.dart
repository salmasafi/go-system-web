// lib/features/admin/product/models/attribute_type_model.dart
// Model for Product Attribute Types (e.g., Color, Size, Material)

class AttributeType {
  final String id;
  final String name;
  final String arName;
  final bool status;
  final DateTime createdAt;
  final DateTime updatedAt;

  AttributeType({
    required this.id,
    required this.name,
    required this.arName,
    this.status = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AttributeType.fromJson(Map<String, dynamic> json) {
    return AttributeType(
      id: json['id'] ?? json['_id'] ?? '',
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
      'name': name,
      'ar_name': arName,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
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

  AttributeType copyWith({
    String? id,
    String? name,
    String? arName,
    bool? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttributeType(
      id: id ?? this.id,
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
  String toString() => 'AttributeType(id: $id, name: $name, arName: $arName)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttributeType && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Response wrapper for API calls
class AttributeTypeResponse {
  final bool success;
  final List<AttributeType> data;
  final String? message;

  AttributeTypeResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory AttributeTypeResponse.fromJson(Map<String, dynamic> json) {
    return AttributeTypeResponse(
      success: json['success'] ?? true,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => AttributeType.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      message: json['message'],
    );
  }
}
