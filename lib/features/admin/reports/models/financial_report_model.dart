/// Financial Report Model
/// Represents financial transactions and summaries
class FinancialReportModel {
  final String id;
  final DateTime date;
  final String type;
  final double amount;
  final String? categoryName;
  final String? bankAccountName;
  final String? referenceType;
  final String? description;
  final String? createdBy;

  FinancialReportModel({
    required this.id,
    required this.date,
    required this.type,
    required this.amount,
    this.categoryName,
    this.bankAccountName,
    this.referenceType,
    this.description,
    this.createdBy,
  });

  factory FinancialReportModel.fromRevenueJson(Map<String, dynamic> json) {
    return FinancialReportModel(
      id: json['id'] ?? '',
      date: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      type: 'revenue',
      amount: (json['amount'] ?? 0).toDouble(),
      categoryName: json['revenue_categories']?['name'],
      bankAccountName: json['bank_accounts']?['name'],
      referenceType: json['reference_type'],
      description: json['description'] ?? json['name'],
      createdBy: json['admins']?['username'],
    );
  }

  factory FinancialReportModel.fromExpenseJson(Map<String, dynamic> json) {
    return FinancialReportModel(
      id: json['id'] ?? '',
      date: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      type: 'expense',
      amount: (json['amount'] ?? 0).toDouble(),
      categoryName: json['expense_categories']?['name'],
      bankAccountName: json['bank_accounts']?['name'],
      referenceType: json['reference_type'],
      description: json['description'] ?? json['name'],
      createdBy: json['admins']?['username'],
    );
  }

  factory FinancialReportModel.fromTransactionJson(Map<String, dynamic> json) {
    return FinancialReportModel(
      id: json['id'] ?? '',
      date: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      type: json['type'] ?? 'transaction',
      amount: (json['amount'] ?? 0).toDouble(),
      bankAccountName: json['bank_accounts']?['name'],
      referenceType: json['reference_type'],
      description: json['description'],
      createdBy: json['admins']?['username'],
    );
  }
}

/// Financial Summary
class FinancialSummary {
  final double totalRevenue;
  final double totalExpenses;
  final double netIncome;
  final double totalTaxCollected;
  final List<BankAccountBalance> bankAccounts;
  final List<MonthlyFinancialData> monthlyData;

  FinancialSummary({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netIncome,
    required this.totalTaxCollected,
    required this.bankAccounts,
    required this.monthlyData,
  });
}

/// Bank account balance
class BankAccountBalance {
  final String id;
  final String name;
  final double balance;
  final double initialBalance;
  final String? accountType;

  BankAccountBalance({
    required this.id,
    required this.name,
    required this.balance,
    required this.initialBalance,
    this.accountType,
  });
}

/// Monthly financial data
class MonthlyFinancialData {
  final String month;
  final double revenue;
  final double expenses;
  final double profit;

  MonthlyFinancialData({
    required this.month,
    required this.revenue,
    required this.expenses,
    required this.profit,
  });
}

/// Revenue by Category
class RevenueByCategory {
  final String categoryName;
  final double amount;
  final int transactionCount;
  final double percentage;

  RevenueByCategory({
    required this.categoryName,
    required this.amount,
    required this.transactionCount,
    required this.percentage,
  });
}

/// Expense by Category
class ExpenseByCategory {
  final String categoryName;
  final double amount;
  final int transactionCount;
  final double percentage;
  final String? color;

  ExpenseByCategory({
    required this.categoryName,
    required this.amount,
    required this.transactionCount,
    required this.percentage,
    this.color,
  });
}
