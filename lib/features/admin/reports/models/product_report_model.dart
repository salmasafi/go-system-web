/// Product Report Model
/// Represents product performance and inventory data
class ProductReportModel {
  final String id;
  final String name;
  final String code;
  final String? categoryName;
  final String? brandName;
  final double price;
  final double cost;
  final int totalQuantity;
  final int totalSold;
  final double totalRevenue;
  final int lowStock;
  final bool status;

  ProductReportModel({
    required this.id,
    required this.name,
    required this.code,
    this.categoryName,
    this.brandName,
    required this.price,
    required this.cost,
    required this.totalQuantity,
    required this.totalSold,
    required this.totalRevenue,
    required this.lowStock,
    required this.status,
  });

  factory ProductReportModel.fromJson(Map<String, dynamic> json) {
    final productWarehouses = json['product_warehouses'] as List? ?? [];
    final totalQty = productWarehouses.fold<int>(
      0, 
      (sum, pw) => sum + ((pw['quantity'] ?? 0) as int),
    );
    
    final saleItems = json['sale_items'] as List? ?? [];
    final totalSold = saleItems.fold<int>(
      0, 
      (sum, si) => sum + ((si['quantity'] ?? 0) as int),
    );
    
    final revenue = saleItems.fold<double>(
      0, 
      (sum, si) => sum + ((si['subtotal'] ?? 0) as num).toDouble(),
    );

    // Extract category name safely
    String? categoryName;
    final categories = json['categories'] as List?;
    if (categories != null && categories.isNotEmpty) {
      final firstCat = categories[0] as Map<String, dynamic>?;
      final categoryData = firstCat?['categories'] as Map<String, dynamic>?;
      categoryName = categoryData?['name'] as String?;
    }

    return ProductReportModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      categoryName: categoryName,
      brandName: json['brands']?['name'] as String?,
      price: (json['price'] ?? 0).toDouble(),
      cost: (json['cost'] ?? 0).toDouble(),
      totalQuantity: totalQty,
      totalSold: totalSold,
      totalRevenue: revenue,
      lowStock: json['low_stock'] ?? 0,
      status: json['status'] ?? true,
    );
  }
}

/// Product Performance Summary
class ProductPerformanceSummary {
  final int totalProducts;
  final int lowStockProducts;
  final int outOfStockProducts;
  final double totalInventoryValue;
  final List<TopProduct> topSellingProducts;
  final List<TopProduct> topRevenueProducts;

  ProductPerformanceSummary({
    required this.totalProducts,
    required this.lowStockProducts,
    required this.outOfStockProducts,
    required this.totalInventoryValue,
    required this.topSellingProducts,
    required this.topRevenueProducts,
  });
}

/// Top product data
class TopProduct {
  final String id;
  final String name;
  final int quantity;
  final double revenue;

  TopProduct({
    required this.id,
    required this.name,
    required this.quantity,
    required this.revenue,
  });
}
