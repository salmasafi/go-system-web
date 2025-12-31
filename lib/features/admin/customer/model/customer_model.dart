class Country {
  final String id;
  final String name;

  Country({
    required this.id,
    required this.name,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }
}

class City {
  final String id;
  final String name;

  City({
    required this.id,
    required this.name,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }
}

class SimpleCustomerGroup {
  final String id;
  final String name;
  final bool status;

  SimpleCustomerGroup({
    required this.id,
    required this.name,
    required this.status,
  });

  factory SimpleCustomerGroup.fromJson(Map<String, dynamic> json) {
    return SimpleCustomerGroup(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'status': status,
    };
  }
}

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
  final Country? country;
  final City? city;
  final SimpleCustomerGroup? customerGroup;
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
    this.country,
    this.city,
    this.customerGroup,
    required this.isDue,
    required this.amountDue,
    required this.totalPointsEarned,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    final dynamic groupJson = json['customer_group_id'];
    SimpleCustomerGroup? group;
    if (groupJson is String && groupJson.isNotEmpty) {
      group = SimpleCustomerGroup(id: groupJson, name: '', status: false);
    } else if (groupJson is Map<String, dynamic>) {
      group = SimpleCustomerGroup.fromJson(groupJson);
    }

    final dynamic countryJson = json['country'];
    Country? countryObj;
    if (countryJson is Map<String, dynamic>) {
      countryObj = Country.fromJson(countryJson);
    } // If string, ignore or handle if needed, but currently set to null

    final dynamic cityJson = json['city'];
    City? cityObj;
    if (cityJson is Map<String, dynamic>) {
      cityObj = City.fromJson(cityJson);
    } // If string, set to null

    return CustomerModel(
      id: json['_id'],
      name: json['name'],
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      address: json['address'] ?? '',
      country: countryObj,
      city: cityObj,
      customerGroup: group,
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
      'country': country?.toJson(),
      'city': city?.toJson(),
      'customer_group_id': customerGroup?.toJson(),
      'is_Due': isDue,
      'amount_Due': amountDue,
      'total_points_earned': totalPointsEarned,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }
}