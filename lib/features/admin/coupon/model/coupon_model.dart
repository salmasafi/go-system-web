class CouponResponse {
  final bool success;
  final CouponData data;

  CouponResponse({
    required this.success,
    required this.data,
  });

  factory CouponResponse.fromJson(Map<String, dynamic> json) {
    return CouponResponse(
      success: json['success'] as bool,
      data: CouponData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class CouponData {
  final String message;
  final List<CouponModel> coupons;

  CouponData({
    required this.message,
    required this.coupons,
  });

  factory CouponData.fromJson(Map<String, dynamic> json) {
    return CouponData(
      message: json['message'],
      coupons: (json['coupons'] as List<dynamic>)
          .map((item) => CouponModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'coupons': coupons.map((e) => e.toJson()).toList(),
    };
  }
}

class CouponModel {
  final String id;
  final String couponCode;
  final String type;
  final double amount;
  final double minimumAmount;
  final int quantity;
  final int available;
  final String expiredDate;
  final bool status;
  final String createdAt;
  final String updatedAt;
  final int version;

  CouponModel({
    required this.id,
    required this.couponCode,
    required this.type,
    required this.amount,
    required this.minimumAmount,
    required this.quantity,
    required this.available,
    required this.expiredDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      couponCode: json['coupon_code']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      minimumAmount: (json['minimum_amount'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] as int? ?? 0,
      available: json['available'] as int? ?? 0,
      expiredDate: json['expired_date']?.toString() ?? '',
      status: json['status'] as bool? ?? true,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      version: json['__v'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'coupon_code': couponCode,
      'type': type,
      'amount': amount,
      'minimum_amount': minimumAmount,
      'quantity': quantity,
      'available': available,
      'expired_date': expiredDate,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': version,
    };
  }

  CouponModel copyWith({
    String? id,
    String? couponCode,
    String? type,
    double? amount,
    double? minimumAmount,
    int? quantity,
    int? available,
    String? expiredDate,
    bool? status,
    String? createdAt,
    String? updatedAt,
    int? version,
  }) {
    return CouponModel(
      id: id ?? this.id,
      couponCode: couponCode ?? this.couponCode,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      minimumAmount: minimumAmount ?? this.minimumAmount,
      quantity: quantity ?? this.quantity,
      available: available ?? this.available,
      expiredDate: expiredDate ?? this.expiredDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
    );
  }
}
