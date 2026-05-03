/// Inventory Report Model
/// Represents inventory movement and stock data
class InventoryReportModel {
  final String id;
  final String reference;
  final DateTime date;
  final String warehouseName;
  final String type;
  final String productName;
  final int quantity;
  final int currentStock;
  final int newStock;
  final String? reason;
  final String status;

  InventoryReportModel({
    required this.id,
    required this.reference,
    required this.date,
    required this.warehouseName,
    required this.type,
    required this.productName,
    required this.quantity,
    required this.currentStock,
    required this.newStock,
    this.reason,
    required this.status,
  });

  factory InventoryReportModel.fromJson(Map<String, dynamic> json) {
    return InventoryReportModel(
      id: json['id'] ?? '',
      reference: json['reference'] ?? '',
      date: json['date'] != null 
          ? DateTime.parse(json['date']) 
          : DateTime.now(),
      warehouseName: json['warehouses']?['name'] ?? '',
      type: json['type'] ?? 'adjustment',
      productName: json['products']?['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      currentStock: json['current_stock'] ?? 0,
      newStock: json['new_stock'] ?? 0,
      reason: json['reason'],
      status: json['status'] ?? 'approved',
    );
  }
}

/// Warehouse Stock Report
class WarehouseStockReport {
  final String warehouseId;
  final String warehouseName;
  final int totalProducts;
  final int totalQuantity;
  final double totalValue;
  final List<StockItem> stockItems;

  WarehouseStockReport({
    required this.warehouseId,
    required this.warehouseName,
    required this.totalProducts,
    required this.totalQuantity,
    required this.totalValue,
    required this.stockItems,
  });
}

/// Individual stock item
class StockItem {
  final String productId;
  final String productName;
  final String? productCode;
  final int quantity;
  final double unitCost;
  final double totalValue;
  final int lowStockThreshold;
  final bool isLowStock;

  StockItem({
    required this.productId,
    required this.productName,
    this.productCode,
    required this.quantity,
    required this.unitCost,
    required this.totalValue,
    required this.lowStockThreshold,
    required this.isLowStock,
  });
}

/// Inventory Movement Summary
class InventoryMovementSummary {
  final int totalAdjustments;
  final int totalTransfers;
  final int totalPurchases;
  final int totalReturns;
  final int stockIn;
  final int stockOut;
  final List<MovementData> recentMovements;

  InventoryMovementSummary({
    required this.totalAdjustments,
    required this.totalTransfers,
    required this.totalPurchases,
    required this.totalReturns,
    required this.stockIn,
    required this.stockOut,
    required this.recentMovements,
  });
}

/// Movement data point
class MovementData {
  final DateTime date;
  final String type;
  final int quantity;
  final String reference;

  MovementData({
    required this.date,
    required this.type,
    required this.quantity,
    required this.reference,
  });
}
