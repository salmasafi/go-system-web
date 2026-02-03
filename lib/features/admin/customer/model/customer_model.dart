// Ensure you import the files where you defined Country, City, and CustomerGroup
import 'package:systego/features/admin/customer_group/model/customer_group.dart'; 
import 'package:systego/features/admin/suppliers/model/supplier_model.dart'; 

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
    return CustomerModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      // FIX: Handle number-to-string conversion safely
      phoneNumber: json['phone_number']?.toString() ?? '',
      address: json['address'] ?? '',
      
      // Integrating the Country/City classes from your Supplier file
      country: json['country'] != null ? Country.fromJson(json['country']) : null,
      city: json['city'] != null ? City.fromJson(json['city']) : null,
      
      customerGroup: json['customer_group_id'] != null 
          ? CustomerGroup.fromJson(json['customer_group_id']) 
          : null,
          
      isDue: json['is_Due'] ?? false,
      amountDue: (json['amount_Due'] as num?)?.toDouble() ?? 0.0,
      totalPointsEarned: (json['total_points_earned'] as num?)?.toInt() ?? 0,
      
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
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
      // FIX: Ensure .toJson() is called on nested objects
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