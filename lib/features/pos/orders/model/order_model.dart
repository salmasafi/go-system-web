class OrderModel {
  final String id;
  final String reference;
  final String customerName;
  final String warehouseName;
  final String status;
  final double grandTotal;
  final double paidAmount;
  final double dueAmount;
  final String date;
  final List<OrderItem> items; // ستكون فارغة في القائمة، وممتلئة في التفاصيل

  OrderModel({
    required this.id,
    required this.reference,
    required this.customerName,
    required this.warehouseName,
    required this.status,
    required this.grandTotal,
    required this.paidAmount,
    required this.dueAmount,
    required this.date,
    required this.items,
  });

  // 1. Factory للقائمة (Summary List)
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    String custName = "Walk-in Customer";
    if (json['customer_id'] != null && json['customer_id'] is Map) {
      custName = json['customer_id']['name'] ?? "Unknown";
    }

    String wareName = "Unknown Warehouse";
    if (json['warehouse_id'] != null && json['warehouse_id'] is Map) {
      wareName = json['warehouse_id']['name'] ?? "";
    }

    double total = (json['grand_total'] as num?)?.toDouble() ?? 0.0;
    double paid = (json['paid_amount'] as num?)?.toDouble() ?? 0.0;
    // إذا كان هناك due محسوب من الباك إند، استخدمه، وإلا احسبه
    double due = (json['due_amount'] as num?)?.toDouble() ?? (total - paid);
    if(due < 0) due = 0; // حماية

    return OrderModel(
      id: json['_id'] ?? '',
      reference: json['reference'] ?? 'N/A',
      customerName: custName,
      warehouseName: wareName,
      status: json['sale_status'] ?? (json['order_pending'] == 1 ? 'pending' : 'completed'),
      grandTotal: total,
      paidAmount: paid,
      dueAmount: due,
      date: json['date'] ?? json['createdAt'] ?? '',
      items: [], // القائمة لا تحتوي على منتجات الآن
    );
  }

  // 2. Factory للتفاصيل الكاملة (Detail Response)
  factory OrderModel.fromDetailJson(Map<String, dynamic> data) {
    final saleJson = data['sale']; // الكائن sale
    final itemsJson = data['items'] as List?; // المصفوفة items

    // نستخدم نفس المنطق لاستخراج البيانات الأساسية من saleJson
    String custName = "Walk-in Customer";
    if (saleJson['customer_id'] != null && saleJson['customer_id'] is Map) {
      custName = saleJson['customer_id']['name'] ?? "Unknown";
    }

    String wareName = "";
    if (saleJson['warehouse_id'] != null && saleJson['warehouse_id'] is Map) {
      wareName = saleJson['warehouse_id']['name'] ?? "";
    }

    double total = (saleJson['grand_total'] as num?)?.toDouble() ?? 0.0;
    double paid = (saleJson['paid_amount'] as num?)?.toDouble() ?? 0.0;
    double due = total - paid;
    if(due < 0) due = 0;

    // تحويل المنتجات
    List<OrderItem> productsList = [];
    if (itemsJson != null) {
      productsList = itemsJson.map((e) => OrderItem.fromJson(e)).toList();
    }

    return OrderModel(
      id: saleJson['_id'] ?? '',
      reference: saleJson['reference'] ?? 'N/A',
      customerName: custName,
      warehouseName: wareName,
      status: saleJson['sale_status'] ?? (saleJson['order_pending'] == 1 ? 'pending' : 'completed'),
      grandTotal: total,
      paidAmount: paid,
      dueAmount: due,
      date: saleJson['date'] ?? saleJson['createdAt'] ?? '',
      items: productsList,
    );
  }
}

class OrderItem {
  final String productName;
  final double price;
  final int quantity;
  final double subtotal;
  final String? image;

  OrderItem({
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subtotal,
    this.image,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    String pName = "Unknown Product";
    String? pImage;

    // محاولة استخراج الاسم من product_id إذا كان object
    if (json['product_id'] != null && json['product_id'] is Map) {
      pName = json['product_id']['name'] ?? pName;
      pImage = json['product_id']['image'];
    } 
    // محاولة استخراج الاسم من product_price_id إذا لم يوجد في product_id
    else if (json['product_price_id'] != null && json['product_price_id'] is Map) {
       // في بعض الردود قد يكون الكود هو الاسم البديل
       pName = json['product_price_id']['code'] ?? pName; 
    }

    double itemPrice = (json['price'] as num?)?.toDouble() ?? 0.0;
    int qty = (json['quantity'] as num?)?.toInt() ?? 1;
    double sub = (json['subtotal'] as num?)?.toDouble() ?? (itemPrice * qty);

    return OrderItem(
      productName: pName,
      price: itemPrice,
      quantity: qty,
      subtotal: sub,
      image: pImage,
    );
  }
}