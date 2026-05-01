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
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      warehouseId: (json['warehouse_id'] ?? json['warehouseId'] ?? '')?.toString() ?? '',
      productId: (json['product_id'] ?? json['productId'] ?? '')?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      selectReasonId: (json['reason_id'] ?? json['select_reasonId'] ?? '')?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      image: json['image'] ?? json['image_url'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now()),
      version: json['version'] ?? json['__v'] ?? 0,
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
