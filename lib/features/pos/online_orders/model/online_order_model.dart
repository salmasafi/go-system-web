class OnlineOrderItem {
  final String productId;
  final String productName;
  final double price;
  final double? wholePrice;
  final int? startQuantity;
  final int quantity;

  OnlineOrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    this.wholePrice,
    this.startQuantity,
    required this.quantity,
  });

  bool get isWholePriceActive =>
      wholePrice != null && startQuantity != null && quantity >= startQuantity!;

  double get effectivePrice => isWholePriceActive ? wholePrice! : price;

  double get subtotal => effectivePrice * quantity;

  factory OnlineOrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['product_id'] is Map ? json['product_id'] : {};
    return OnlineOrderItem(
      productId: product['_id']?.toString() ?? json['product_id']?.toString() ?? '',
      productName: product['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      wholePrice: (json['whole_price'] as num?)?.toDouble(),
      startQuantity: (json['start_quantity'] as num?)?.toInt(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}

class OnlineOrderModel {
  final String id;
  final String orderNumber;
  final String customerName;
  final String branch;
  final double amount;
  final String status;
  final String dateTime;
  final String type;
  final List<OnlineOrderItem> items;

  OnlineOrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.branch,
    required this.amount,
    required this.status,
    required this.dateTime,
    required this.type,
    this.items = const [],
  });

  factory OnlineOrderModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer_id'] is Map ? json['customer_id'] : {};
    final branch = json['branch_id'] is Map ? json['branch_id'] : {};
    return OnlineOrderModel(
      id: json['_id']?.toString() ?? '',
      orderNumber: json['order_number']?.toString() ?? json['reference']?.toString() ?? '',
      customerName: customer['name']?.toString() ?? 'N/A',
      branch: branch['name']?.toString() ?? 'N/A',
      amount: (json['total_amount'] as num?)?.toDouble() ??
          (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'pending',
      dateTime: json['createdAt']?.toString() ?? json['date']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      items: ((json['products'] ?? json['items']) is List
              ? (json['products'] ?? json['items']) as List
              : [])
          .map((e) => OnlineOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
