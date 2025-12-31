import '../../customer/model/customer_model.dart';

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
    return {'success': success, 'data': data.toJson()};
  }
}

class CustomerGroupData {
  final String message;
  final List<CustomerGroup> groups;

  CustomerGroupData({required this.message, required this.groups});

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
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final List<CustomerModel> customers;

  CustomerGroup({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.customers,
  });

  factory CustomerGroup.fromJson(Map<String, dynamic> json) {
    return CustomerGroup(
      id: (json['_id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      status: json['status'] as bool,
      createdAt: DateTime.parse(
        (json['createdAt'] as String?) ?? '1970-01-01T00:00:00.000Z',
      ),
      updatedAt: DateTime.parse(
        (json['updatedAt'] as String?) ?? '1970-01-01T00:00:00.000Z',
      ),
      version: json['__v'] as int? ?? 0,
      customers: (json['customers'] as List<dynamic>? ?? [])
          .map((e) => CustomerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
      'customers': customers.map((e) => e.toJson()).toList(),
    };
  }
}