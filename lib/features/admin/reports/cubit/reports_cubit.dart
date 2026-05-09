import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/reports_repository.dart';
import 'reports_state.dart';

/// Cubit for managing reports data and state
class ReportsCubit extends Cubit<ReportsState> {
  final ReportsRepository _repository;

  ReportsCubit({ReportsRepository? repository})
      : _repository = repository ?? ReportsRepository(),
        super(ReportsInitial());

  // ==================== SALES REPORTS ====================

  /// Load sales report with optional date filtering
  Future<void> loadSalesReport({DateTime? startDate, DateTime? endDate}) async {
    emit(ReportsLoading());
    try {
      log('ReportsCubit: Loading sales report');
      
      final sales = await _repository.getSalesReport(
        startDate: startDate,
        endDate: endDate,
      );
      
      final summary = await _repository.getSalesSummary(
        startDate: startDate,
        endDate: endDate,
      );
      
      emit(SalesReportLoaded(
        sales: sales,
        summary: summary,
        startDate: startDate,
        endDate: endDate,
      ));
      
      log('ReportsCubit: Sales report loaded - ${sales.length} records');
    } catch (e) {
      log('ReportsCubit: Error loading sales report - $e');
      emit(ReportsError(e.toString()));
    }
  }

  // ==================== PRODUCT REPORTS ====================

  /// Load product report with optional filtering
  Future<void> loadProductReport({String? categoryId, String? brandId}) async {
    emit(ReportsLoading());
    try {
      log('ReportsCubit: Loading product report');
      
      final products = await _repository.getProductReport(
        categoryId: categoryId,
        brandId: brandId,
      );
      
      final summary = await _repository.getProductPerformanceSummary();
      
      emit(ProductReportLoaded(
        products: products,
        summary: summary,
      ));
      
      log('ReportsCubit: Product report loaded - ${products.length} products');
    } catch (e) {
      log('ReportsCubit: Error loading product report - $e');
      emit(ReportsError(e.toString()));
    }
  }

  // ==================== INVENTORY REPORTS ====================

  /// Load inventory report with optional warehouse filtering
  Future<void> loadInventoryReport({String? warehouseId}) async {
    emit(ReportsLoading());
    try {
      log('ReportsCubit: Loading inventory report');
      
      final movements = await _repository.getInventoryReport(
        warehouseId: warehouseId,
      );
      
      final warehouseReports = await _repository.getWarehouseStockReports();
      final summary = await _repository.getInventoryMovementSummary();
      
      emit(InventoryReportLoaded(
        movements: movements,
        warehouseReports: warehouseReports,
        summary: summary,
      ));
      
      log('ReportsCubit: Inventory report loaded - ${movements.length} movements');
    } catch (e) {
      log('ReportsCubit: Error loading inventory report - $e');
      emit(ReportsError(e.toString()));
    }
  }

  // ==================== FINANCIAL REPORTS ====================

  /// Load financial report with optional date filtering
  Future<void> loadFinancialReport({DateTime? startDate, DateTime? endDate}) async {
    emit(ReportsLoading());
    try {
      log('ReportsCubit: Loading financial report');
      
      final transactions = await _repository.getFinancialReport(
        startDate: startDate,
        endDate: endDate,
      );
      
      final summary = await _repository.getFinancialSummary(
        startDate: startDate,
        endDate: endDate,
      );
      
      emit(FinancialReportLoaded(
        transactions: transactions,
        summary: summary,
        startDate: startDate,
        endDate: endDate,
      ));
      
      log('ReportsCubit: Financial report loaded - ${transactions.length} transactions');
    } catch (e) {
      log('ReportsCubit: Error loading financial report - $e');
      emit(ReportsError(e.toString()));
    }
  }

  // ==================== SHIFT REPORTS ====================

  /// Load shift report with optional date filtering
  Future<void> loadShiftReport({DateTime? startDate, DateTime? endDate}) async {
    emit(ReportsLoading());
    try {
      log('ReportsCubit: Loading shift report');
      
      final shifts = await _repository.getShiftReport(
        startDate: startDate,
        endDate: endDate,
      );
      
      final summary = await _repository.getShiftSummary(
        startDate: startDate,
        endDate: endDate,
      );
      
      final performance = await _repository.getCashierPerformance(
        startDate: startDate,
        endDate: endDate,
      );
      
      emit(ShiftReportLoaded(
        shifts: shifts,
        summary: summary,
        performance: performance,
        startDate: startDate,
        endDate: endDate,
      ));
      
      log('ReportsCubit: Shift report loaded - ${shifts.length} shifts');
    } catch (e) {
      log('ReportsCubit: Error loading shift report - $e');
      emit(ReportsError(e.toString()));
    }
  }

  // ==================== CASHIER DAILY REVENUE ====================

  /// Load cashier daily revenue breakdown by payment method
  Future<void> loadCashierDailyRevenue({DateTime? date}) async {
    emit(ReportsLoading());
    final targetDate = date ?? DateTime.now();
    try {
      log('ReportsCubit: Loading cashier daily revenue for $targetDate');
      final client = _repository.client;

      // Breakdown by payment method
      final rawEntries = await client.rpc(
        'get_cashier_daily_revenue',
        params: {'p_date': targetDate.toIso8601String().split('T')[0]},
      );

      final entries = (rawEntries as List).map((r) => CashierRevenueEntry(
            cashierId: r['cashier_id'].toString(),
            cashierName: r['cashier_name'].toString(),
            paymentType: r['payment_type'].toString(),
            totalAmount: (r['total_amount'] as num?)?.toDouble() ?? 0.0,
          )).toList();

      // Grand totals per cashier
      final rawTotals = await client.rpc(
        'get_cashier_daily_total',
        params: {'p_date': targetDate.toIso8601String().split('T')[0]},
      );

      final totals = (rawTotals as List).map((r) => CashierDailyTotal(
            cashierId: r['cashier_id'].toString(),
            cashierName: r['cashier_name'].toString(),
            totalAmount: (r['total_amount'] as num?)?.toDouble() ?? 0.0,
            saleCount: (r['sale_count'] as num?)?.toInt() ?? 0,
          )).toList();

      emit(CashierDailyRevenueLoaded(
        date: targetDate,
        entries: entries,
        totals: totals,
      ));
      log('ReportsCubit: Cashier revenue loaded - ${totals.length} cashiers');
    } catch (e) {
      log('ReportsCubit: Error loading cashier revenue - $e');
      emit(ReportsError(e.toString()));
    }
  }

  /// Refresh current report based on state
  Future<void> refresh() async {
    final currentState = state;
    
    if (currentState is SalesReportLoaded) {
      await loadSalesReport(
        startDate: currentState.startDate,
        endDate: currentState.endDate,
      );
    } else if (currentState is ProductReportLoaded) {
      await loadProductReport();
    } else if (currentState is InventoryReportLoaded) {
      await loadInventoryReport();
    } else if (currentState is FinancialReportLoaded) {
      await loadFinancialReport(
        startDate: currentState.startDate,
        endDate: currentState.endDate,
      );
    } else if (currentState is ShiftReportLoaded) {
      await loadShiftReport(
        startDate: currentState.startDate,
        endDate: currentState.endDate,
      );
    }
  }
}
