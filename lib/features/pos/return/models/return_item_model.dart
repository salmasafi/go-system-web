class ReturnItemModel {
  final String id;
  final String saleId;
  final String productName;
  final String productCode;
  final int quantity;
  final int alreadyReturned;
  final int availableToReturn;
  int returnQuantity;
  String reason; // per-item reason

  ReturnItemModel({
    required this.id,
    required this.saleId,
    required this.productName,
    required this.productCode,
    required this.quantity,
    required this.alreadyReturned,
    required this.availableToReturn,
    this.returnQuantity = 0,
    this.reason = '',
  });

  factory ReturnItemModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>? ?? {};

    return ReturnItemModel(
      id: json['_id']?.toString() ?? '',
      saleId: json['sale_id']?.toString() ?? '',
      productName: product['name']?.toString() ?? '',
      productCode: product['code']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      alreadyReturned: (json['already_returned'] as num?)?.toInt() ?? 0,
      availableToReturn: (json['available_to_return'] as num?)?.toInt() ?? 0,
      returnQuantity: 0,
    );
  }
}
