import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../models/sales_report_model.dart';
import '../../models/product_report_model.dart';
import '../../models/inventory_report_model.dart';
import '../../models/financial_report_model.dart';
import '../../models/shift_report_model.dart';

/// Interface for reports data operations
abstract class ReportsRepositoryInterface {
  // Sales Reports
  Future<List<SalesReportModel>> getSalesReport({DateTime? startDate, DateTime? endDate});
  Future<SalesSummary> getSalesSummary({DateTime? startDate, DateTime? endDate});
  
  // Product Reports
  Future<List<ProductReportModel>> getProductReport({String? categoryId, String? brandId});
  Future<ProductPerformanceSummary> getProductPerformanceSummary();
  
  // Inventory Reports
  Future<List<InventoryReportModel>> getInventoryReport({String? warehouseId});
  Future<List<WarehouseStockReport>> getWarehouseStockReports();
  Future<InventoryMovementSummary> getInventoryMovementSummary();
  
  // Financial Reports
  Future<List<FinancialReportModel>> getFinancialReport({DateTime? startDate, DateTime? endDate});
  Future<FinancialSummary> getFinancialSummary({DateTime? startDate, DateTime? endDate});
  
  // Shift Reports
  Future<List<ShiftReportModel>> getShiftReport({DateTime? startDate, DateTime? endDate});
  Future<ShiftSummary> getShiftSummary({DateTime? startDate, DateTime? endDate});
  Future<List<CashierPerformance>> getCashierPerformance({DateTime? startDate, DateTime? endDate});
}

/// Reports repository using Supabase
class ReportsRepository implements ReportsRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  // ==================== SALES REPORTS ====================
  
  @override
  Future<List<SalesReportModel>> getSalesReport({DateTime? startDate, DateTime? endDate}) async {
    try {
      log('ReportsRepository: Fetching sales report');
      
      var query = _client
          .from('sales')
          .select('''
            *,
            customers(name),
            warehouses(name),
            cashiers(name),
            sale_items(id)
          ''');
      
      if (startDate != null) {
        query = query.gte('date', startDate.toIso8601String().split('T')[0]);
      }
      if (endDate != null) {
        query = query.lte('date', endDate.toIso8601String().split('T')[0]);
      }
      
      final response = await query.order('created_at', ascending: false);
      
      final reports = (response as List)
          .map((json) => SalesReportModel.fromJson(json))
          .toList();
      
      log('ReportsRepository: Fetched ${reports.length} sales records');
      return reports;
    } catch (e) {
      log('ReportsRepository: Error fetching sales report - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<SalesSummary> getSalesSummary({DateTime? startDate, DateTime? endDate}) async {
    try {
      log('ReportsRepository: Fetching sales summary');
      
      final sales = await getSalesReport(startDate: startDate, endDate: endDate);
      
      final totalSales = sales.fold<double>(0, (sum, s) => sum + s.grandTotal);
      final totalTax = sales.fold<double>(0, (sum, s) => sum + s.taxAmount);
      final totalDiscounts = sales.fold<double>(0, (sum, s) => sum + s.discountAmount);
      final double avgOrderValue = sales.isEmpty ? 0.0 : (totalSales / sales.length).toDouble();
      
      // Group by date for daily data
      final dailyDataMap = <String, DailySalesData>{};
      for (final sale in sales) {
        final dateKey = sale.date.toIso8601String().split('T')[0];
        if (dailyDataMap.containsKey(dateKey)) {
          final existing = dailyDataMap[dateKey]!;
          dailyDataMap[dateKey] = DailySalesData(
            date: sale.date,
            amount: existing.amount + sale.grandTotal,
            orderCount: existing.orderCount + 1,
          );
        } else {
          dailyDataMap[dateKey] = DailySalesData(
            date: sale.date,
            amount: sale.grandTotal,
            orderCount: 1,
          );
        }
      }
      
      return SalesSummary(
        totalSales: totalSales,
        totalOrders: sales.length,
        totalTax: totalTax,
        totalDiscounts: totalDiscounts,
        averageOrderValue: avgOrderValue,
        dailySales: dailyDataMap.values.toList()..sort((a, b) => a.date.compareTo(b.date)),
      );
    } catch (e) {
      log('ReportsRepository: Error fetching sales summary - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  // ==================== PRODUCT REPORTS ====================
  
  @override
  Future<List<ProductReportModel>> getProductReport({String? categoryId, String? brandId}) async {
    try {
      log('ReportsRepository: Fetching product report');
      
      var query = _client
          .from('products')
          .select('''
            *,
            product_warehouses(quantity),
            sale_items(quantity, subtotal),
            product_categories(categories(name)),
            brands(name)
          ''');
      
      if (categoryId != null) {
        query = query.eq('product_categories.category_id', categoryId);
      }
      if (brandId != null) {
        query = query.eq('brand_id', brandId);
      }
      
      final response = await query.order('name');
      
      final reports = (response as List)
          .map((json) => ProductReportModel.fromJson(json))
          .toList();
      
      log('ReportsRepository: Fetched ${reports.length} products');
      return reports;
    } catch (e) {
      log('ReportsRepository: Error fetching product report - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<ProductPerformanceSummary> getProductPerformanceSummary() async {
    try {
      log('ReportsRepository: Fetching product performance summary');
      
      final products = await getProductReport();
      
      final lowStock = products.where((p) => p.totalQuantity <= p.lowStock && p.totalQuantity > 0).length;
      final outOfStock = products.where((p) => p.totalQuantity == 0).length;
      final inventoryValue = products.fold<double>(
        0, 
        (sum, p) => sum + (p.totalQuantity * p.cost),
      );
      
      // Top selling products
      final sortedByQuantity = products.toList()
        ..sort((a, b) => b.totalSold.compareTo(a.totalSold));
      final topSelling = sortedByQuantity.take(10).map((p) => TopProduct(
        id: p.id,
        name: p.name,
        quantity: p.totalSold,
        revenue: p.totalRevenue,
      )).toList();
      
      // Top revenue products
      final sortedByRevenue = products.toList()
        ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
      final topRevenue = sortedByRevenue.take(10).map((p) => TopProduct(
        id: p.id,
        name: p.name,
        quantity: p.totalSold,
        revenue: p.totalRevenue,
      )).toList();
      
      return ProductPerformanceSummary(
        totalProducts: products.length,
        lowStockProducts: lowStock,
        outOfStockProducts: outOfStock,
        totalInventoryValue: inventoryValue,
        topSellingProducts: topSelling,
        topRevenueProducts: topRevenue,
      );
    } catch (e) {
      log('ReportsRepository: Error fetching product performance summary - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  // ==================== INVENTORY REPORTS ====================
  
  @override
  Future<List<InventoryReportModel>> getInventoryReport({String? warehouseId}) async {
    try {
      log('ReportsRepository: Fetching inventory report');
      
      var query = _client
          .from('adjustments')
          .select('''
            *,
            warehouses(name),
            products(name)
          ''');
      
      if (warehouseId != null) {
        query = query.eq('warehouse_id', warehouseId);
      }
      
      final response = await query.order('date', ascending: false);
      
      final reports = (response as List)
          .map((json) => InventoryReportModel.fromJson(json))
          .toList();
      
      log('ReportsRepository: Fetched ${reports.length} inventory adjustments');
      return reports;
    } catch (e) {
      log('ReportsRepository: Error fetching inventory report - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<WarehouseStockReport>> getWarehouseStockReports() async {
    try {
      log('ReportsRepository: Fetching warehouse stock reports');
      
      // Get all warehouses
      final warehousesResponse = await _client
          .from('warehouses')
          .select('id, name');
      
      final warehouses = warehousesResponse as List;
      final reports = <WarehouseStockReport>[];
      
      for (final wh in warehouses) {
        final warehouseId = wh['id'] as String;
        final warehouseName = wh['name'] as String;
        
        // Get stock for this warehouse
        final stockResponse = await _client
            .from('product_warehouses')
            .select('''
              *,
              products(id, name, code, cost, low_stock)
            ''')
            .eq('warehouse_id', warehouseId);
        
        final stockItems = (stockResponse as List).map((item) {
          final product = item['products'] as Map<String, dynamic>;
          final qty = (item['quantity'] ?? 0) as int;
          final cost = (product['cost'] ?? 0).toDouble();
          final lowStock = product['low_stock'] ?? 0;
          
          return StockItem(
            productId: product['id'] ?? '',
            productName: product['name'] ?? '',
            productCode: product['code'],
            quantity: qty,
            unitCost: cost,
            totalValue: (qty * cost).toDouble(),
            lowStockThreshold: lowStock,
            isLowStock: qty <= lowStock && qty > 0,
          );
        }).toList();
        
        final totalQty = stockItems.fold<int>(0, (sum, s) => sum + s.quantity);
        final totalValue = stockItems.fold<double>(0, (sum, s) => sum + s.totalValue);
        
        reports.add(WarehouseStockReport(
          warehouseId: warehouseId,
          warehouseName: warehouseName,
          totalProducts: stockItems.length,
          totalQuantity: totalQty,
          totalValue: totalValue,
          stockItems: stockItems,
        ));
      }
      
      return reports;
    } catch (e) {
      log('ReportsRepository: Error fetching warehouse stock reports - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<InventoryMovementSummary> getInventoryMovementSummary() async {
    try {
      log('ReportsRepository: Fetching inventory movement summary');
      
      // Get adjustments count
      final adjustmentsResponse = await _client
          .from('adjustments')
          .select('id');
      
      // Get transfers count
      final transfersResponse = await _client
          .from('transfers')
          .select('id');
      
      // Get recent movements
      final recentAdjustments = await _client
          .from('adjustments')
          .select('date, type, quantity, reference')
          .order('date', ascending: false)
          .limit(20);
      
      final recentMovements = (recentAdjustments as List).map((json) => MovementData(
        date: DateTime.parse(json['date']),
        type: json['type'] ?? 'adjustment',
        quantity: json['quantity'] ?? 0,
        reference: json['reference'] ?? '',
      )).toList();
      
      // Calculate stock in/out
      final adjustments = await _client
          .from('adjustments')
          .select('type, quantity');
      
      int stockIn = 0;
      int stockOut = 0;
      
      for (final adj in adjustments as List) {
        final type = adj['type'] as String?;
        final qty = (adj['quantity'] ?? 0) as int;
        if (type == 'addition') {
          stockIn += qty;
        } else if (type == 'subtraction') {
          stockOut += qty;
        }
      }
      
      return InventoryMovementSummary(
        totalAdjustments: adjustmentsResponse.length,
        totalTransfers: transfersResponse.length,
        totalPurchases: 0, // Will need separate query
        totalReturns: 0, // Will need separate query
        stockIn: stockIn,
        stockOut: stockOut,
        recentMovements: recentMovements,
      );
    } catch (e) {
      log('ReportsRepository: Error fetching inventory movement summary - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  // ==================== FINANCIAL REPORTS ====================
  
  @override
  Future<List<FinancialReportModel>> getFinancialReport({DateTime? startDate, DateTime? endDate}) async {
    try {
      log('ReportsRepository: Fetching financial report');
      
      // Get revenues - apply filters before order
      var revenueQuery = _client
          .from('revenues')
          .select('''
            *,
            revenue_categories(name),
            bank_accounts(name),
            admins(username)
          ''');
      
      // Get expenses - apply filters before order
      var expenseQuery = _client
          .from('expenses')
          .select('''
            *,
            expense_categories(name),
            bank_accounts(name),
            admins(username)
          ''');
      
      if (startDate != null) {
        final startStr = startDate.toIso8601String();
        revenueQuery = revenueQuery.gte('created_at', startStr);
        expenseQuery = expenseQuery.gte('created_at', startStr);
      }
      if (endDate != null) {
        final endStr = endDate.toIso8601String();
        revenueQuery = revenueQuery.lte('created_at', endStr);
        expenseQuery = expenseQuery.lte('created_at', endStr);
      }
      
      // Apply order after filters
      final revenuesResponse = await revenueQuery.order('created_at', ascending: false);
      final expensesResponse = await expenseQuery.order('created_at', ascending: false);
      
      final reports = <FinancialReportModel>[];
      
      for (final json in revenuesResponse as List) {
        reports.add(FinancialReportModel.fromRevenueJson(json));
      }
      
      for (final json in expensesResponse as List) {
        reports.add(FinancialReportModel.fromExpenseJson(json));
      }
      
      // Sort by date descending
      reports.sort((a, b) => b.date.compareTo(a.date));
      
      log('ReportsRepository: Fetched ${reports.length} financial records');
      return reports;
    } catch (e) {
      log('ReportsRepository: Error fetching financial report - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<FinancialSummary> getFinancialSummary({DateTime? startDate, DateTime? endDate}) async {
    try {
      log('ReportsRepository: Fetching financial summary');
      
      final transactions = await getFinancialReport(startDate: startDate, endDate: endDate);
      
      final revenues = transactions.where((t) => t.type == 'revenue').toList();
      final expenses = transactions.where((t) => t.type == 'expense').toList();
      
      final totalRevenue = revenues.fold<double>(0, (sum, r) => sum + r.amount);
      final totalExpenses = expenses.fold<double>(0, (sum, e) => sum + e.amount);
      
      // Get bank account balances
      final accountsResponse = await _client
          .from('bank_accounts')
          .select('id, name, balance, initial_balance, account_type');
      
      final bankAccounts = (accountsResponse as List).map((json) => BankAccountBalance(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        balance: (json['balance'] ?? 0).toDouble(),
        initialBalance: (json['initial_balance'] ?? 0).toDouble(),
        accountType: json['account_type'],
      )).toList();
      
      return FinancialSummary(
        totalRevenue: totalRevenue,
        totalExpenses: totalExpenses,
        netIncome: totalRevenue - totalExpenses,
        totalTaxCollected: 0, // Will need separate query
        bankAccounts: bankAccounts,
        monthlyData: [], // Will implement grouping by month
      );
    } catch (e) {
      log('ReportsRepository: Error fetching financial summary - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  // ==================== SHIFT REPORTS ====================
  
  @override
  Future<List<ShiftReportModel>> getShiftReport({DateTime? startDate, DateTime? endDate}) async {
    try {
      log('ReportsRepository: Fetching shift report');
      
      var query = _client
          .from('shifts')
          .select('''
            *,
            cashiers(name),
            admins(username),
            bank_accounts(name)
          ''');
      
      if (startDate != null) {
        query = query.gte('start_time', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('start_time', endDate.toIso8601String());
      }
      
      final response = await query.order('start_time', ascending: false);
      
      final reports = (response as List)
          .map((json) => ShiftReportModel.fromJson(json))
          .toList();
      
      log('ReportsRepository: Fetched ${reports.length} shifts');
      return reports;
    } catch (e) {
      log('ReportsRepository: Error fetching shift report - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<ShiftSummary> getShiftSummary({DateTime? startDate, DateTime? endDate}) async {
    try {
      log('ReportsRepository: Fetching shift summary');
      
      final shifts = await getShiftReport(startDate: startDate, endDate: endDate);
      
      return ShiftSummary.fromShifts(shifts);
    } catch (e) {
      log('ReportsRepository: Error fetching shift summary - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<CashierPerformance>> getCashierPerformance({DateTime? startDate, DateTime? endDate}) async {
    try {
      log('ReportsRepository: Fetching cashier performance');
      
      final shifts = await getShiftReport(startDate: startDate, endDate: endDate);
      
      // Group by cashier
      final cashierMap = <String, List<ShiftReportModel>>{};
      for (final shift in shifts) {
        if (!cashierMap.containsKey(shift.cashierName)) {
          cashierMap[shift.cashierName] = [];
        }
        cashierMap[shift.cashierName]!.add(shift);
      }
      
      // Calculate performance for each cashier
      final performance = cashierMap.entries.map((entry) {
        final name = entry.key;
        final shiftsList = entry.value;
        final totalSales = shiftsList.fold<double>(0, (sum, s) => sum + s.totalSaleAmount);
        
        return CashierPerformance(
          cashierId: '', // Would need to fetch actual ID
          cashierName: name,
          totalShifts: shiftsList.length,
          totalSales: totalSales,
          averageSalesPerShift: shiftsList.isEmpty ? 0 : totalSales / shiftsList.length,
          totalTransactions: shiftsList.fold<int>(0, (sum, s) => sum + s.totalTransactions),
          averageTransactionValue: 0, // Would need transaction count
        );
      }).toList();
      
      // Sort by total sales
      performance.sort((a, b) => b.totalSales.compareTo(a.totalSales));
      
      return performance;
    } catch (e) {
      log('ReportsRepository: Error fetching cashier performance - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }
}
