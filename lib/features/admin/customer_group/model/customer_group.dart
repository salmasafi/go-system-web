class CustomerGroupResponse {
  final bool success;
  final CustomerGroupData data;

  CustomerGroupResponse({required this.success, required this.data});

  factory CustomerGroupResponse.fromJson(Map<String, dynamic> json) {
    return CustomerGroupResponse(
      success: json['success'] as bool,
      data: CustomerGroupData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class CustomerGroupData {
  final String message;
  final List<CustomerGroup> groups;

  CustomerGroupData({
    required this.message,
    required this.groups,
  });

  factory CustomerGroupData.fromJson(Map<String, dynamic> json) {
    return CustomerGroupData(
      message: json['message'] as String,
      groups: (json['groups'] as List<dynamic>)
          .map((item) => CustomerGroup.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'groups': groups.map((item) => item.toJson()).toList(),
    };
  }
}
class CustomerGroup {
  final String id;
  final String name;
  final bool status;
  // FIX: Make these nullable because they don't exist in the nested Customer object
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;

  CustomerGroup({
    required this.id,
    required this.name,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  factory CustomerGroup.fromJson(Map<String, dynamic> json) {
    return CustomerGroup(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? false,
      // FIX: Use tryParse or handle null safely
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt']) 
          : null,
      version: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'status': status,
      // FIX: Handle nulls in toJson
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (version != null) '__v': version,
    };
  }
}