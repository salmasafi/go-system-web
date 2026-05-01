import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/migration/migration_service.dart';
import '../../../../../core/services/dio_helper.dart';
import '../../../../../core/services/endpoints.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../model/purchase_return_model.dart';

/// Interface for purchase return data operations
abstract class PurchaseReturnRepositoryInterface {
  Future<List<PurchaseReturnModel>> getAllReturns();
  Future<Map<String, dynamic>?> getPurchaseByReference(String reference);
  Future<void> createReturn({
    required String purchaseId,
    required String note,
    required String refundMethod,
    required String refundAccountId,
    required List<Map<String, dynamic>> items,
  });
  Future<void> updateReturn({
    required String id,
    required String note,
    required String refundMethod,
  });
  Future<void> deleteReturn(String id);
}

/// Hybrid repository that supports both Dio and Supabase for purchase returns
class PurchaseReturnRepository implements PurchaseReturnRepositoryInterface {
  late final PurchaseReturnRepositoryInterface _dataSource;

  PurchaseReturnRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('purchase_returns')) {
      log('PurchaseReturnRepository: Using Supabase');
      _dataSource = _PurchaseReturnSupabaseDataSource();
    } else {
      log('PurchaseReturnRepository: Using Dio (legacy)');
      _dataSource = _PurchaseReturnDioDataSource();
    }
  }

  @override
  Future<List<PurchaseReturnModel>> getAllReturns() =>
      _dataSource.getAllReturns();

  @override
  Future<Map<String, dynamic>?> getPurchaseByReference(String reference) =>
      _dataSource.getPurchaseByReference(reference);

  @override
  Future<void> createReturn({
    required String purchaseId,
    required String note,
    required String refundMethod,
    required String refundAccountId,
    required List<Map<String, dynamic>> items,
  }) => _dataSource.createReturn(
    purchaseId: purchaseId,
    note: note,
    refundMethod: refundMethod,
    refundAccountId: refundAccountId,
    items: items,
  );

  @override
  Future<void> updateReturn({
    required String id,
    required String note,
    required String refundMethod,
  }) =>
      _dataSource.updateReturn(id: id, note: note, refundMethod: refundMethod);

  @override
  Future<void> deleteReturn(String id) => _dataSource.deleteReturn(id);
}

/// Supabase implementation for PurchaseReturn data source
class _PurchaseReturnSupabaseDataSource
    implements PurchaseReturnRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<List<PurchaseReturnModel>> getAllReturns() async {
    try {
      log('PurchaseReturnSupabase: Fetching all returns');
      // Simplified fetch, ideally join with purchases and items
      final response = await _client
          .from('purchase_returns')
          .select('*, purchase:purchase_id(*)')
          .order('created_at', ascending: false);
      return (response as List)
          .map((json) => _mapSupabaseToModel(json))
          .toList();
    } catch (e) {
      log('PurchaseReturnSupabase: Error fetching returns - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<Map<String, dynamic>?> getPurchaseByReference(String reference) async {
    try {
      log(
        'PurchaseReturnSupabase: Searching purchase by reference: $reference',
      );
      final response = await _client
          .from('purchases')
          .select('*, items:purchase_items(*)')
          .ilike('reference', '%$reference%')
          .maybeSingle();

      return response;
    } catch (e) {
      log('PurchaseReturnSupabase: Error searching purchase - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> createReturn({
    required String purchaseId,
    required String note,
    required String refundMethod,
    required String refundAccountId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      log('PurchaseReturnSupabase: Creating return for purchase: $purchaseId');

      // Use a transaction (RPC or sequential calls)
      final returnResponse = await _client
          .from('purchase_returns')
          .insert({
            'purchase_id': purchaseId,
            'note': note,
            'refund_method': refundMethod,
            'refund_account_id': refundAccountId,
            'status': 'completed',
          })
          .select()
          .single();

      final returnId = returnResponse['id'];

      // Insert items
      final returnItems = items
          .map(
            (item) => {
              'purchase_return_id': returnId,
              'product_id': item['product_id'],
              'quantity': item['quantity'],
              'reason': item['reason'],
            },
          )
          .toList();

      await _client.from('purchase_return_items').insert(returnItems);
    } catch (e) {
      log('PurchaseReturnSupabase: Error creating return - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> updateReturn({
    required String id,
    required String note,
    required String refundMethod,
  }) async {
    try {
      log('PurchaseReturnSupabase: Updating return: $id');
      await _client
          .from('purchase_returns')
          .update({'note': note, 'refund_method': refundMethod})
          .eq('id', id);
    } catch (e) {
      log('PurchaseReturnSupabase: Error updating return - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteReturn(String id) async {
    try {
      log('PurchaseReturnSupabase: Deleting return: $id');
      await _client.from('purchase_returns').delete().eq('id', id);
    } catch (e) {
      log('PurchaseReturnSupabase: Error deleting return - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  PurchaseReturnModel _mapSupabaseToModel(Map<String, dynamic> json) {
    final purchase = json['purchase'] as Map<String, dynamic>?;
    return PurchaseReturnModel(
      id: json['id'] ?? '',
      reference: json['reference'] ?? '',
      purchaseReference: purchase?['reference'] ?? '',
      purchaseId: purchase?['id'] ?? '',
      purchaseGrandTotal: (purchase?['grand_total'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      refundMethod: json['refund_method'] ?? '',
      note: json['note'] ?? '',
      date: json['created_at'] ?? '',
      items: [],
    );
  }
}

/// Dio implementation for PurchaseReturn data source (legacy)
class _PurchaseReturnDioDataSource
    implements PurchaseReturnRepositoryInterface {
  @override
  Future<List<PurchaseReturnModel>> getAllReturns() async {
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getAllPurchaseReturns,
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = PurchaseReturnData.fromJson(response.data['data']);
        return data.returns;
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<Map<String, dynamic>?> getPurchaseByReference(String reference) async {
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getPurchaseByReference(reference),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final allPurchases = [
          ...(data['purchases']?['full'] as List? ?? []),
          ...(data['purchases']?['later'] as List? ?? []),
          ...(data['purchases']?['partial'] as List? ?? []),
        ];
        return allPurchases.isNotEmpty
            ? allPurchases.first as Map<String, dynamic>
            : null;
      }
      return null;
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> createReturn({
    required String purchaseId,
    required String note,
    required String refundMethod,
    required String refundAccountId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await DioHelper.postData(
        url: EndPoint.createPurchaseReturn,
        data: {
          'purchase_id': purchaseId,
          'note': note,
          'refund_method': refundMethod,
          'refund_account_id': refundAccountId,
          'items': items,
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
  Future<void> updateReturn({
    required String id,
    required String note,
    required String refundMethod,
  }) async {
    try {
      final response = await DioHelper.putData(
        url: EndPoint.updatePurchaseReturn(id),
        data: {'note': note, 'refund_method': refundMethod},
      );
      if (response.statusCode != 200) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteReturn(String id) async {
    try {
      final response = await DioHelper.deleteData(
        url: EndPoint.deletePurchaseReturn(id),
      );
      if (response.statusCode != 200) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }
}
