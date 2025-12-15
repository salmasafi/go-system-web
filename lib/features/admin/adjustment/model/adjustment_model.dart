class AdjustmentResponse {
  final bool success;
  final AdjustmentData data;

  AdjustmentResponse({required this.success, required this.data});

  factory AdjustmentResponse.fromJson(Map<String, dynamic> json) {
    return AdjustmentResponse(
      success: json['success'] as bool,
      data: AdjustmentData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson()};
  }
}

class AdjustmentData {
  final String message;
  final List<AdjustmentModel> adjustments;

  AdjustmentData({
    required this.message,
    required this.adjustments,
  });

  factory AdjustmentData.fromJson(Map<String, dynamic> json) {
    return AdjustmentData(
      message: json['message'] as String,
      adjustments: (json['adjustments'] as List<dynamic>)
          .map((item) => AdjustmentModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'adjustments': adjustments.map((item) => item.toJson()).toList(),
    };
  }
}

class AdjustmentModel {
  final String id;
  final String warehouseId;
  final String productId;
  final int quantity;
  final String selectReasonId;
  final String note;
  final String? image;
  final DateTime createdAt;
  final int version;

  AdjustmentModel({
    required this.id,
    required this.warehouseId,
    required this.productId,
    required this.quantity,
    required this.selectReasonId,
    required this.note,
    this.image,
    required this.createdAt,
    required this.version,
  });

  factory AdjustmentModel.fromJson(Map<String, dynamic> json) {
    return AdjustmentModel(
      id: json['_id'] as String,
      warehouseId: json['warehouse_id'] as String,
      productId: json['productId'] as String,
      quantity: json['quantity'] as int,
      selectReasonId: json['select_reasonId'] as String,
      note: json['note'] as String,
      image: json['image'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      version: json['__v'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'warehouse_id': warehouseId,
      'productId': productId,
      'quantity': quantity,
      'select_reasonId': selectReasonId,
      'note': note,
      'image': image,
      'createdAt': createdAt.toIso8601String(),
      '__v': version,
    };
  }
}