// Ensure you import the files where you defined Country, City, and CustomerGroup
import 'package:GoSystem/features/admin/suppliers/model/supplier_model.dart';

import '../../customer_group/model/customer_group_model.dart'; 

class Country {
  final String id;
  final String name;

  Country({
    required this.id,
    required this.name,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? json['country_name'] ?? '').toString(),
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
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? json['city_name'] ?? '').toString(),
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
      id: (json['id'] ?? json['_id'] ?? '').toString(),
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

  CustomerResponse({required this.success, required this.data});

  factory CustomerResponse.fromJson(Map<String, dynamic> json) {
    return CustomerResponse(
      success: json['success'] as bool,
      data: CustomerData.fromJson(json['data']),
    );
  }
}

class CustomerData {
  final String message;
  final List<CustomerModel> customers;

  CustomerData({required this.message, required this.customers});

  factory CustomerData.fromJson(Map<String, dynamic> json) {
    return CustomerData(
      message: json['message'] ?? '',
      customers: (json['customers'] as List?)
          ?.map((e) => CustomerModel.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'customers': customers.map((e) => e.toJson()).toList(),
      };
}

class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String address;
  // These use the classes you defined in SupplierModel
  final Country? country;
  final City? city;

  final CustomerGroup? customerGroup;
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
    final dynamic countryJson = json['country_id'] ?? json['country'];
    Country? countryObj;
    if (countryJson is Map<String, dynamic>) {
      countryObj = Country.fromJson(countryJson);
    } else if (countryJson != null) {
       countryObj = Country(id: countryJson.toString(), name: '');
    }

    final dynamic cityJson = json['city_id'] ?? json['city'];
    City? cityObj;
    if (cityJson is Map<String, dynamic>) {
      cityObj = City.fromJson(cityJson);
    } else if (cityJson != null) {
       cityObj = City(id: cityJson.toString(), name: '');
    }

    final dynamic groupJson = json['customer_group_id'] ?? json['group'];
    CustomerGroup? groupObj;
    if (groupJson is Map<String, dynamic>) {
      groupObj = CustomerGroup.fromJson(groupJson);
    }

    return CustomerModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: (json['phone_number'] ?? json['phone'] ?? '').toString(),
      address: json['address']?.toString() ?? '',
      country: countryObj,
      city: cityObj,
      customerGroup: groupObj,
      isDue: json['is_due'] ?? json['is_Due'] ?? false,
      amountDue: (json['amount_due'] ?? json['amount_Due'] ?? 0).toDouble(),
      totalPointsEarned: (json['total_points_earned'] ?? 0).toInt(),
      createdAt: DateTime.tryParse((json['created_at'] ?? json['createdAt'] ?? '').toString()) ?? DateTime.now(),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? json['updatedAt'] ?? '').toString()) ?? DateTime.now(),
      version: json['version'] ?? json['__v'] ?? 0,
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
