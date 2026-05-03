/// Cashier Shift Report Model
/// Represents cashier shift data and performance
class ShiftReportModel {
  final String id;
  final String cashierName;
  final String? cashiermanName;
  final String? bankAccountName;
  final DateTime startTime;
  final DateTime? endTime;
  final String status;
  final double openingBalance;
  final double totalSaleAmount;
  final double totalExpenses;
  final double netCashInDrawer;
  final int totalTransactions;
  final double expectedCash;
  final double? actualCash;
  final double? difference;

  ShiftReportModel({
    required this.id,
    required this.cashierName,
    this.cashiermanName,
    this.bankAccountName,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.openingBalance,
    required this.totalSaleAmount,
    required this.totalExpenses,
    required this.netCashInDrawer,
    required this.totalTransactions,
    required this.expectedCash,
    this.actualCash,
    this.difference,
  });

  factory ShiftReportModel.fromJson(Map<String, dynamic> json) {
    final totalSales = (json['total_sale_amount'] ?? 0).toDouble();
    final totalExps = (json['total_expenses'] ?? 0).toDouble();
    final opening = (json['opening_balance'] ?? 0).toDouble();
    final expected = opening + totalSales - totalExps;

    return ShiftReportModel(
      id: json['id'] ?? '',
      cashierName: json['cashiers']?['name'] ?? '',
      cashiermanName: json['admins']?['username'],
      bankAccountName: json['bank_accounts']?['name'],
      startTime: json['start_time'] != null 
          ? DateTime.parse(json['start_time']) 
          : DateTime.now(),
      endTime: json['end_time'] != null 
          ? DateTime.parse(json['end_time']) 
          : null,
      status: json['status'] ?? 'open',
      openingBalance: opening,
      totalSaleAmount: totalSales,
      totalExpenses: totalExps,
      netCashInDrawer: (json['net_cash_in_drawer'] ?? 0).toDouble(),
      totalTransactions: json['total_transactions'] ?? 0,
      expectedCash: expected,
      actualCash: json['actual_cash']?.toDouble(),
      difference: json['difference']?.toDouble(),
    );
  }

  /// Calculate shift duration in hours
  double get durationInHours {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime).inMinutes / 60;
  }

  /// Check if shift has variance
  bool get hasVariance {
    if (actualCash == null) return false;
    return (actualCash! - expectedCash).abs() > 0.01;
  }
}

/// Shift Summary for date range
class ShiftSummary {
  final int totalShifts;
  final int openShifts;
  final int closedShifts;
  final double totalSales;
  final double totalExpenses;
  final double totalOpeningBalance;
  final num averageShiftDuration;
  final List<ShiftReportModel> shifts;

  ShiftSummary({
    required this.totalShifts,
    required this.openShifts,
    required this.closedShifts,
    required this.totalSales,
    required this.totalExpenses,
    required this.totalOpeningBalance,
    required this.averageShiftDuration,
    required this.shifts,
  });

  factory ShiftSummary.fromShifts(List<ShiftReportModel> shiftsList) {
    final open = shiftsList.where((s) => s.status == 'open').length;
    final closed = shiftsList.where((s) => s.status == 'closed').length;
    final totalSales = shiftsList.fold<double>(0, (sum, s) => sum + s.totalSaleAmount);
    final totalExps = shiftsList.fold<double>(0, (sum, s) => sum + s.totalExpenses);
    final totalOpening = shiftsList.fold<double>(0, (sum, s) => sum + s.openingBalance);
    final avgDuration = shiftsList.isEmpty 
        ? 0 
        : shiftsList.fold<double>(0, (sum, s) => sum + s.durationInHours) / shiftsList.length;

    return ShiftSummary(
      totalShifts: shiftsList.length,
      openShifts: open,
      closedShifts: closed,
      totalSales: totalSales,
      totalExpenses: totalExps,
      totalOpeningBalance: totalOpening,
      averageShiftDuration: avgDuration,
      shifts: shiftsList,
    );
  }
}

/// Cashier Performance
class CashierPerformance {
  final String cashierId;
  final String cashierName;
  final int totalShifts;
  final double totalSales;
  final double averageSalesPerShift;
  final int totalTransactions;
  final double averageTransactionValue;

  CashierPerformance({
    required this.cashierId,
    required this.cashierName,
    required this.totalShifts,
    required this.totalSales,
    required this.averageSalesPerShift,
    required this.totalTransactions,
    required this.averageTransactionValue,
  });
}
