// lib/features/orders/data/models/pos_sales_models.dart

// ... existing models (SaleItemModel, PendingSaleModel, DueSaleModel) ...

class PendingSaleDetailsModel {
  final String id;
  final String reference;
  final String date;
  final double grandTotal;
  final double subTotal;
  final double taxAmount;
  final double discount;
  final String note;
  final CustomerInfo customer;
  final WarehouseInfo warehouse;
  final CashierInfo cashier;
  final List<PendingSaleProductItem> products;
  // Payload for recreating the sale easily
  final Map<String, dynamic> payloadForCreateSale;

  PendingSaleDetailsModel({
    required this.id,
    required this.reference,
    required this.date,
    required this.grandTotal,
    required this.subTotal,
    required this.taxAmount,
    required this.discount,
    required this.note,
    required this.customer,
    required this.warehouse,
    required this.cashier,
    required this.products,
    required this.payloadForCreateSale,
  });

  factory PendingSaleDetailsModel.fromJson(Map<String, dynamic> json) {
    final sale = json['sale'] ?? {};
    final productsList = json['products'] as List? ?? [];

    return PendingSaleDetailsModel(
      id: sale['_id'] ?? '',
      reference: sale['reference'] ?? '',
      date: sale['date'] ?? '',
      grandTotal: (sale['grand_total'] as num?)?.toDouble() ?? 0.0,
      subTotal: (sale['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (sale['tax_amount'] as num?)?.toDouble() ?? 0.0,
      discount: (sale['discount'] as num?)?.toDouble() ?? 0.0,
      note: sale['note'] ?? '',
      customer: CustomerInfo.fromJson(sale['customer'] ?? {}),
      warehouse: WarehouseInfo.fromJson(sale['warehouse'] ?? {}),
      cashier: CashierInfo.fromJson(sale['cashier'] ?? {}),
      products: productsList.map((e) => PendingSaleProductItem.fromJson(e)).toList(),
      payloadForCreateSale: json['payloadForCreateSale'] ?? {},
    );
  }
}

class CustomerInfo {
  final String id;
  final String name;
  final String email;
  final String phone;

  CustomerInfo({required this.id, required this.name, required this.email, required this.phone});

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      phone: json['phone_number'] ?? '',
    );
  }
}

class WarehouseInfo {
  final String id;
  final String name;

  WarehouseInfo({required this.id, required this.name});

  factory WarehouseInfo.fromJson(Map<String, dynamic> json) {
    return WarehouseInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class CashierInfo {
  final String id;
  final String email;

  CashierInfo({required this.id, required this.email});

  factory CashierInfo.fromJson(Map<String, dynamic> json) {
    return CashierInfo(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class PendingSaleProductItem {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double price; // Unit price from sales record
  final int quantity;
  final double subtotal;

  PendingSaleProductItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory PendingSaleProductItem.fromJson(Map<String, dynamic> json) {
    // Determine Product Name & ID
    String pName = '';
    String pId = '';
    String pImg = '';
    
    if (json['product'] is Map) {
      pName = json['product']['name'] ?? '';
      pId = json['product']['_id'] ?? '';
      pImg = json['product']['image'] ?? '';
    }

    return PendingSaleProductItem(
      id: json['_id'] ?? '',
      productId: pId,
      productName: pName,
      productImage: pImg,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
