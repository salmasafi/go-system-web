class PurchaseReturnResponse {
  final bool success;
  final PurchaseReturnData data;
  PurchaseReturnResponse({required this.success, required this.data});
  factory PurchaseReturnResponse.fromJson(Map<String, dynamic> json) =>
      PurchaseReturnResponse(
        success: json['success'] as bool,
        data: PurchaseReturnData.fromJson(json['data']),
      );
}

class PurchaseReturnData {
  final List<PurchaseReturnModel> returns;
  final int totalReturns;
  final double totalAmount;
  PurchaseReturnData(
      {required this.returns,
      required this.totalReturns,
      required this.totalAmount});
  factory PurchaseReturnData.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? {};
    return PurchaseReturnData(
      returns: (json['returns'] as List? ?? [])
          .map((e) => PurchaseReturnModel.fromJson(e))
          .toList(),
      totalReturns: (summary['total_returns'] as num?)?.toInt() ?? 0,
      totalAmount: (summary['total_amount'] as num?)?.toDouble() ?? 0,
    );
  }
}

class PurchaseReturnModel {
  final String id;
  final String reference;
  final String purchaseReference;
  final String purchaseId;
  final double purchaseGrandTotal;
  final String? supplierName;
  final String? supplierPhone;
  final double totalAmount;
  final String refundMethod;
  final String note;
  final String date;
  final List<ReturnItem> items;

  PurchaseReturnModel({
    required this.id,
    required this.reference,
    required this.purchaseReference,
    required this.purchaseId,
    required this.purchaseGrandTotal,
    this.supplierName,
    this.supplierPhone,
    required this.totalAmount,
    required this.refundMethod,
    required this.note,
    required this.date,
    required this.items,
  });

  factory PurchaseReturnModel.fromJson(Map<String, dynamic> json) {
    final purchase =
        json['purchase_id'] is Map ? json['purchase_id'] as Map : {};
    final supplier =
        json['supplier_id'] is Map ? json['supplier_id'] as Map : null;
    return PurchaseReturnModel(
      id: json['_id'] ?? '',
      reference: json['reference'] ?? '',
      purchaseReference: json['purchase_reference'] ?? '',
      purchaseId: purchase['_id']?.toString() ?? '',
      purchaseGrandTotal:
          (purchase['grand_total'] as num?)?.toDouble() ?? 0,
      supplierName: supplier?['company_name']?.toString() ??
          supplier?['username']?.toString(),
      supplierPhone: supplier?['phone_number']?.toString(),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      refundMethod: json['refund_method'] ?? '',
      note: json['note'] ?? '',
      date: json['date'] ?? json['createdAt'] ?? '',
      items: (json['items'] as List? ?? [])
          .map((e) => ReturnItem.fromJson(e))
          .toList(),
    );
  }
}

class ReturnItem {
  final String productId;
  final int originalQuantity;
  final int returnedQuantity;
  final double price;
  final double subtotal;

  ReturnItem({
    required this.productId,
    required this.originalQuantity,
    required this.returnedQuantity,
    required this.price,
    required this.subtotal,
  });

  factory ReturnItem.fromJson(Map<String, dynamic> json) => ReturnItem(
        productId: json['product_id']?.toString() ?? '',
        originalQuantity: (json['original_quantity'] as num?)?.toInt() ?? 0,
        returnedQuantity: (json['returned_quantity'] as num?)?.toInt() ?? 0,
        price: (json['price'] as num?)?.toDouble() ?? 0,
        subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      );
}
