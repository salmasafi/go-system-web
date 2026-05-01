import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/migration/migration_service.dart';
import '../../../../../core/services/dio_helper.dart';
import '../../../../../core/services/endpoints.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../model/revenue_model.dart';

// ─────────────────────────────────────────────
// Supabase-specific model
// ─────────────────────────────────────────────

class SupabaseRevenueModel {
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

  SupabaseRevenueModel({
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

  factory SupabaseRevenueModel.fromJson(Map<String, dynamic> json) {
    return SupabaseRevenueModel(
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

  RevenueModel toLegacyModel() {
    return RevenueModel(
      id: id,
      name: description,
      amount: amount,
      category: null, // Legacy model requires full objects, but updates handle nulls
      admin: null,
      financialAccount: null,
      note: receiptNumber,
      createdAt: createdAt,
      updatedAt: createdAt,
      version: 0,
    );
  }
}

// ─────────────────────────────────────────────
// Interface
// ─────────────────────────────────────────────

abstract class RevenueRepositoryInterface {
  Future<List<SupabaseRevenueModel>> getAllRevenues();
  Future<SupabaseRevenueModel?> getRevenueById(String id);
  Future<SupabaseRevenueModel> createRevenue({
    required String categoryId,
    required String bankAccountId,
    required double amount,
    required String description,
    String? receiptNumber,
    String? receiptImage,
  });
  Future<SupabaseRevenueModel> updateRevenue({
    required String id,
    required String categoryId,
    required String bankAccountId,
    required double amount,
    required String description,
    String? receiptNumber,
  });
  Future<Map<String, dynamic>> getSelectionData();
}

// ─────────────────────────────────────────────
// Hybrid Repository
// ─────────────────────────────────────────────

class RevenueRepository implements RevenueRepositoryInterface {
  late RevenueRepositoryInterface _dataSource;

  RevenueRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('financial')) {
      log('RevenueRepository: Using Supabase');
      _dataSource = _RevenueSupabaseDataSource();
    } else {
      log('RevenueRepository: Using Dio (legacy)');
      _dataSource = _RevenueDioDataSource();
    }
  }

  @override
  Future<List<SupabaseRevenueModel>> getAllRevenues() =>
      _dataSource.getAllRevenues();

  @override
  Future<SupabaseRevenueModel> createRevenue({
    required String categoryId,
    required String bankAccountId,
    required double amount,
    required String description,
    String? receiptNumber,
    String? receiptImage,
  }) =>
      _dataSource.createRevenue(
        categoryId: categoryId,
        bankAccountId: bankAccountId,
        amount: amount,
        description: description,
        receiptNumber: receiptNumber,
        receiptImage: receiptImage,
      );

  @override
  Future<SupabaseRevenueModel?> getRevenueById(String id) => _dataSource.getRevenueById(id);

  @override
  Future<SupabaseRevenueModel> updateRevenue({
    required String id,
    required String categoryId,
    required String bankAccountId,
    required double amount,
    required String description,
    String? receiptNumber,
  }) => _dataSource.updateRevenue(
    id: id,
    categoryId: categoryId,
    bankAccountId: bankAccountId,
    amount: amount,
    description: description,
    receiptNumber: receiptNumber,
  );

  @override
  Future<Map<String, dynamic>> getSelectionData() => _dataSource.getSelectionData();

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

class _RevenueSupabaseDataSource implements RevenueRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;
  static const String _table = 'revenues';

  @override
  Future<List<SupabaseRevenueModel>> getAllRevenues() async {
    try {
      log('RevenueSupabase: Fetching all revenues');
      final response = await _client
          .from(_table)
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) =>
              SupabaseRevenueModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('RevenueSupabase: Error fetching revenues - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<SupabaseRevenueModel> createRevenue({
    required String categoryId,
    required String bankAccountId,
    required double amount,
    required String description,
    String? receiptNumber,
    String? receiptImage,
  }) async {
    try {
      log('RevenueSupabase: Creating revenue');

      final reference =
          'REV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      final response = await _client.from(_table).insert({
        'reference': reference,
        'category_id': categoryId,
        'bank_account_id': bankAccountId,
        'amount': amount,
        'date': DateTime.now().toIso8601String(),
        'description': description,
        'receipt_number': receiptNumber,
        'receipt_image': receiptImage,
        'status': 'approved',
      }).select().single();

      // Ensure bank account is updated. In a real scenario, this would be an RPC.
      // Assuming RPC 'update_bank_account_balance' exists or handled via trigger
      // await _client.rpc('update_bank_account_balance', params: {
      //   'p_account_id': bankAccountId,
      //   'p_amount': amount,
      // });

      return SupabaseRevenueModel.fromJson(response);
    } catch (e) {
      log('RevenueSupabase: Error creating revenue - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<SupabaseRevenueModel?> getRevenueById(String id) async {
    try {
      log('RevenueSupabase: Fetching revenue by id: $id');
      final response = await _client.from(_table).select().eq('id', id).maybeSingle();
      if (response == null) return null;
      return SupabaseRevenueModel.fromJson(response);
    } catch (e) {
      log('RevenueSupabase: Error fetching revenue - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<SupabaseRevenueModel> updateRevenue({
    required String id,
    required String categoryId,
    required String bankAccountId,
    required double amount,
    required String description,
    String? receiptNumber,
  }) async {
    try {
      log('RevenueSupabase: Updating revenue: $id');
      final response = await _client.from(_table).update({
        'category_id': categoryId,
        'bank_account_id': bankAccountId,
        'amount': amount,
        'description': description,
        'receipt_number': receiptNumber,
      }).eq('id', id).select().single();
      return SupabaseRevenueModel.fromJson(response);
    } catch (e) {
      log('RevenueSupabase: Error updating revenue - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<Map<String, dynamic>> getSelectionData() async {
    try {
      log('RevenueSupabase: Fetching selection data');
      final categoriesResponse = await _client.from('categories').select('id, name');
      final accountsResponse = await _client.from('bank_accounts').select('id, name');
      
      return {
        'success': true,
        'data': {
          'categories': categoriesResponse,
          'accounts': accountsResponse,
        }
      };
    } catch (e) {
      log('RevenueSupabase: Error fetching selection data - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }
}

// ─────────────────────────────────────────────
// Dio (Legacy) Implementation
// ─────────────────────────────────────────────

class _RevenueDioDataSource implements RevenueRepositoryInterface {
  @override
  Future<List<SupabaseRevenueModel>> getAllRevenues() async {
    throw UnimplementedError('Not supported in legacy API');
  }

  @override
  Future<SupabaseRevenueModel> createRevenue({
    required String categoryId,
    required String bankAccountId,
    required double amount,
    required String description,
    String? receiptNumber,
    String? receiptImage,
  }) async {
    throw UnimplementedError('Not supported in legacy API');
  }

  @override
  Future<SupabaseRevenueModel?> getRevenueById(String id) async {
    try {
      final response = await DioHelper.getData(url: EndPoint.getRevenueById(id));
      if (response.statusCode == 200) {
        // Return dummy model as we're migrating
        return SupabaseRevenueModel(
          id: id,
          categoryId: '',
          bankAccountId: '',
          amount: 0,
          date: DateTime.now(),
          description: '',
          status: '',
          createdAt: DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<SupabaseRevenueModel> updateRevenue({
    required String id,
    required String categoryId,
    required String bankAccountId,
    required double amount,
    required String description,
    String? receiptNumber,
  }) async {
    try {
      final response = await DioHelper.putData(
        url: EndPoint.updateRevenue(id),
        data: {
          'name': description,
          'amount': amount,
          'Category_id': categoryId,
          'note': receiptNumber,
          'financial_accountId': bankAccountId,
        },
      );
      if (response.statusCode == 200) {
        return SupabaseRevenueModel(
          id: id,
          categoryId: categoryId,
          bankAccountId: bankAccountId,
          amount: amount,
          date: DateTime.now(),
          description: description,
          receiptNumber: receiptNumber,
          status: 'approved',
          createdAt: DateTime.now(),
        );
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<Map<String, dynamic>> getSelectionData() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.getRevenueSelection);
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }
}
