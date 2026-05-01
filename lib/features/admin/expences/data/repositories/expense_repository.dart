import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/migration/migration_service.dart';
import '../../../../../core/services/dio_helper.dart';
import '../../../../../core/services/endpoints.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../../expense_admin/model/expense_admin_model.dart';

// ─────────────────────────────────────────────
// Supabase-specific model
// ─────────────────────────────────────────────

class SupabaseExpenseModel {
  final String id;
  final String? reference;
  final String categoryId;
  final String bankAccountId;
  final String? shiftId;
  final double amount;
  final DateTime date;
  final String description;
  final String? receiptNumber;
  final String? receiptImage;
  final String status;
  final DateTime createdAt;

  SupabaseExpenseModel({
    required this.id,
    this.reference,
    required this.categoryId,
    required this.bankAccountId,
    this.shiftId,
    required this.amount,
    required this.date,
    required this.description,
    this.receiptNumber,
    this.receiptImage,
    required this.status,
    required this.createdAt,
  });

  factory SupabaseExpenseModel.fromJson(Map<String, dynamic> json) {
    return SupabaseExpenseModel(
      id: json['id'] as String? ?? '',
      reference: json['reference'] as String?,
      categoryId: json['category_id'] as String? ?? '',
      bankAccountId: json['bank_account_id'] as String? ?? '',
      shiftId: json['shift_id'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      description: json['description'] as String? ?? '',
      receiptNumber: json['receipt_number'] as String?,
      receiptImage: json['receipt_image'] as String?,
      status: json['status'] as String? ?? 'approved',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  ExpenseModel toLegacyModel() {
    return ExpenseModel(
      id: id,
      name: description,
      amount: amount,
      categoryId: categoryId,
      note: receiptNumber,
      financialAccountId: bankAccountId,
      createdAt: createdAt,
      updatedAt: createdAt,
      version: 0,
    );
  }
}

// ─────────────────────────────────────────────
// Interface
// ─────────────────────────────────────────────

abstract class ExpenseRepositoryInterface {
  Future<List<ExpenseAdminModel>> getAllExpenses();
  Future<void> createExpense({
    required String name,
    required double amount,
    required String categoryId,
    required String financialAccountId,
    required String note,
  });
  Future<void> deleteExpense(String id);
}

// ─────────────────────────────────────────────
// Hybrid Repository
// ─────────────────────────────────────────────

class ExpenseRepository implements ExpenseRepositoryInterface {
  late final ExpenseRepositoryInterface _dataSource;

  ExpenseRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('financial')) {
      log('ExpenseRepository: Using Supabase');
      _dataSource = _ExpenseSupabaseDataSource();
    } else {
      log('ExpenseRepository: Using Dio (legacy)');
      _dataSource = _ExpenseDioDataSource();
    }
  }

  @override
  Future<List<ExpenseAdminModel>> getAllExpenses() =>
      _dataSource.getAllExpenses();

  @override
  Future<void> createExpense({
    required String name,
    required double amount,
    required String categoryId,
    required String financialAccountId,
    required String note,
  }) =>
      _dataSource.createExpense(
        name: name,
        amount: amount,
        categoryId: categoryId,
        financialAccountId: financialAccountId,
        note: note,
      );

  @override
  Future<void> deleteExpense(String id) => _dataSource.deleteExpense(id);

  void enableSupabase() {
    MigrationService.enableSupabase('financial');
    _initializeDataSource();
  }

  void enableDio() {
    MigrationService.enableDio('financial');
    _initializeDataSource();
  }
}

// ─────────────────────────────────────────────
// Supabase Implementation
// ─────────────────────────────────────────────

class _ExpenseSupabaseDataSource implements ExpenseRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;
  static const String _table = 'expenses';

  @override
  Future<List<ExpenseAdminModel>> getAllExpenses() async {
    try {
      log('ExpenseSupabase: Fetching all expenses');
      final response = await _client
          .from(_table)
          .select('*, expense_categories(name), financial_accounts(name)')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => _mapSupabaseToModel(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('ExpenseSupabase: Error fetching expenses - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> createExpense({
    required String name,
    required double amount,
    required String categoryId,
    required String financialAccountId,
    required String note,
  }) async {
    try {
      log('ExpenseSupabase: Creating expense');
      await _client.from(_table).insert({
        'description': name,
        'amount': amount,
        'category_id': categoryId,
        'bank_account_id': financialAccountId,
        'note': note,
        'date': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      log('ExpenseSupabase: Error creating expense - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    try {
      log('ExpenseSupabase: Deleting expense: $id');
      await _client.from(_table).delete().eq('id', id);
    } catch (e) {
      log('ExpenseSupabase: Error deleting expense - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  ExpenseAdminModel _mapSupabaseToModel(Map<String, dynamic> json) {
    final category = json['expense_categories'] as Map<String, dynamic>?;
    final account = json['financial_accounts'] as Map<String, dynamic>?;

    return ExpenseAdminModel(
      id: json['id'] ?? '',
      name: json['description'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      note: json['note'] ?? '',
      financialAccountId: json['bank_account_id'] ?? '',
      financialAccountName: account != null ? account['name'] : null,
      categoryId: json['category_id'] ?? '',
      categoryName: category != null ? category['name'] : null,
      v: json['version'] ?? 1,
    );
  }
}

// ─────────────────────────────────────────────
// Dio (Legacy) Implementation
// ─────────────────────────────────────────────

class _ExpenseDioDataSource implements ExpenseRepositoryInterface {
  @override
  Future<List<ExpenseAdminModel>> getAllExpenses() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.getAllExpenseAdmin);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = ExpenseAdminResponse.fromJson(response.data);
        return data.data.expenses;
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> createExpense({
    required String name,
    required double amount,
    required String categoryId,
    required String financialAccountId,
    required String note,
  }) async {
    try {
      final response = await DioHelper.postData(
        url: EndPoint.addPosExpense,
        data: {
          'name': name,
          'amount': amount,
          'Category_id': categoryId,
          'financial_accountId': financialAccountId,
          'note': note,
        },
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    try {
      final response = await DioHelper.deleteData(url: '${EndPoint.deleteExpense}/$id');
      if (response.statusCode != 200) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }
}
