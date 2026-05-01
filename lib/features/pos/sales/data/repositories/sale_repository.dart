import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/migration/migration_service.dart';
import '../../../../core/services/dio_helper.dart';
import '../../../../core/services/endpoints.dart';
import '../../../../core/supabase/supabase_client.dart';
import '../../../../core/supabase/supabase_error_handler.dart';
import '../../../../core/utils/error_handler.dart';
import '../../history/model/sale_model.dart';
import '../../history/model/pending_sale_details_model.dart';

/// Interface for sale data operations
abstract class SaleRepositoryInterface {
  Future<List<SaleItemModel>> getAllSales({int? page, int? limit});
  Future<SaleDetailModel?> getSaleById(String id);
  Future<List<PendingSaleModel>> getPendingSales();
  Future<PendingSaleDetailsModel?> getPendingSaleDetails(String id);
  Future<List<DueSaleModel>> getDueSales();
  Future<SaleDetailModel> createSale({
    required String customerId,
    required String warehouseId,
    required List<Map<String, dynamic>> items,
    required double grandTotal,
    double? taxAmount,
    double? discount,
    String? note,
    String? couponCode,
    List<Map<String, dynamic>>? payments,
  });
  Future<bool> completePendingSale(String saleId);
  Future<bool> cancelSale(String saleId);
  Future<bool> applyCoupon(String saleId, String couponCode);
  Future<List<SaleItemModel>> searchSalesByReference(String query);
}

/// Hybrid repository that supports both Dio and Supabase for sales
class SaleRepository implements SaleRepositoryInterface {
  late final SaleRepositoryInterface _dataSource;

  SaleRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('sales')) {
      log('SaleRepository: Using Supabase');
      _dataSource = _SaleSupabaseDataSource();
    } else {
      log('SaleRepository: Using Dio (legacy)');
      _dataSource = _SaleDioDataSource();
    }
  }

  @override
  Future<List<SaleItemModel>> getAllSales({int? page, int? limit}) =>
      _dataSource.getAllSales(page: page, limit: limit);

  @override
  Future<SaleDetailModel?> getSaleById(String id) => _dataSource.getSaleById(id);

  @override
  Future<List<PendingSaleModel>> getPendingSales() => _dataSource.getPendingSales();

  @override
  Future<PendingSaleDetailsModel?> getPendingSaleDetails(String id) =>
      _dataSource.getPendingSaleDetails(id);

  @override
  Future<List<DueSaleModel>> getDueSales() => _dataSource.getDueSales();

  @override
  Future<SaleDetailModel> createSale({
    required String customerId,
    required String warehouseId,
    required List<Map<String, dynamic>> items,
    required double grandTotal,
    double? taxAmount,
    double? discount,
    String? note,
    String? couponCode,
    List<Map<String, dynamic>>? payments,
  }) => _dataSource.createSale(
    customerId: customerId,
    warehouseId: warehouseId,
    items: items,
    grandTotal: grandTotal,
    taxAmount: taxAmount,
    discount: discount,
    note: note,
    couponCode: couponCode,
    payments: payments,
  );

  @override
  Future<bool> completePendingSale(String saleId) =>
      _dataSource.completePendingSale(saleId);

  @override
  Future<bool> cancelSale(String saleId) => _dataSource.cancelSale(saleId);

  @override
  Future<bool> applyCoupon(String saleId, String couponCode) =>
      _dataSource.applyCoupon(saleId, couponCode);

  @override
  Future<List<SaleItemModel>> searchSalesByReference(String query) =>
      _dataSource.searchSalesByReference(query);

  void enableSupabase() {
    MigrationService.enableSupabase('sales');
    _initializeDataSource();
  }

  void enableDio() {
    MigrationService.enableDio('sales');
    _initializeDataSource();
  }
}

/// Supabase implementation for Sale data source
class _SaleSupabaseDataSource implements SaleRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<List<SaleItemModel>> getAllSales({int? page, int? limit}) async {
    try {
      log('SaleSupabase: Fetching sales, page: $page, limit: $limit');

      var query = _client
          .from('sales')
          .select('''
            *,
            customer:customer_id(id, name)
          ''')
          .eq('sale_status', 'completed')
          .order('created_at', ascending: false);

      if (page != null && limit != null) {
        query = query.range((page - 1) * limit, page * limit - 1);
      }

      final response = await query;

      final sales = (response as List)
          .map((json) => _mapSupabaseToSaleItemModel(json))
          .toList();

      log('SaleSupabase: Fetched ${sales.length} sales');
      return sales;
    } catch (e) {
      log('SaleSupabase: Error fetching sales - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<SaleDetailModel?> getSaleById(String id) async {
    try {
      log('SaleSupabase: Fetching sale by id: $id');

      // Fetch sale with items and payments
      final saleResponse = await _client
          .from('sales')
          .select('''
            *,
            customer:customer_id(id, name),
            warehouse:warehouse_id(id, name),
            items:sale_items(*, product:product_id(id, name, image)),
            payments:sale_payments(*)
          ''')
          .eq('id', id)
          .maybeSingle();

      if (saleResponse == null) return null;

      return _mapSupabaseToSaleDetailModel(saleResponse);
    } catch (e) {
      log('SaleSupabase: Error fetching sale - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<PendingSaleModel>> getPendingSales() async {
    try {
      log('SaleSupabase: Fetching pending sales');

      final response = await _client
          .from('sales')
          .select('''
            *,
            customer:customer_id(id, name),
            warehouse:warehouse_id(id, name)
          ''')
          .eq('sale_status', 'pending')
          .order('created_at', ascending: false);

      final sales = (response as List)
          .map((json) => _mapSupabaseToPendingSaleModel(json))
          .toList();

      log('SaleSupabase: Fetched ${sales.length} pending sales');
      return sales;
    } catch (e) {
      log('SaleSupabase: Error fetching pending sales - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<PendingSaleDetailsModel?> getPendingSaleDetails(String id) async {
    try {
      log('SaleSupabase: Fetching pending sale details: $id');

      final response = await _client
          .from('sales')
          .select('''
            *,
            customer:customer_id(id, name, email, phone_number),
            warehouse:warehouse_id(id, name),
            items:sale_items(*, product:product_id(id, name, code, image))
          ''')
          .eq('id', id)
          .eq('sale_status', 'pending')
          .maybeSingle();

      if (response == null) return null;

      return _mapSupabaseToPendingSaleDetailsModel(response);
    } catch (e) {
      log('SaleSupabase: Error fetching pending sale details - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<DueSaleModel>> getDueSales() async {
    try {
      log('SaleSupabase: Fetching due sales');

      final response = await _client
          .from('sales')
          .select('''
            *,
            customer:customer_id(id, name, phone_number)
          ''')
          .gt('remaining_amount', 0)
          .order('created_at', ascending: false);

      final sales = (response as List)
          .map((json) => _mapSupabaseToDueSaleModel(json))
          .toList();

      log('SaleSupabase: Fetched ${sales.length} due sales');
      return sales;
    } catch (e) {
      log('SaleSupabase: Error fetching due sales - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<SaleDetailModel> createSale({
    required String customerId,
    required String warehouseId,
    required List<Map<String, dynamic>> items,
    required double grandTotal,
    double? taxAmount,
    double? discount,
    String? note,
    String? couponCode,
    List<Map<String, dynamic>>? payments,
  }) async {
    try {
      log('SaleSupabase: Creating sale for customer: $customerId');

      // Use RPC for atomic transaction
      final response = await _client.rpc('create_sale_with_items', params: {
        'p_customer_id': customerId,
        'p_warehouse_id': warehouseId,
        'p_items': items,
        'p_grand_total': grandTotal,
        'p_tax_amount': taxAmount ?? 0.0,
        'p_discount': discount ?? 0.0,
        'p_note': note ?? '',
        'p_coupon_code': couponCode,
        'p_payments': payments ?? [],
      });

      log('SaleSupabase: Sale created successfully');
      return await getSaleById(response['sale_id']) as SaleDetailModel;
    } catch (e) {
      log('SaleSupabase: Error creating sale - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> completePendingSale(String saleId) async {
    try {
      log('SaleSupabase: Completing pending sale: $saleId');

      await _client
          .from('sales')
          .update({'sale_status': 'completed'})
          .eq('id', saleId);

      log('SaleSupabase: Pending sale completed');
      return true;
    } catch (e) {
      log('SaleSupabase: Error completing sale - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> cancelSale(String saleId) async {
    try {
      log('SaleSupabase: Cancelling sale: $saleId');

      // Use RPC to handle inventory restoration
      await _client.rpc('cancel_sale', params: {
        'p_sale_id': saleId,
      });

      log('SaleSupabase: Sale cancelled and inventory restored');
      return true;
    } catch (e) {
      log('SaleSupabase: Error cancelling sale - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> applyCoupon(String saleId, String couponCode) async {
    try {
      log('SaleSupabase: Applying coupon $couponCode to sale $saleId');

      // Validate and apply coupon
      final result = await _client.rpc('apply_sale_coupon', params: {
        'p_sale_id': saleId,
        'p_coupon_code': couponCode,
      });

      return result['success'] == true;
    } catch (e) {
      log('SaleSupabase: Error applying coupon - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<SaleItemModel>> searchSalesByReference(String query) async {
    try {
      log('SaleSupabase: Searching sales by reference: $query');

      final response = await _client
          .from('sales')
          .select('*, customer:customer_id(id, name)')
          .ilike('reference', '%$query%')
          .order('created_at', ascending: false)
          .limit(20);

      final sales = (response as List)
          .map((json) => _mapSupabaseToSaleItemModel(json))
          .toList();

      log('SaleSupabase: Found ${sales.length} sales');
      return sales;
    } catch (e) {
      log('SaleSupabase: Error searching sales - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  // Mapping methods
  SaleItemModel _mapSupabaseToSaleItemModel(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    return SaleItemModel(
      id: json['id'] ?? '',
      reference: json['reference'] ?? 'N/A',
      customerName: customer?['name'] ?? 'Walk-in Customer',
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      status: json['sale_status'] ?? 'completed',
      date: json['created_at'] ?? '',
    );
  }

  SaleDetailModel _mapSupabaseToSaleDetailModel(Map<String, dynamic> json) {
    final items = (json['items'] as List? ?? [])
        .map((item) => SaleDetailItem(
              productId: item['product']?['id'] ?? item['product_id'] ?? '',
              productName: item['product']?['name'] ?? 'Unknown',
              quantity: (item['quantity'] as num?)?.toInt() ?? 0,
              price: (item['price'] as num?)?.toDouble() ?? 0.0,
              subtotal: (item['subtotal'] as num?)?.toDouble() ?? 0.0,
              image: item['product']?['image'],
            ))
        .toList();

    return SaleDetailModel(
      id: json['id'] ?? '',
      reference: json['reference'] ?? '',
      customerId: json['customer_id'] ?? '',
      warehouseId: json['warehouse_id'] ?? '',
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      items: items,
    );
  }

  PendingSaleModel _mapSupabaseToPendingSaleModel(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    final warehouse = json['warehouse'] as Map<String, dynamic>?;
    return PendingSaleModel(
      id: json['id'] ?? '',
      reference: json['reference'] ?? 'PENDING',
      customerName: customer?['name'] ?? 'N/A',
      warehouseName: warehouse?['name'] ?? '',
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      totalItems: (json['items_count'] as num?)?.toInt() ?? 0,
      date: json['created_at'] ?? '',
      status: json['sale_status'] ?? 'pending',
    );
  }

  PendingSaleDetailsModel _mapSupabaseToPendingSaleDetailsModel(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    final warehouse = json['warehouse'] as Map<String, dynamic>?;
    final products = (json['items'] as List? ?? [])
        .map((item) => PendingSaleProductItem(
              productId: item['product']?['id'] ?? item['product_id'] ?? '',
              productName: item['product']?['name'] ?? 'Unknown',
              quantity: (item['quantity'] as num?)?.toInt() ?? 0,
              price: (item['price'] as num?)?.toDouble() ?? 0.0,
              subtotal: (item['subtotal'] as num?)?.toDouble() ?? 0.0,
            ))
        .toList();

    return PendingSaleDetailsModel(
      id: json['id'] ?? '',
      reference: json['reference'] ?? '',
      date: json['created_at'] ?? '',
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      subTotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      note: json['note'] ?? '',
      customer: CustomerInfo(
        id: customer?['id'] ?? '',
        name: customer?['name'] ?? 'Unknown',
        email: customer?['email'] ?? '',
        phone: customer?['phone_number'] ?? '',
      ),
      warehouse: WarehouseInfo(
        id: warehouse?['id'] ?? '',
        name: warehouse?['name'] ?? '',
      ),
      cashier: CashierInfo(id: '', name: ''),
      products: products,
      payloadForCreateSale: {},
    );
  }

  DueSaleModel _mapSupabaseToDueSaleModel(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    return DueSaleModel(
      id: json['id'] ?? '',
      reference: json['reference'] ?? 'N/A',
      customerId: customer?['id'] ?? '',
      customerName: customer?['name'] ?? 'Unknown',
      phone: customer?['phone_number'] ?? '',
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (json['remaining_amount'] as num?)?.toDouble() ?? 0.0,
      date: json['created_at'] ?? '',
    );
  }
}

/// Dio implementation for Sale data source (legacy)
class _SaleDioDataSource implements SaleRepositoryInterface {
  @override
  Future<List<SaleItemModel>> getAllSales({int? page, int? limit}) async {
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getSales,
        query: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final salesList = response.data['data']?['sales'] as List? ?? [];
        return salesList.map((e) => SaleItemModel.fromJson(e)).toList();
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<SaleDetailModel?> getSaleById(String id) async {
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getSaleById(id),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return SaleDetailModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<PendingSaleModel>> getPendingSales() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.getPendingSales);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final pendingList = response.data['data']?['pending'] as List? ?? [];
        return pendingList.map((e) => PendingSaleModel.fromJson(e)).toList();
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<PendingSaleDetailsModel?> getPendingSaleDetails(String id) async {
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getPendingSaleDetails(id),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return PendingSaleDetailsModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<DueSaleModel>> getDueSales() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.getDueSales);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final dueList = response.data['data']?['dues'] as List? ?? [];
        return dueList.map((e) => DueSaleModel.fromJson(e)).toList();
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<SaleDetailModel> createSale({
    required String customerId,
    required String warehouseId,
    required List<Map<String, dynamic>> items,
    required double grandTotal,
    double? taxAmount,
    double? discount,
    String? note,
    String? couponCode,
    List<Map<String, dynamic>>? payments,
  }) async {
    try {
      final response = await DioHelper.postData(
        url: EndPoint.createSale,
        data: {
          'customer_id': customerId,
          'warehouse_id': warehouseId,
          'items': items,
          'grand_total': grandTotal,
          'tax_amount': taxAmount ?? 0.0,
          'discount': discount ?? 0.0,
          'note': note ?? '',
          'coupon_code': couponCode,
          'payments': payments ?? [],
        },
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {
        final saleId = response.data['data']?['sale']?['_id'];
        if (saleId != null) {
          return await getSaleById(saleId) as SaleDetailModel;
        }
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> completePendingSale(String saleId) async {
    try {
      final response = await DioHelper.postData(
        url: EndPoint.completePendingSale(saleId),
      );
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> cancelSale(String saleId) async {
    try {
      final response = await DioHelper.postData(
        url: EndPoint.cancelSale(saleId),
      );
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> applyCoupon(String saleId, String couponCode) async {
    try {
      final response = await DioHelper.postData(
        url: EndPoint.applyCoupon,
        data: {
          'sale_id': saleId,
          'coupon_code': couponCode,
        },
      );
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<SaleItemModel>> searchSalesByReference(String query) async {
    try {
      final response = await DioHelper.getData(
        url: EndPoint.searchSales,
        query: {'reference': query},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final salesList = response.data['data']?['sales'] as List? ?? [];
        return salesList.map((e) => SaleItemModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }
}
