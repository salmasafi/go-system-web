class PaymentMethodResponse {
  final bool success;
  final PaymentMethodData data;

  PaymentMethodResponse({required this.success, required this.data});

  factory PaymentMethodResponse.fromJson(Map<String, dynamic> json) {
    return PaymentMethodResponse(
      success: json['success'] as bool,
      data: PaymentMethodData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson()};
  }
}

class PaymentMethodData {
  final String message;
  final List<PaymentMethodModel> paymentMethods;

  PaymentMethodData({required this.message, required this.paymentMethods});

  factory PaymentMethodData.fromJson(Map<String, dynamic> json) {
    return PaymentMethodData(
      message: json['message'] as String,
      paymentMethods: (json['paymentMethods'] as List<dynamic>)
          .map(
            (item) => PaymentMethodModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'paymentMethods': paymentMethods.map((item) => item.toJson()).toList(),
    };
  }
}

// PaymentMethodResponse and PaymentMethodData unchanged (they already handle the structure correctly)

class PaymentMethodModel {
  final String id;
  final String name;
  final String arName;
  final String type;
  final String description;
  final String? icon;
  final bool isActive;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentMethodModel({
    required this.id,
    required this.name,
    required this.arName,
    required this.type,
    required this.description,
    this.icon,
    required this.isActive,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  // Fix: Handle null 'country' in JSON (e.g., second PaymentMethod in your response has "country": null)
  // Also specify Map<String, dynamic> for type safety
  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      name: (json['name']?.toString()) ?? '',
      arName: (json['ar_name']?.toString()) ?? '',
      type: (json['type']?.toString()) ?? '',
      description: (json['discription']?.toString()) ?? '',
      icon: json['icon']?.toString(),
      isActive: json['isActive'] as bool? ?? false,
      version: json['__v'] as int? ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'ar_name': arName,
      'discription': description,
      'icon': icon,
      'isActive': isActive,
      'type': type,
      '__v': version,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
