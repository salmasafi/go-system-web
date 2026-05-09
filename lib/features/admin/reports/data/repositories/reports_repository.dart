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

  /// Exposed for cubit-level RPC calls
  SupabaseClient get client => _client;

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
            warehouse_products(quantity),
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
            .from('warehouse_products')
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
          .select('created_at, type, reference')
          .order('created_at', ascending: false)
          .limit(20);

      final recentMovements = (recentAdjustments as List).map((json) {
        final dateStr = json['created_at'] ?? json['date'] ?? '';
        return MovementData(
          date: DateTime.tryParse(dateStr) ?? DateTime.now(),
          type: json['type'] ?? 'adjustment',
          quantity: 0,
          reference: json['reference'] ?? '',
        );
      }).toList();

      // Calculate stock in/out from adjustment_items
      // type 'increase' → stock in, type 'decrease' → stock out
      final adjustmentItems = await _client
          .from('adjustment_items')
          .select('quantity, adjustments!inner(type)');

      int stockIn = 0;
      int stockOut = 0;

      for (final item in adjustmentItems as List) {
        final type = (item['adjustments'] as Map?)?['type'] as String? ?? '';
        final qty = (item['quantity'] ?? 0) as int;
        if (type == 'increase') stockIn += qty;
        if (type == 'decrease') stockOut += qty;
      }

      // Count purchases and returns
      final purchasesCountResponse = await _client
          .from('purchases')
          .select('id');
      final returnsCountResponse = await _client
          .from('sale_returns')
          .select('id');

      return InventoryMovementSummary(
        totalAdjustments: adjustmentsResponse.length,
        totalTransfers: transfersResponse.length,
        totalPurchases: (purchasesCountResponse as List).length,
        totalReturns: (returnsCountResponse as List).length,
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
      
      // Include actual sales from POS
      var salesQuery = _client.from('sales')
          .select('grand_total, tax_amount, date')
          .eq('sale_status', 'completed');
      if (startDate != null) {
        salesQuery = salesQuery.gte('date', startDate.toIso8601String().split('T')[0]);
      }
      if (endDate != null) {
        salesQuery = salesQuery.lte('date', endDate.toIso8601String().split('T')[0]);
      }
      final salesData = await salesQuery;
      final totalSalesIncome = (salesData as List)
          .fold<double>(0, (s, r) => s + ((r['grand_total'] as num?)?.toDouble() ?? 0));
      final totalTaxCollected = salesData
          .fold<double>(0, (s, r) => s + ((r['tax_amount'] as num?)?.toDouble() ?? 0));

      // Group all income/expenses by month (key = 'YYYY-MM')
      final monthlyRevMap = <String, double>{};
      final monthlyExpMap = <String, double>{};

      // POS Sales
      for (final sale in salesData) {
        final dt = DateTime.tryParse(sale['date'] ?? '') ?? DateTime.now();
        final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
        final amount = (sale['grand_total'] as num?)?.toDouble() ?? 0;
        monthlyRevMap[key] = (monthlyRevMap[key] ?? 0) + amount;
      }
      // Manual revenues
      for (final t in revenues) {
        final key = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
        monthlyRevMap[key] = (monthlyRevMap[key] ?? 0) + t.amount;
      }
      // Expenses
      for (final t in expenses) {
        final key = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
        monthlyExpMap[key] = (monthlyExpMap[key] ?? 0) + t.amount;
      }

      final allKeys = {...monthlyRevMap.keys, ...monthlyExpMap.keys}.toList()..sort();
      final monthlyData = allKeys.map((key) {
        final rev = monthlyRevMap[key] ?? 0;
        final exp = monthlyExpMap[key] ?? 0;
        return MonthlyFinancialData(
          month: key,
          revenue: rev,
          expenses: exp,
          profit: rev - exp,
        );
      }).toList();

      return FinancialSummary(
        totalRevenue: totalRevenue + totalSalesIncome,
        totalExpenses: totalExpenses,
        netIncome: totalRevenue + totalSalesIncome - totalExpenses,
        totalTaxCollected: totalTaxCollected,
        bankAccounts: bankAccounts,
        monthlyData: monthlyData,
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
      
      // Calculate totalTransactions per shift from sales table
      final shiftIds = (response as List)
          .map((json) => json['id'] as String)
          .toList();
      
      final Map<String, int> shiftTxCounts = {};
      if (shiftIds.isNotEmpty) {
        // Fetch sale counts grouped by shift_id
        final salesResponse = await _client
            .from('sales')
            .select('shift_id');
        
        for (final sale in salesResponse as List) {
          final shiftId = sale['shift_id'] as String?;
          if (shiftId != null && shiftIds.contains(shiftId)) {
            shiftTxCounts[shiftId] = (shiftTxCounts[shiftId] ?? 0) + 1;
          }
        }
      }
      
      final reports = response.map((json) {
        // Inject total_transactions calculated from sales
        final shiftId = json['id'] as String;
        final txCount = shiftTxCounts[shiftId] ?? 0;
        final mutableJson = Map<String, dynamic>.from(json);
        mutableJson['total_transactions'] = txCount;
        return ShiftReportModel.fromJson(mutableJson);
      }).toList();
      
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
      
      // Group by cashier ID to avoid duplicates
      final cashierMap = <String, _CashierAccum>{};
      for (final shift in shifts) {
        final key = shift.cashierId;
        cashierMap.putIfAbsent(key, () => _CashierAccum(shift.cashierId, shift.cashierName));
        cashierMap[key]!.add(shift);
      }

      final performance = cashierMap.values.map((acc) {
        final totalTx = acc.totalTransactions;
        return CashierPerformance(
          cashierId: acc.cashierId,
          cashierName: acc.cashierName,
          totalShifts: acc.shifts.length,
          totalSales: acc.totalSales,
          averageSalesPerShift:
              acc.shifts.isEmpty ? 0 : acc.totalSales / acc.shifts.length,
          totalTransactions: totalTx,
          averageTransactionValue:
              totalTx == 0 ? 0 : acc.totalSales / totalTx,
        );
      }).toList()
        ..sort((a, b) => b.totalSales.compareTo(a.totalSales));

      return performance;
    } catch (e) {
      log('ReportsRepository: Error fetching cashier performance - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }
}

// ── Helper accumulator for cashier performance grouping ──────────────────────
class _CashierAccum {
  final String cashierId;
  final String cashierName;
  final List<ShiftReportModel> shifts = [];

  _CashierAccum(this.cashierId, this.cashierName);

  void add(ShiftReportModel shift) => shifts.add(shift);

  double get totalSales =>
      shifts.fold(0, (s, sh) => s + sh.totalSaleAmount);

  int get totalTransactions =>
      shifts.fold(0, (s, sh) => s + sh.totalTransactions);
}
