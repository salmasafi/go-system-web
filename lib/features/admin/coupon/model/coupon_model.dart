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
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['_id'],
      couponCode: json['coupon_code'],
      type: json['type'],
      amount: (json['amount'] as num).toDouble(),
      minimumAmount: (json['minimum_amount'] as num).toDouble(),
      quantity: json['quantity'],
      available: json['available'],
      expiredDate: json['expired_date'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      version: json['__v'],
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
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': version,
    };
  }
}
