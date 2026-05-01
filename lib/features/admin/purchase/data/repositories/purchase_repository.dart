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
import '../../model/purchase_model.dart';

/// Interface for purchase data operations
abstract class PurchaseRepositoryInterface {
  Future<PurchaseData> getAllPurchases();
  Future<Purchase?> getPurchaseById(String id);
  Future<Purchase> createPurchase({
    required String warehouseId,
    required String supplierId,
    required List<Map<String, dynamic>> items,
    required double grandTotal,
    double? taxAmount,
    double? discount,
    double? shippingCost,
    String? note,
    String? receiptImage,
    File? receiptImageFile,
    List<Map<String, dynamic>>? payments,
  });
  Future<Purchase> updatePurchase({
    required String id,
    String? warehouseId,
    String? supplierId,
    List<Map<String, dynamic>>? items,
    double? grandTotal,
    double? taxAmount,
    double? discount,
    double? shippingCost,
    String? note,
    String? paymentStatus,
  });
  Future<void> deletePurchase(String id);
  Future<bool> handleDuePayment(String purchaseId, double amount, String financialAccountId);
  Future<List<Purchase>> getPurchasesBySupplier(String supplierId);
  Future<List<Purchase>> getPurchasesByWarehouse(String warehouseId);
}

/// Hybrid repository that supports both Dio and Supabase for purchases
class PurchaseRepository implements PurchaseRepositoryInterface {
  late final PurchaseRepositoryInterface _dataSource;

  PurchaseRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('purchases')) {
      log('PurchaseRepository: Using Supabase');
      _dataSource = _PurchaseSupabaseDataSource();
    } else {
      log('PurchaseRepository: Using Dio (legacy)');
      _dataSource = _PurchaseDioDataSource();
    }
  }

  @override
  Future<PurchaseData> getAllPurchases() => _dataSource.getAllPurchases();

  @override
  Future<Purchase?> getPurchaseById(String id) => _dataSource.getPurchaseById(id);

  @override
  Future<Purchase> createPurchase({
    required String warehouseId,
    required String supplierId,
    required List<Map<String, dynamic>> items,
    required double grandTotal,
    double? taxAmount,
    double? discount,
    double? shippingCost,
    String? note,
    String? receiptImage,
    File? receiptImageFile,
    List<Map<String, dynamic>>? payments,
  }) => _dataSource.createPurchase(
    warehouseId: warehouseId,
    supplierId: supplierId,
    items: items,
    grandTotal: grandTotal,
    taxAmount: taxAmount,
    discount: discount,
    shippingCost: shippingCost,
    note: note,
    receiptImage: receiptImage,
    receiptImageFile: receiptImageFile,
    payments: payments,
  );

  @override
  Future<Purchase> updatePurchase({
    required String id,
    String? warehouseId,
    String? supplierId,
    List<Map<String, dynamic>>? items,
    double? grandTotal,
    double? taxAmount,
    double? discount,
    double? shippingCost,
    String? note,
    String? paymentStatus,
  }) => _dataSource.updatePurchase(
    id: id,
    warehouseId: warehouseId,
    supplierId: supplierId,
    items: items,
    grandTotal: grandTotal,
    taxAmount: taxAmount,
    discount: discount,
    shippingCost: shippingCost,
    note: note,
    paymentStatus: paymentStatus,
  );

  @override
  Future<void> deletePurchase(String id) => _dataSource.deletePurchase(id);

  @override
  Future<bool> handleDuePayment(String purchaseId, double amount, String financialAccountId) =>
      _dataSource.handleDuePayment(purchaseId, amount, financialAccountId);

  @override
  Future<List<Purchase>> getPurchasesBySupplier(String supplierId) =>
      _dataSource.getPurchasesBySupplier(supplierId);

  @override
  Future<List<Purchase>> getPurchasesByWarehouse(String warehouseId) =>
      _dataSource.getPurchasesByWarehouse(warehouseId);

  void enableSupabase() {
    MigrationService.enableSupabase('purchases');
    _initializeDataSource();
  }

  void enableDio() {
    MigrationService.enableDio('purchases');
    _initializeDataSource();
  }
}

/// Supabase implementation for Purchase data source
class _PurchaseSupabaseDataSource implements PurchaseRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;
  final StorageService _storage = StorageService(SupabaseClientWrapper.instance);

  @override
  Future<PurchaseData> getAllPurchases() async {
    try {
      log('PurchaseSupabase: Fetching all purchases');

      // Fetch purchases with related data
      final response = await _client
          .from('purchases')
          .select('''
            *,
            warehouse:warehouse_id(*),
            supplier:supplier_id(*),
            tax:tax_id(*),
            items:purchase_items(*, product:product_id(*)),
            invoices:invoices(*),
            due_payments:due_payments(*)
          ''')
          .order('created_at', ascending: false);

      // Calculate stats
      final full = response.where((p) => p['payment_status'] == 'full').toList();
      final later = response.where((p) => p['payment_status'] == 'later').toList();
      final partial = response.where((p) => p['payment_status'] == 'partial').toList();

      final stats = PurchaseStats(
        totalPurchases: response.length,
        fullCount: full.length,
        laterCount: later.length,
        partialCount: partial.length,
        totalAmount: response.fold<int>(0, (sum, p) => sum + ((p['grand_total'] as num?)?.toInt() ?? 0)),
        fullAmount: full.fold<int>(0, (sum, p) => sum + ((p['grand_total'] as num?)?.toInt() ?? 0)),
        laterAmount: later.fold<int>(0, (sum, p) => sum + ((p['grand_total'] as num?)?.toInt() ?? 0)),
        partialAmount: partial.fold<int>(0, (sum, p) => sum + ((p['grand_total'] as num?)?.toInt() ?? 0)),
      );

      final purchases = Purchases(
        full: full.map((json) => _mapSupabaseToPurchase(json)).toList(),
        later: later.map((json) => _mapSupabaseToPurchase(json)).toList(),
        partial: partial.map((json) => _mapSupabaseToPurchase(json)).toList(),
      );

      log('PurchaseSupabase: Fetched ${response.length} purchases');
      return PurchaseData(stats: stats, purchases: purchases);
    } catch (e) {
      log('PurchaseSupabase: Error fetching purchases - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<Purchase?> getPurchaseById(String id) async {
    try {
      log('PurchaseSupabase: Fetching purchase by id: $id');

      final response = await _client
          .from('purchases')
          .select('''
            *,
            warehouse:warehouse_id(*),
            supplier:supplier_id(*),
            tax:tax_id(*),
            items:purchase_items(*, product:product_id(*)),
            invoices:invoices(*),
            due_payments:due_payments(*)
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return _mapSupabaseToPurchase(response);
    } catch (e) {
      log('PurchaseSupabase: Error fetching purchase - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<Purchase> createPurchase({
    required String warehouseId,
    required String supplierId,
    required List<Map<String, dynamic>> items,
    required double grandTotal,
    double? taxAmount,
    double? discount,
    double? shippingCost,
    String? note,
    String? receiptImage,
    File? receiptImageFile,
    List<Map<String, dynamic>>? payments,
  }) async {
    try {
      log('PurchaseSupabase: Creating purchase');

      // Upload receipt image if provided
      String? receiptUrl;
      if (receiptImageFile != null) {
        receiptUrl = await _storage.uploadImage(
          file: receiptImageFile,
          folder: 'purchase_receipts',
          fileName: 'purchase_${DateTime.now().millisecondsSinceEpoch}.jpg',
          maxWidth: 1200,
        );
      } else if (receiptImage != null && receiptImage.isNotEmpty) {
        receiptUrl = receiptImage;
      }

      // Use RPC for atomic transaction
      final response = await _client.rpc('create_purchase_with_items', params: {
        'p_warehouse_id': warehouseId,
        'p_supplier_id': supplierId,
        'p_items': items,
        'p_grand_total': grandTotal,
        'p_tax_amount': taxAmount ?? 0.0,
        'p_discount': discount ?? 0.0,
        'p_shipping_cost': shippingCost ?? 0.0,
        'p_note': note ?? '',
        'p_receipt_img': receiptUrl ?? '',
        'p_payments': payments ?? [],
      });

      log('PurchaseSupabase: Purchase created successfully');
      return await getPurchaseById(response['purchase_id']) as Purchase;
    } catch (e) {
      log('PurchaseSupabase: Error creating purchase - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<Purchase> updatePurchase({
    required String id,
    String? warehouseId,
    String? supplierId,
    List<Map<String, dynamic>>? items,
    double? grandTotal,
    double? taxAmount,
    double? discount,
    double? shippingCost,
    String? note,
    String? paymentStatus,
  }) async {
    try {
      log('PurchaseSupabase: Updating purchase: $id');

      final updateData = <String, dynamic>{};
      if (warehouseId != null) updateData['warehouse_id'] = warehouseId;
      if (supplierId != null) updateData['supplier_id'] = supplierId;
      if (grandTotal != null) updateData['grand_total'] = grandTotal;
      if (taxAmount != null) updateData['tax_amount'] = taxAmount;
      if (discount != null) updateData['discount'] = discount;
      if (shippingCost != null) updateData['shipping_cost'] = shippingCost;
      if (note != null) updateData['note'] = note;
      if (paymentStatus != null) updateData['payment_status'] = paymentStatus;

      await _client.from('purchases').update(updateData).eq('id', id);

      // Update items if provided
      if (items != null && items.isNotEmpty) {
        // Delete existing items and recreate
        await _client.from('purchase_items').delete().eq('purchase_id', id);
        for (final item in items) {
          await _client.from('purchase_items').insert({
            'purchase_id': id,
            ...item,
          });
        }
      }

      log('PurchaseSupabase: Purchase updated successfully');
      return await getPurchaseById(id) as Purchase;
    } catch (e) {
      log('PurchaseSupabase: Error updating purchase - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deletePurchase(String id) async {
    try {
      log('PurchaseSupabase: Deleting purchase: $id');

      // Use RPC to handle inventory restoration
      await _client.rpc('delete_purchase', params: {
        'p_purchase_id': id,
      });

      log('PurchaseSupabase: Purchase deleted successfully');
    } catch (e) {
      log('PurchaseSupabase: Error deleting purchase - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> handleDuePayment(String purchaseId, double amount, String financialAccountId) async {
    try {
      log('PurchaseSupabase: Processing due payment for purchase: $purchaseId');

      await _client.rpc('process_purchase_payment', params: {
        'p_purchase_id': purchaseId,
        'p_amount': amount,
        'p_financial_account_id': financialAccountId,
      });

      log('PurchaseSupabase: Due payment processed successfully');
      return true;
    } catch (e) {
      log('PurchaseSupabase: Error processing due payment - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<Purchase>> getPurchasesBySupplier(String supplierId) async {
    try {
      log('PurchaseSupabase: Fetching purchases by supplier: $supplierId');

      final response = await _client
          .from('purchases')
          .select('''
            *,
            warehouse:warehouse_id(*),
            supplier:supplier_id(*),
            tax:tax_id(*),
            items:purchase_items(*, product:product_id(*)),
            invoices:invoices(*),
            due_payments:due_payments(*)
          ''')
          .eq('supplier_id', supplierId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => _mapSupabaseToPurchase(json)).toList();
    } catch (e) {
      log('PurchaseSupabase: Error fetching purchases by supplier - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<Purchase>> getPurchasesByWarehouse(String warehouseId) async {
    try {
      log('PurchaseSupabase: Fetching purchases by warehouse: $warehouseId');

      final response = await _client
          .from('purchases')
          .select('''
            *,
            warehouse:warehouse_id(*),
            supplier:supplier_id(*),
            tax:tax_id(*),
            items:purchase_items(*, product:product_id(*)),
            invoices:invoices(*),
            due_payments:due_payments(*)
          ''')
          .eq('warehouse_id', warehouseId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => _mapSupabaseToPurchase(json)).toList();
    } catch (e) {
      log('PurchaseSupabase: Error fetching purchases by warehouse - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  /// Map Supabase response to Purchase model
  Purchase _mapSupabaseToPurchase(Map<String, dynamic> json) {
    final warehouseData = json['warehouse'] as Map<String, dynamic>?;
    final supplierData = json['supplier'] as Map<String, dynamic>?;
    final taxData = json['tax'] as Map<String, dynamic>?;

    return Purchase(
      id: json['id'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      warehouse: warehouseData != null
          ? Warehouse(
              id: warehouseData['id'] ?? '',
              name: warehouseData['name'] ?? '',
              address: warehouseData['address'] ?? '',
              phone: warehouseData['phone'] ?? '',
              email: warehouseData['email'] ?? '',
              numberOfProducts: warehouseData['number_of_products'] ?? 0,
              stockQuantity: warehouseData['stock_quantity'] ?? 0,
              createdAt: DateTime.tryParse(warehouseData['created_at'] ?? '') ?? DateTime.now(),
              updatedAt: DateTime.tryParse(warehouseData['updated_at'] ?? '') ?? DateTime.now(),
              version: warehouseData['version'] ?? 1,
              isOnline: warehouseData['is_online'] ?? false,
            )
          : Warehouse(id: '', name: '', address: '', phone: '', email: '', numberOfProducts: 0, stockQuantity: 0, createdAt: DateTime.now(), updatedAt: DateTime.now(), version: 1, isOnline: false),
      supplier: supplierData != null
          ? Supplier(
              id: supplierData['id'] ?? '',
              image: supplierData['image'] ?? '',
              username: supplierData['username'] ?? '',
              email: supplierData['email'] ?? '',
              phoneNumber: supplierData['phone_number'] ?? '',
              address: supplierData['address'] ?? '',
              companyName: supplierData['company_name'] ?? '',
              cityId: supplierData['city_id'] ?? '',
              countryId: supplierData['country_id'] ?? '',
              version: supplierData['version'] ?? 1,
            )
          : Supplier(id: '', image: '', username: '', email: '', phoneNumber: '', address: '', companyName: '', cityId: '', countryId: '', version: 1),
      tax: taxData != null
          ? Tax(
              id: taxData['id'] ?? '',
              name: taxData['name'] ?? '',
              status: taxData['status'] ?? false,
              amount: (taxData['amount'] as num?)?.toDouble() ?? 0.0,
              type: taxData['type'] ?? '',
              createdAt: DateTime.tryParse(taxData['created_at'] ?? '') ?? DateTime.now(),
              updatedAt: DateTime.tryParse(taxData['updated_at'] ?? '') ?? DateTime.now(),
              version: taxData['version'] ?? 1,
            )
          : null,
      receiptImg: json['receipt_img'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      exchangeRate: (json['exchange_rate'] as num?)?.toDouble() ?? 1.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      shippingCost: (json['shipping_cost'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      note: json['note'],
      reference: json['reference'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      version: json['version'] ?? 1,
      items: (json['items'] as List? ?? [])
          .map((item) => PurchaseItem.fromJson(item))
          .toList(),
      invoices: (json['invoices'] as List? ?? [])
          .map((inv) => Invoice.fromJson(inv))
          .toList(),
      duePayments: (json['due_payments'] as List? ?? [])
          .map((dp) => DuePayment.fromJson(dp))
          .toList(),
    );
  }
}

/// Dio implementation for Purchase data source (legacy)
class _PurchaseDioDataSource implements PurchaseRepositoryInterface {
  @override
  Future<PurchaseData> getAllPurchases() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.getPurchase);

      if (response.statusCode == 200) {
        final model = PurchaseResponse.fromJson(response.data);
        if (model.success) {
          return model.data;
        }
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<Purchase?> getPurchaseById(String id) async {
    try {
      final response = await DioHelper.getData(
        url: '${EndPoint.getPurchase}/$id',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final purchaseJson = response.data['data']?['purchase'];
        if (purchaseJson != null) {
          return Purchase.fromJson(purchaseJson);
        }
      }
      return null;
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<Purchase> createPurchase({
    required String warehouseId,
    required String supplierId,
    required List<Map<String, dynamic>> items,
    required double grandTotal,
    double? taxAmount,
    double? discount,
    double? shippingCost,
    String? note,
    String? receiptImage,
    File? receiptImageFile,
    List<Map<String, dynamic>>? payments,
  }) async {
    try {
      final data = <String, dynamic>{
        'warehouse_id': warehouseId,
        'supplier_id': supplierId,
        'items': items,
        'grand_total': grandTotal,
        'tax_amount': taxAmount ?? 0.0,
        'discount': discount ?? 0.0,
        'shipping_cost': shippingCost ?? 0.0,
        'note': note ?? '',
        if (receiptImage != null) 'receipt_img': receiptImage,
        if (payments != null) 'payments': payments,
      };

      // Handle image file if provided
      if (receiptImageFile != null) {
        final bytes = await receiptImageFile.readAsBytes();
        final base64 = base64Encode(bytes);
        data['receipt_img'] = 'data:image/jpeg;base64,$base64';
      }

      final response = await DioHelper.postData(
        url: EndPoint.createPurchase,
        data: data,
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {
        final purchaseId = response.data['data']?['purchase']?['_id'];
        if (purchaseId != null) {
          return await getPurchaseById(purchaseId) as Purchase;
        }
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<Purchase> updatePurchase({
    required String id,
    String? warehouseId,
    String? supplierId,
    List<Map<String, dynamic>>? items,
    double? grandTotal,
    double? taxAmount,
    double? discount,
    double? shippingCost,
    String? note,
    String? paymentStatus,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (warehouseId != null) data['warehouse_id'] = warehouseId;
      if (supplierId != null) data['supplier_id'] = supplierId;
      if (items != null) data['items'] = items;
      if (grandTotal != null) data['grand_total'] = grandTotal;
      if (taxAmount != null) data['tax_amount'] = taxAmount;
      if (discount != null) data['discount'] = discount;
      if (shippingCost != null) data['shipping_cost'] = shippingCost;
      if (note != null) data['note'] = note;
      if (paymentStatus != null) data['payment_status'] = paymentStatus;

      final response = await DioHelper.putData(
        url: '${EndPoint.getPurchase}/$id',
        data: data,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return await getPurchaseById(id) as Purchase;
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deletePurchase(String id) async {
    try {
      final response = await DioHelper.deleteData(
        url: '${EndPoint.getPurchase}/$id',
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> handleDuePayment(String purchaseId, double amount, String financialAccountId) async {
    try {
      final response = await DioHelper.postData(
        url: '${EndPoint.getPurchase}/$purchaseId/payment',
        data: {
          'amount': amount,
          'financial_account_id': financialAccountId,
        },
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<Purchase>> getPurchasesBySupplier(String supplierId) async {
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getPurchase,
        query: {'supplier_id': supplierId},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final purchasesList = response.data['data']?['purchases']?['full'] as List? ?? [];
        return purchasesList.map((e) => Purchase.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<Purchase>> getPurchasesByWarehouse(String warehouseId) async {
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getPurchase,
        query: {'warehouse_id': warehouseId},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final purchasesList = response.data['data']?['purchases']?['full'] as List? ?? [];
        return purchasesList.map((e) => Purchase.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }
}
