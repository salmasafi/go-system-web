class AdjustmentModel {
  final String id;
  final String reference;
  final String warehouseId;
  final String warehouseName;
  final String type; // 'increase' or 'decrease'
  final String reason;
  final double totalAmount;
  final String status; // 'pending', 'completed', 'cancelled'
  final String note;
  final String? attachmentUrl;
  final String createdAt;
  final String createdBy;
  final List<AdjustmentItemModel> items;

  AdjustmentModel({
    required this.id,
    required this.reference,
    required this.warehouseId,
    required this.warehouseName,
    required this.type,
    required this.reason,
    required this.totalAmount,
    required this.status,
    required this.note,
    this.attachmentUrl,
    required this.createdAt,
    required this.createdBy,
    required this.items,
  });

  factory AdjustmentModel.fromJson(Map<String, dynamic> json) {
    final warehouse = json['warehouse_id'] is Map ? json['warehouse_id'] as Map : null;
    final createdByUser = json['created_by'] is Map ? json['created_by'] as Map : null;
    
    return AdjustmentModel(
      id: json['_id'] ?? json['id'] ?? '',
      reference: json['reference'] ?? '',
      warehouseId: warehouse?['_id']?.toString() ?? json['warehouse_id']?.toString() ?? '',
      warehouseName: warehouse?['name']?.toString() ?? '',
      type: json['type'] ?? 'increase',
      reason: json['reason'] ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'completed',
      note: json['note'] ?? '',
      attachmentUrl: json['attachment_url'],
      createdAt: json['created_at'] ?? json['createdAt'] ?? '',
      createdBy: createdByUser?['full_name']?.toString() ?? 
                 createdByUser?['email']?.toString() ?? '',
      items: (json['items'] as List? ?? [])
          .map((e) => AdjustmentItemModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'reference': reference,
    'warehouse_id': warehouseId,
    'type': type,
    'reason': reason,
    'total_amount': totalAmount,
    'status': status,
    'note': note,
    'attachment_url': attachmentUrl,
    'created_at': createdAt,
  };
}

class AdjustmentItemModel {
  final String id;
  final String adjustmentId;
  final String productId;
  final String productName;
  final String productCode;
  final int quantity;
  final int currentStock;
  final int newStock;
  final double unitCost;
  final double totalCost;
  final String reason;

  AdjustmentItemModel({
    required this.id,
    required this.adjustmentId,
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.quantity,
    required this.currentStock,
    required this.newStock,
    required this.unitCost,
    required this.totalCost,
    required this.reason,
  });

  factory AdjustmentItemModel.fromJson(Map<String, dynamic> json) {
    final product = json['product_id'] is Map ? json['product_id'] as Map : null;
    
    return AdjustmentItemModel(
      id: json['_id'] ?? json['id'] ?? '',
      adjustmentId: json['adjustment_id']?.toString() ?? '',
      productId: product?['_id']?.toString() ?? json['product_id']?.toString() ?? '',
      productName: product?['name']?.toString() ?? '',
      productCode: product?['code']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      currentStock: (json['current_stock'] as num?)?.toInt() ?? 0,
      newStock: (json['new_stock'] as num?)?.toInt() ?? 0,
      unitCost: (json['unit_cost'] as num?)?.toDouble() ?? 0.0,
      totalCost: (json['total_cost'] as num?)?.toDouble() ?? 0.0,
      reason: json['reason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'adjustment_id': adjustmentId,
    'product_id': productId,
    'quantity': quantity,
    'current_stock': currentStock,
    'new_stock': newStock,
    'unit_cost': unitCost,
    'total_cost': totalCost,
    'reason': reason,
  };
}
