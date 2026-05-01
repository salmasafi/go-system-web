import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/migration/migration_service.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';

// ─────────────────────────────────────────────
// Supabase-specific model
// ─────────────────────────────────────────────

class SupabaseFinancialTransactionModel {
  final String id;
  final String? reference;
  final String transactionType; // expense, revenue, sale_payment, etc.
  final String? relatedId;
  final String? relatedType;
  final String bankAccountId;
  final double amount;
  final double previousBalance;
  final double newBalance;
  final DateTime date;
  final String? description;
  final DateTime createdAt;

  SupabaseFinancialTransactionModel({
    required this.id,
    this.reference,
    required this.transactionType,
    this.relatedId,
    this.relatedType,
    required this.bankAccountId,
    required this.amount,
    required this.previousBalance,
    required this.newBalance,
    required this.date,
    this.description,
    required this.createdAt,
  });

  factory SupabaseFinancialTransactionModel.fromJson(Map<String, dynamic> json) {
    return SupabaseFinancialTransactionModel(
      id: json['id'] as String? ?? '',
      reference: json['reference'] as String?,
      transactionType: json['transaction_type'] as String? ?? '',
      relatedId: json['related_id'] as String?,
      relatedType: json['related_type'] as String?,
      bankAccountId: json['bank_account_id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      previousBalance: (json['previous_balance'] as num?)?.toDouble() ?? 0.0,
      newBalance: (json['new_balance'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}

// ─────────────────────────────────────────────
// Interface
// ─────────────────────────────────────────────

abstract class FinancialTransactionRepositoryInterface {
  Future<List<SupabaseFinancialTransactionModel>> getAllTransactions();
  Future<List<SupabaseFinancialTransactionModel>> getTransactionsByAccount(String bankAccountId);
  Future<SupabaseFinancialTransactionModel> createTransaction({
    required String transactionType,
    required String bankAccountId,
    required double amount,
    required double previousBalance,
    required double newBalance,
    String? relatedId,
    String? relatedType,
    String? description,
  });
}

// ─────────────────────────────────────────────
// Hybrid Repository
// ─────────────────────────────────────────────

class FinancialTransactionRepository implements FinancialTransactionRepositoryInterface {
  late final FinancialTransactionRepositoryInterface _dataSource;

  FinancialTransactionRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('financial')) {
      log('FinancialTransactionRepository: Using Supabase');
      _dataSource = _FinancialTransactionSupabaseDataSource();
    } else {
      log('FinancialTransactionRepository: Using Dio (legacy)');
      _dataSource = _FinancialTransactionDioDataSource();
    }
  }

  @override
  Future<List<SupabaseFinancialTransactionModel>> getAllTransactions() =>
      _dataSource.getAllTransactions();

  @override
  Future<List<SupabaseFinancialTransactionModel>> getTransactionsByAccount(String bankAccountId) =>
      _dataSource.getTransactionsByAccount(bankAccountId);

  @override
  Future<SupabaseFinancialTransactionModel> createTransaction({
    required String transactionType,
    required String bankAccountId,
    required double amount,
    required double previousBalance,
    required double newBalance,
    String? relatedId,
    String? relatedType,
    String? description,
  }) =>
      _dataSource.createTransaction(
        transactionType: transactionType,
        bankAccountId: bankAccountId,
        amount: amount,
        previousBalance: previousBalance,
        newBalance: newBalance,
        relatedId: relatedId,
        relatedType: relatedType,
        description: description,
      );

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

class _FinancialTransactionSupabaseDataSource implements FinancialTransactionRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;
  static const String _table = 'financial_transactions';

  @override
  Future<List<SupabaseFinancialTransactionModel>> getAllTransactions() async {
    try {
      log('FinancialTxSupabase: Fetching all transactions');
      final response = await _client
          .from(_table)
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) =>
              SupabaseFinancialTransactionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('FinancialTxSupabase: Error fetching transactions - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<SupabaseFinancialTransactionModel>> getTransactionsByAccount(String bankAccountId) async {
    try {
      log('FinancialTxSupabase: Fetching transactions for account $bankAccountId');
      final response = await _client
          .from(_table)
          .select()
          .eq('bank_account_id', bankAccountId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) =>
              SupabaseFinancialTransactionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('FinancialTxSupabase: Error fetching account transactions - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<SupabaseFinancialTransactionModel> createTransaction({
    required String transactionType,
    required String bankAccountId,
    required double amount,
    required double previousBalance,
    required double newBalance,
    String? relatedId,
    String? relatedType,
    String? description,
  }) async {
    try {
      log('FinancialTxSupabase: Creating transaction');

      final reference =
          'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

      final response = await _client.from(_table).insert({
        'reference': reference,
        'transaction_type': transactionType,
        'bank_account_id': bankAccountId,
        'amount': amount,
        'previous_balance': previousBalance,
        'new_balance': newBalance,
        'date': DateTime.now().toIso8601String(),
        'related_id': relatedId,
        'related_type': relatedType,
        'description': description,
      }).select().single();

      return SupabaseFinancialTransactionModel.fromJson(response);
    } catch (e) {
      log('FinancialTxSupabase: Error creating transaction - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }
}

// ─────────────────────────────────────────────
// Dio (Legacy) Implementation
// ─────────────────────────────────────────────

class _FinancialTransactionDioDataSource implements FinancialTransactionRepositoryInterface {
  @override
  Future<List<SupabaseFinancialTransactionModel>> getAllTransactions() async {
    // Legacy API doesn't have a direct equivalent
    return [];
  }

  @override
  Future<List<SupabaseFinancialTransactionModel>> getTransactionsByAccount(String bankAccountId) async {
    return [];
  }

  @override
  Future<SupabaseFinancialTransactionModel> createTransaction({
    required String transactionType,
    required String bankAccountId,
    required double amount,
    required double previousBalance,
    required double newBalance,
    String? relatedId,
    String? relatedType,
    String? description,
  }) async {
    throw UnimplementedError('createTransaction not supported via Dio');
  }
}
