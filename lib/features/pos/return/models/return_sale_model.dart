import 'return_item_model.dart';

class ReturnSaleModel {
  final String id;
  final String reference;
  final String date;
  final String? customerName;
  final String warehouseName;
  final String cashierEmail;
  final String cashierName;
  final String cashierManName;
  final List<ReturnItemModel> items;

  ReturnSaleModel({
    required this.id,
    required this.reference,
    required this.date,
    this.customerName,
    required this.warehouseName,
    required this.cashierEmail,
    required this.cashierName,
    required this.cashierManName,
    required this.items,
  });

  String get displayCustomerName => customerName ?? 'Walk-in Customer';

  factory ReturnSaleModel.fromJson(Map<String, dynamic> json) {
    // Supports both the new return-sale/{id} response and legacy flat sale objects
    final data = json['data'] as Map<String, dynamic>?;
    final sale = data?['sale'] as Map<String, dynamic>? ??
        json['sale'] as Map<String, dynamic>? ??
        json;
    final customer = sale['customer'] as Map<String, dynamic>?;
    final warehouse = sale['warehouse'] as Map<String, dynamic>? ?? {};
    final createdBy = sale['created_by'] as Map<String, dynamic>? ?? {};
    final shift = sale['shift'] as Map<String, dynamic>? ?? {};
    final cashier = shift['cashier'] as Map<String, dynamic>? ?? {};
    final cashierMan = shift['cashierman'] as Map<String, dynamic>? ?? {};

    final rawItems = (data?['items'] ?? json['items']) as List<dynamic>? ?? [];
    final items = rawItems
        .map((e) => ReturnItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return ReturnSaleModel(
      id: sale['_id']?.toString() ?? '',
      reference: sale['reference']?.toString() ?? '',
      date: sale['date']?.toString() ?? '',
      customerName: customer?['name']?.toString(),
      warehouseName: warehouse['name']?.toString() ?? '',
      cashierEmail: createdBy['email']?.toString() ?? '',
      cashierName: cashier['name']?.toString() ?? '',
      cashierManName: cashierMan['username']?.toString() ?? '',
      items: items,
    );
  }
}
