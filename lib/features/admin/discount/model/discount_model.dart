class DiscountResponse {
  final bool success;
  final DiscountData data;

  DiscountResponse({required this.success, required this.data});

  factory DiscountResponse.fromJson(Map<String, dynamic> json) {
    return DiscountResponse(
      success: json['success'] as bool,
      data: DiscountData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson()};
  }
}

class DiscountData {
  final String message;
  final List<DiscountModel> discounts;

  DiscountData({required this.message, required this.discounts});

  factory DiscountData.fromJson(Map<String, dynamic> json) {
    return DiscountData(
      message: json['message'],
      discounts: (json['discounts'] as List<dynamic>)
          .map((item) => DiscountModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'discounts': discounts.map((e) => e.toJson()).toList(),
    };
  }
}

class DiscountModel {
  final String id;
  final String name;
  final double amount;
  final String type;
  final bool status;
  final String? createdAt;
  final String? updatedAt;
  final int? version;

  DiscountModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory DiscountModel.fromJson(Map<String, dynamic> json) {
    return DiscountModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: (json['type'] ?? 'fixed').toString(),
      status: json['status'] as bool? ?? true,
      createdAt: (json['created_at'] ?? json['createdAt'] ?? '').toString(),
      updatedAt: (json['updated_at'] ?? json['updatedAt'] ?? '').toString(),
      version: json['version'] ?? json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'type': type,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'version': version,
    };
  }
}
