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
    final customerJson = json['customer'] ?? json['customer_id'];
    return SaleItemModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      reference: json['reference'] ?? 'N/A',
      customerName: (customerJson is Map) 
          ? customerJson['name'] ?? 'Unknown' 
          : 'Walk-in Customer',
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      status: json['sale_status'] ?? json['status'] ?? 'completed',
      date: json['created_at'] ?? json['date'] ?? json['createdAt'] ?? '',
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
    final customerJson = json['customer'] ?? json['customer_id'];
    final warehouseJson = json['warehouse'] ?? json['warehouse_id'];
    
    return PendingSaleModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      reference: json['reference'] ?? 'PENDING',
      customerName: (customerJson is Map)
          ? customerJson['name'] ?? 'N/A'
          : 'N/A',
      warehouseName: (warehouseJson is Map) ? warehouseJson['name'] ?? '' : '',
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      totalItems: list.length,
      date: json['created_at'] ?? json['date'] ?? json['createdAt'] ?? '',
      status: json['sale_status'] ?? json['status'] ?? 'pending',
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
    final customerJson = json['customer'] ?? json['customer_id'];
    final customer = customerJson is Map ? customerJson : {};
    return DueSaleModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      reference: json['reference'] ?? 'N/A',
      customerId: (customer['id'] ?? customer['_id'] ?? '').toString(),
      customerName: customer['name'] ?? 'Unknown',
      phone: customer['phone_number']?.toString() ?? '',
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (json['remaining_amount'] as num?)?.toDouble() ?? 0.0,
      date: json['created_at'] ?? json['date'] ?? json['createdAt'] ?? '',
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
    final sale = data['sale'] ?? data; // Support both wrapped and direct JSON
    final itemsList = (data['items'] ?? sale['items']) as List? ?? [];

    final customerJson = sale['customer'] ?? sale['customer_id'];
    final warehouseJson = sale['warehouse'] ?? sale['warehouse_id'];

    return SaleDetailModel(
      id: (sale['id'] ?? sale['_id'] ?? '').toString(),
      reference: sale['reference'] ?? '',
      customerId: (customerJson is Map) 
          ? (customerJson['id'] ?? customerJson['_id'] ?? '').toString() 
          : (customerJson ?? '').toString(),
      warehouseId: (warehouseJson is Map) 
          ? (warehouseJson['id'] ?? warehouseJson['_id'] ?? '').toString() 
          : (warehouseJson ?? '').toString(),
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
    
    final productJson = json['product'] ?? json['product_id'];
    
    if (productJson is Map) {
      pName = productJson['name'] ?? '';
      pId = productJson['id'] ?? productJson['_id'] ?? '';
      pImg = productJson['image'] ?? productJson['image_url'];
    } else if (json['product_price_id'] is Map) {
       // fallback
       pName = json['product_price_id']['code'] ?? 'Item';
       pId = json['product_price_id']['id'] ?? json['product_price_id']['_id'] ?? '';
    }

    return SaleDetailItem(
      productId: pId,
      productName: pName,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      image: pImg,
    );
  }
}
