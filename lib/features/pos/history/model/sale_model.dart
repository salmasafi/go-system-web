// lib/features/orders/data/models/pos_sales_models.dart

// 1. موديل البيعة العامة (للقائمة الرئيسية - Sales)
class SaleItemModel {
  final String id;
  final String reference;
  final String customerName;
  final double grandTotal;
  final String status;
  final String date;

  SaleItemModel({
    required this.id,
    required this.reference,
    required this.customerName,
    required this.grandTotal,
    required this.status,
    required this.date,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      id: json['_id'] ?? '',
      reference: json['reference'] ?? 'N/A',
      customerName: (json['customer_id'] is Map) 
          ? json['customer_id']['name'] ?? 'Unknown' 
          : 'Walk-in Customer',
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      status: json['sale_status'] ?? 'completed',
      date: json['date'] ?? json['createdAt'] ?? '',
    );
  }
}

// 2. موديل البيعة المعلقة (Pending Sales)
class PendingSaleModel {
  final String id;
  final String reference;
  final String customerName;
  final String warehouseName;
  final double grandTotal;
  final int totalItems;
  final String date;
  final String status;

  PendingSaleModel({
    required this.id,
    required this.reference,
    required this.customerName,
    required this.warehouseName,
    required this.grandTotal,
    required this.totalItems,
    required this.date,
    required this.status,
  });

  factory PendingSaleModel.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List? ?? [];
    final warehouse = json['warehouse_id'] is Map ? json['warehouse_id'] : {};
    return PendingSaleModel(
      id: json['_id'] ?? '',
      reference: json['reference'] ?? 'PENDING',
      customerName: (json['customer_id'] is Map)
          ? json['customer_id']['name'] ?? 'N/A'
          : 'N/A',
      warehouseName: warehouse['name'] ?? '',
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      totalItems: list.length,
      date: json['date'] ?? json['createdAt'] ?? '',
      status: json['sale_status'] ?? 'pending',
    );
  }
}

// 3. موديل الديون (Dues) - يركز على العميل والمبلغ المتبقي
class DueSaleModel {
  final String id;
  final String reference;
  final String customerId;
  final String customerName;
  final String phone;
  final double grandTotal;
  final double paidAmount;
  final double remainingAmount;
  final String date;

  DueSaleModel({
    required this.id,
    required this.reference,
    required this.customerId,
    required this.customerName,
    required this.phone,
    required this.grandTotal,
    required this.paidAmount,
    required this.remainingAmount,
    required this.date,
  });

  factory DueSaleModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer_id'] is Map ? json['customer_id'] : {};
    return DueSaleModel(
      id: json['_id'] ?? '',
      reference: json['reference'] ?? 'N/A',
      customerId: customer['_id'] ?? '',
      customerName: customer['name'] ?? 'Unknown',
      phone: customer['phone_number'] ?? '',
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (json['remaining_amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] ?? json['createdAt'] ?? '',
    );
  }
}

// 3b. موديل العميل المجمّع (Grouped by customer)
class CustomerDueModel {
  final String customerId;
  final String customerName;
  final String phone;
  final double totalDue;
  final List<DueSaleModel> sales;

  CustomerDueModel({
    required this.customerId,
    required this.customerName,
    required this.phone,
    required this.totalDue,
    required this.sales,
  });

  /// أول sale id - يُستخدم كـ representative للدفع
  String get firstSaleId => sales.isNotEmpty ? sales.first.id : '';
}

// 4. موديل التفاصيل الكاملة (Full Details for Checkout)
class SaleDetailModel {
  final String id;
  final String reference;
  final String customerId; // نحتاج الـ ID لإتمام البيع
  final String warehouseId;
  final double grandTotal;
  final double taxAmount;
  final double discount;
  final List<SaleDetailItem> items;

  SaleDetailModel({
    required this.id,
    required this.reference,
    required this.customerId,
    required this.warehouseId,
    required this.grandTotal,
    required this.taxAmount,
    required this.discount,
    required this.items,
  });

  factory SaleDetailModel.fromJson(Map<String, dynamic> data) {
    final sale = data['sale'];
    final itemsList = data['items'] as List? ?? [];

    return SaleDetailModel(
      id: sale['_id'] ?? '',
      reference: sale['reference'] ?? '',
      customerId: (sale['customer_id'] is Map) ? sale['customer_id']['_id'] : '',
      warehouseId: (sale['warehouse_id'] is Map) ? sale['warehouse_id']['_id'] : '',
      grandTotal: (sale['grand_total'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (sale['tax_amount'] as num?)?.toDouble() ?? 0.0,
      discount: (sale['discount'] as num?)?.toDouble() ?? 0.0,
      items: itemsList.map((e) => SaleDetailItem.fromJson(e)).toList(),
    );
  }
}

class SaleDetailItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final double subtotal;
  final String? image;

  SaleDetailItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.subtotal,
    this.image,
  });

  factory SaleDetailItem.fromJson(Map<String, dynamic> json) {
    // التعامل مع المنتج المتداخل
    String pName = '';
    String pId = '';
    String? pImg;
    
    if (json['product_id'] is Map) {
      pName = json['product_id']['name'];
      pId = json['product_id']['_id'];
      pImg = json['product_id']['image'];
    } else if (json['product_price_id'] is Map) {
       // fallback
       pName = json['product_price_id']['code'] ?? 'Item';
       pId = json['product_price_id']['_id'];
    }

    return SaleDetailItem(
      productId: pId,
      productName: pName,
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      image: pImg,
    );
  }
}
