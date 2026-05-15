class ReturnItemModel {
  final String id;
  final String saleId;
  final String productName;
  final String productCode;
  final double price;
  final int quantity;
  final int alreadyReturned;
  final int availableToReturn;
  int returnQuantity;
  String reason;

  ReturnItemModel({
    required this.id,
    required this.saleId,
    required this.productName,
    required this.productCode,
    required this.price,
    required this.quantity,
    required this.alreadyReturned,
    required this.availableToReturn,
    this.returnQuantity = 0,
    this.reason = '',
  });

  factory ReturnItemModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>? ?? {};
    final qty = (json['quantity'] as num?)?.toInt() ?? 0;
    final alreadyReturned = (json['already_returned'] as num?)?.toInt() ?? 0;

    return ReturnItemModel(
      id: json['_id']?.toString() ?? '',
      saleId: json['sale_id']?.toString() ?? '',
      productName: product['name']?.toString() ?? '',
      productCode: product['code']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: qty,
      alreadyReturned: alreadyReturned,
      availableToReturn: qty - alreadyReturned,
      returnQuantity: 0,
    );
  }
}
