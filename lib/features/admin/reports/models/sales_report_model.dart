/// Sales Report Model
/// Represents aggregated sales data for reporting
class SalesReportModel {
  final String id;
  final String reference;
  final DateTime date;
  final String? customerName;
  final String warehouseName;
  final String? cashierName;
  final double grandTotal;
  final double taxAmount;
  final double discountAmount;
  final double paidAmount;
  final double remainingAmount;
  final String saleStatus;
  final int itemsCount;

  SalesReportModel({
    required this.id,
    required this.reference,
    required this.date,
    this.customerName,
    required this.warehouseName,
    this.cashierName,
    required this.grandTotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.saleStatus,
    required this.itemsCount,
  });

  factory SalesReportModel.fromJson(Map<String, dynamic> json) {
    return SalesReportModel(
      id: json['id'] ?? '',
      reference: json['reference'] ?? '',
      date: json['date'] != null 
          ? DateTime.parse(json['date']) 
          : DateTime.now(),
      customerName: json['customers']?['name'],
      warehouseName: json['warehouses']?['name'] ?? '',
      cashierName: json['cashiers']?['name'],
      grandTotal: (json['grand_total'] ?? 0).toDouble(),
      taxAmount: (json['tax_amount'] ?? 0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      paidAmount: (json['paid_amount'] ?? 0).toDouble(),
      remainingAmount: (json['remaining_amount'] ?? 0).toDouble(),
      saleStatus: json['sale_status'] ?? 'completed',
      itemsCount: json['sale_items'] != null 
          ? (json['sale_items'] as List).length 
          : 0,
    );
  }
}

/// Sales Summary for dashboard/overview
class SalesSummary {
  final double totalSales;
  final int totalOrders;
  final double totalTax;
  final double totalDiscounts;
  final double averageOrderValue;
  final List<DailySalesData> dailySales;

  SalesSummary({
    required this.totalSales,
    required this.totalOrders,
    required this.totalTax,
    required this.totalDiscounts,
    required this.averageOrderValue,
    required this.dailySales,
  });
}

/// Daily sales data point for charts
class DailySalesData {
  final DateTime date;
  final double amount;
  final int orderCount;

  DailySalesData({
    required this.date,
    required this.amount,
    required this.orderCount,
  });
}
