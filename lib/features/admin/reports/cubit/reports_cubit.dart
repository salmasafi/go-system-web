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
