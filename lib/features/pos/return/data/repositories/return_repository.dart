import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/migration/migration_service.dart';
import '../../../../core/services/dio_helper.dart';
import '../../../../core/services/endpoints.dart';
import '../../../../core/supabase/supabase_client.dart';
import '../../../../core/supabase/storage_service.dart';
import '../../../../core/supabase/supabase_error_handler.dart';
import '../../../../core/utils/error_handler.dart';
import '../../models/return_sale_model.dart';
import '../../models/return_item_model.dart';
import '../../../admin/purchase_returns/model/purchase_return_model.dart';

/// Interface for return data operations
abstract class ReturnRepositoryInterface {
  // Sale Returns
  Future<ReturnSaleModel?> searchSaleForReturn(String reference);
  Future<ReturnSaleModel> createSaleReturn({
    required String saleId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    String? refundMethod,
    String? note,
    File? attachmentFile,
  });
  Future<bool> validateReturnQuantities(String saleId, List<Map<String, dynamic>> items);
  
  // Purchase Returns
  Future<List<PurchaseReturnModel>> getAllPurchaseReturns();
  Future<PurchaseReturnModel?> getPurchaseReturnById(String id);
  Future<PurchaseReturnModel> createPurchaseReturn({
    required String purchaseId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    String? refundMethod,
    String? note,
    File? attachmentFile,
  });
  Future<bool> restoreProductQuantities(String returnId);
  Future<bool> updateCustomerBalance(String customerId, double amount);
}

/// Hybrid repository that supports both Dio and Supabase for returns
class ReturnRepository implements ReturnRepositoryInterface {
  late final ReturnRepositoryInterface _dataSource;

  ReturnRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('returns')) {
      log('ReturnRepository: Using Supabase');
      _dataSource = _ReturnSupabaseDataSource();
    } else {
      log('ReturnRepository: Using Dio (legacy)');
      _dataSource = _ReturnDioDataSource();
    }
  }

  @override
  Future<ReturnSaleModel?> searchSaleForReturn(String reference) =>
      _dataSource.searchSaleForReturn(reference);

  @override
  Future<ReturnSaleModel> createSaleReturn({
    required String saleId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    String? refundMethod,
    String? note,
    File? attachmentFile,
  }) => _dataSource.createSaleReturn(
    saleId: saleId,
    items: items,
    totalAmount: totalAmount,
    refundMethod: refundMethod,
    note: note,
    attachmentFile: attachmentFile,
  );

  @override
  Future<bool> validateReturnQuantities(String saleId, List<Map<String, dynamic>> items) =>
      _dataSource.validateReturnQuantities(saleId, items);

  @override
  Future<List<PurchaseReturnModel>> getAllPurchaseReturns() =>
      _dataSource.getAllPurchaseReturns();

  @override
  Future<PurchaseReturnModel?> getPurchaseReturnById(String id) =>
      _dataSource.getPurchaseReturnById(id);

  @override
  Future<PurchaseReturnModel> createPurchaseReturn({
    required String purchaseId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    String? refundMethod,
    String? note,
    File? attachmentFile,
  }) => _dataSource.createPurchaseReturn(
    purchaseId: purchaseId,
    items: items,
    totalAmount: totalAmount,
    refundMethod: refundMethod,
    note: note,
    attachmentFile: attachmentFile,
  );

  @override
  Future<bool> restoreProductQuantities(String returnId) =>
      _dataSource.restoreProductQuantities(returnId);

  @override
  Future<bool> updateCustomerBalance(String customerId, double amount) =>
      _dataSource.updateCustomerBalance(customerId, amount);

  void enableSupabase() {
    MigrationService.enableSupabase('returns');
    _initializeDataSource();
  }

  void enableDio() {
    MigrationService.enableDio('returns');
    _initializeDataSource();
  }
}

/// Supabase implementation for Return data source
class _ReturnSupabaseDataSource implements ReturnRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;
  final StorageService _storage = StorageService(SupabaseClientWrapper.instance);

  @override
  Future<ReturnSaleModel?> searchSaleForReturn(String reference) async {
    try {
      log('ReturnSupabase: Searching sale for return: $reference');

      final response = await _client
          .from('sales')
          .select('''
            *,
            customer:customer_id(id, name),
            warehouse:warehouse_id(id, name),
            items:sale_items(*, product:product_id(id, name, code))
          ''')
          .eq('reference', reference)
          .eq('sale_status', 'completed')
          .maybeSingle();

      if (response == null) return null;

      return _mapSupabaseToReturnSaleModel(response);
    } catch (e) {
      log('ReturnSupabase: Error searching sale - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<ReturnSaleModel> createSaleReturn({
    required String saleId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    String? refundMethod,
    String? note,
    File? attachmentFile,
  }) async {
    try {
      log('ReturnSupabase: Creating sale return for sale: $saleId');

      // Upload attachment if provided
      String? attachmentUrl;
      if (attachmentFile != null) {
        attachmentUrl = await _storage.uploadImage(
          file: attachmentFile,
          folder: 'return_attachments',
          fileName: 'return_${DateTime.now().millisecondsSinceEpoch}.jpg',
          maxWidth: 1200,
        );
      }

      // Use RPC for atomic transaction
      final response = await _client.rpc('create_sale_return', params: {
        'p_sale_id': saleId,
        'p_items': items,
        'p_total_amount': totalAmount,
        'p_refund_method': refundMethod ?? 'cash',
        'p_note': note ?? '',
        'p_attachment_url': attachmentUrl ?? '',
      });

      log('ReturnSupabase: Sale return created successfully');
      return await searchSaleForReturn(response['reference']) as ReturnSaleModel;
    } catch (e) {
      log('ReturnSupabase: Error creating sale return - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> validateReturnQuantities(String saleId, List<Map<String, dynamic>> items) async {
    try {
      log('ReturnSupabase: Validating return quantities for sale: $saleId');

      final response = await _client.rpc('validate_return_quantities', params: {
        'p_sale_id': saleId,
        'p_items': items,
      });

      return response['valid'] == true;
    } catch (e) {
      log('ReturnSupabase: Error validating quantities - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<PurchaseReturnModel>> getAllPurchaseReturns() async {
    try {
      log('ReturnSupabase: Fetching all purchase returns');

      final response = await _client
          .from('purchase_returns')
          .select('''
            *,
            purchase:purchase_id(id, reference, grand_total),
            supplier:supplier_id(id, company_name, username, phone_number),
            items:purchase_return_items(*)
          ''')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => _mapSupabaseToPurchaseReturnModel(json))
          .toList();
    } catch (e) {
      log('ReturnSupabase: Error fetching purchase returns - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<PurchaseReturnModel?> getPurchaseReturnById(String id) async {
    try {
      log('ReturnSupabase: Fetching purchase return by id: $id');

      final response = await _client
          .from('purchase_returns')
          .select('''
            *,
            purchase:purchase_id(id, reference, grand_total),
            supplier:supplier_id(id, company_name, username, phone_number),
            items:purchase_return_items(*)
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return _mapSupabaseToPurchaseReturnModel(response);
    } catch (e) {
      log('ReturnSupabase: Error fetching purchase return - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<PurchaseReturnModel> createPurchaseReturn({
    required String purchaseId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    String? refundMethod,
    String? note,
    File? attachmentFile,
  }) async {
    try {
      log('ReturnSupabase: Creating purchase return for purchase: $purchaseId');

      // Upload attachment if provided
      String? attachmentUrl;
      if (attachmentFile != null) {
        attachmentUrl = await _storage.uploadImage(
          file: attachmentFile,
          folder: 'return_attachments',
          fileName: 'purchase_return_${DateTime.now().millisecondsSinceEpoch}.jpg',
          maxWidth: 1200,
        );
      }

      // Use RPC for atomic transaction
      final response = await _client.rpc('create_purchase_return', params: {
        'p_purchase_id': purchaseId,
        'p_items': items,
        'p_total_amount': totalAmount,
        'p_refund_method': refundMethod ?? 'cash',
        'p_note': note ?? '',
        'p_attachment_url': attachmentUrl ?? '',
      });

      log('ReturnSupabase: Purchase return created successfully');
      return await getPurchaseReturnById(response['return_id']) as PurchaseReturnModel;
    } catch (e) {
      log('ReturnSupabase: Error creating purchase return - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> restoreProductQuantities(String returnId) async {
    try {
      log('ReturnSupabase: Restoring product quantities for return: $returnId');

      await _client.rpc('restore_return_quantities', params: {
        'p_return_id': returnId,
      });

      return true;
    } catch (e) {
      log('ReturnSupabase: Error restoring quantities - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> updateCustomerBalance(String customerId, double amount) async {
    try {
      log('ReturnSupabase: Updating customer balance: $customerId, amount: $amount');

      await _client.rpc('update_customer_balance_for_return', params: {
        'p_customer_id': customerId,
        'p_amount': amount,
      });

      return true;
    } catch (e) {
      log('ReturnSupabase: Error updating customer balance - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  /// Map Supabase response to ReturnSaleModel
  ReturnSaleModel _mapSupabaseToReturnSaleModel(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    final warehouse = json['warehouse'] as Map<String, dynamic>?;
    final items = (json['items'] as List? ?? [])
        .map((item) => ReturnItemModel(
              productId: item['product']?['id'] ?? item['product_id'] ?? '',
              productName: item['product']?['name'] ?? 'Unknown',
              originalQuantity: (item['quantity'] as num?)?.toInt() ?? 0,
              availableToReturn: (item['quantity'] as num?)?.toInt() ?? 0,
              returnQuantity: 0,
              price: (item['price'] as num?)?.toDouble() ?? 0.0,
              reason: '',
            ))
        .toList();

    return ReturnSaleModel(
      id: json['id'] ?? '',
      reference: json['reference'] ?? '',
      date: json['created_at'] ?? '',
      customerName: customer?['name'],
      warehouseName: warehouse?['name'] ?? '',
      cashierEmail: '',
      cashierName: '',
      cashierManName: '',
      items: items,
    );
  }

  /// Map Supabase response to PurchaseReturnModel
  PurchaseReturnModel _mapSupabaseToPurchaseReturnModel(Map<String, dynamic> json) {
    final purchase = json['purchase'] as Map<String, dynamic>?;
    final supplier = json['supplier'] as Map<String, dynamic>?;
    final items = (json['items'] as List? ?? [])
        .map((item) => ReturnItem(
              productId: item['product_id'] ?? '',
              originalQuantity: (item['original_quantity'] as num?)?.toInt() ?? 0,
              returnedQuantity: (item['returned_quantity'] as num?)?.toInt() ?? 0,
              price: (item['price'] as num?)?.toDouble() ?? 0.0,
              subtotal: (item['subtotal'] as num?)?.toDouble() ?? 0.0,
            ))
        .toList();

    return PurchaseReturnModel(
      id: json['id'] ?? '',
      reference: json['reference'] ?? '',
      purchaseReference: purchase?['reference'] ?? '',
      purchaseId: purchase?['id'] ?? '',
      purchaseGrandTotal: (purchase?['grand_total'] as num?)?.toDouble() ?? 0.0,
      supplierName: supplier?['company_name'] ?? supplier?['username'],
      supplierPhone: supplier?['phone_number'],
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      refundMethod: json['refund_method'] ?? 'cash',
      note: json['note'] ?? '',
      date: json['created_at'] ?? '',
      items: items,
    );
  }
}

/// Dio implementation for Return data source (legacy)
class _ReturnDioDataSource implements ReturnRepositoryInterface {
  @override
  Future<ReturnSaleModel?> searchSaleForReturn(String reference) async {
    try {
      final response = await DioHelper.postData(
        url: EndPoint.saleForReturn,
        data: {'reference': reference},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ReturnSaleModel.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<ReturnSaleModel> createSaleReturn({
    required String saleId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    String? refundMethod,
    String? note,
    File? attachmentFile,
  }) async {
    try {
      final data = <String, dynamic>{
        'sale_id': saleId,
        'items': items,
        'total_amount': totalAmount,
        'refund_method': refundMethod ?? 'cash',
        'note': note ?? '',
      };

      if (attachmentFile != null) {
        final bytes = await attachmentFile.readAsBytes();
        data['attachment'] = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      }

      final response = await DioHelper.postData(
        url: EndPoint.createSaleReturn,
        data: data,
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {
        return await searchSaleForReturn(response['data']?['reference']) as ReturnSaleModel;
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> validateReturnQuantities(String saleId, List<Map<String, dynamic>> items) async {
    try {
      final response = await DioHelper.postData(
        url: EndPoint.validateReturn,
        data: {
          'sale_id': saleId,
          'items': items,
        },
      );

      return response.statusCode == 200 && response.data['valid'] == true;
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<PurchaseReturnModel>> getAllPurchaseReturns() async {
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getPurchaseReturns,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final returnsList = response.data['data']?['returns'] as List? ?? [];
        return returnsList.map((e) => PurchaseReturnModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<PurchaseReturnModel?> getPurchaseReturnById(String id) async {
    try {
      final response = await DioHelper.getData(
        url: '${EndPoint.getPurchaseReturns}/$id',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return PurchaseReturnModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<PurchaseReturnModel> createPurchaseReturn({
    required String purchaseId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    String? refundMethod,
    String? note,
    File? attachmentFile,
  }) async {
    try {
      final data = <String, dynamic>{
        'purchase_id': purchaseId,
        'items': items,
        'total_amount': totalAmount,
        'refund_method': refundMethod ?? 'cash',
        'note': note ?? '',
      };

      if (attachmentFile != null) {
        final bytes = await attachmentFile.readAsBytes();
        data['attachment'] = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      }

      final response = await DioHelper.postData(
        url: EndPoint.createPurchaseReturn,
        data: data,
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {
        return await getPurchaseReturnById(response['data']?['return_id']) as PurchaseReturnModel;
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> restoreProductQuantities(String returnId) async {
    try {
      final response = await DioHelper.postData(
        url: '${EndPoint.restoreReturnQuantities}/$returnId',
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> updateCustomerBalance(String customerId, double amount) async {
    try {
      final response = await DioHelper.postData(
        url: EndPoint.updateCustomerBalance,
        data: {
          'customer_id': customerId,
          'amount': amount,
        },
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }
}
