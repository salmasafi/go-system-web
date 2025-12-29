class CustomerResponse {
  final bool success;
  final CustomerData data;

  CustomerResponse({
    required this.success,
    required this.data,
  });

  factory CustomerResponse.fromJson(Map<String, dynamic> json) {
    return CustomerResponse(
      success: json['success'] as bool,
      data: CustomerData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class CustomerData {
  final String message;
  final List<CustomerModel> customers;

  CustomerData({
    required this.message,
    required this.customers,
  });

  factory CustomerData.fromJson(Map<String, dynamic> json) {
    return CustomerData(
      message: json['message'],
      customers: (json['customers'] as List)
          .map((e) => CustomerModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'customers': customers.map((e) => e.toJson()).toList(),
    };
  }
}

class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String address;
  final String country;
  final String city;
  final String? customerGroupId;
  final bool isDue;
  final double amountDue;
  final int totalPointsEarned;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.country,
    required this.city,
    this.customerGroupId,
    required this.isDue,
    required this.amountDue,
    required this.totalPointsEarned,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['_id'],
      name: json['name'],
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'],
      address: json['address'] ?? '',
      country: json['country'],
      city: json['city'],
      customerGroupId: json['customer_group_id'],
      isDue: json['is_Due'] ?? false,
      amountDue: (json['amount_Due'] as num?)?.toDouble() ?? 0.0,
      totalPointsEarned: (json['total_points_earned'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      version: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'address': address,
      'country': country,
      'city': city,
      if (customerGroupId != null) 'customer_group_id': customerGroupId,
      'is_Due': isDue,
      'amount_Due': amountDue,
      'total_points_earned': totalPointsEarned,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }
}