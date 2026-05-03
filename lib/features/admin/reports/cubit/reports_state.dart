import '../models/sales_report_model.dart';
import '../models/product_report_model.dart';
import '../models/inventory_report_model.dart';
import '../models/financial_report_model.dart';
import '../models/shift_report_model.dart';

/// Base state for all reports
abstract class ReportsState {}

/// Initial state
class ReportsInitial extends ReportsState {}

/// Loading state
class ReportsLoading extends ReportsState {}

/// Error state
class ReportsError extends ReportsState {
  final String message;

  ReportsError(this.message);
}

// ==================== SALES REPORT STATES ====================

/// Sales report loaded state
class SalesReportLoaded extends ReportsState {
  final List<SalesReportModel> sales;
  final SalesSummary? summary;
  final DateTime? startDate;
  final DateTime? endDate;

  SalesReportLoaded({
    required this.sales,
    this.summary,
    this.startDate,
    this.endDate,
  });
}

// ==================== PRODUCT REPORT STATES ====================

/// Product report loaded state
class ProductReportLoaded extends ReportsState {
  final List<ProductReportModel> products;
  final ProductPerformanceSummary? summary;

  ProductReportLoaded({
    required this.products,
    this.summary,
  });
}

// ==================== INVENTORY REPORT STATES ====================

/// Inventory report loaded state
class InventoryReportLoaded extends ReportsState {
  final List<InventoryReportModel> movements;
  final List<WarehouseStockReport>? warehouseReports;
  final InventoryMovementSummary? summary;

  InventoryReportLoaded({
    required this.movements,
    this.warehouseReports,
    this.summary,
  });
}

// ==================== FINANCIAL REPORT STATES ====================

/// Financial report loaded state
class FinancialReportLoaded extends ReportsState {
  final List<FinancialReportModel> transactions;
  final FinancialSummary? summary;
  final DateTime? startDate;
  final DateTime? endDate;

  FinancialReportLoaded({
    required this.transactions,
    this.summary,
    this.startDate,
    this.endDate,
  });
}

// ==================== SHIFT REPORT STATES ====================

/// Shift report loaded state
class ShiftReportLoaded extends ReportsState {
  final List<ShiftReportModel> shifts;
  final ShiftSummary? summary;
  final List<CashierPerformance>? performance;
  final DateTime? startDate;
  final DateTime? endDate;

  ShiftReportLoaded({
    required this.shifts,
    this.summary,
    this.performance,
    this.startDate,
    this.endDate,
  });
}
