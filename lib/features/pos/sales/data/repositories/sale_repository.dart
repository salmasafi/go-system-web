import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../../history/model/sale_model.dart';
import '../../../history/model/pending_sale_details_model.dart';

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
    String? shiftId,
    String? cashierId,
    required List<Map<String, dynamic>> items,
    required double grandTotal,
    double? taxAmount,
    double? discount,
    String? note,
    String? couponCode,
    List<Map<String, dynamic>>? payments,
    bool isPending = false,
  });
  Future<bool> completePendingSale(String saleId);
  Future<bool> cancelSale(String saleId);
  Future<bool> applyCoupon(String saleId, String couponCode);
  Future<List<SaleItemModel>> searchSalesByReference(String query);
  Future<bool> payDue(String saleId, String customerId, double amount, String bankAccountId);
}

/// Sale repository using Supabase as the primary data source.
class SaleRepository implements SaleRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<List<SaleItemModel>> getAllSales({int? page, int? limit}) async {
    try {
      log('SaleRepository: Fetching sales, page: $page, limit: $limit');

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

      return (response as List)
          .map((json) => _mapSupabaseToSaleItemModel(json))
          .toList();
    } catch (e) {
      log('SaleRepository: Error fetching sales - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<SaleDetailModel?> getSaleById(String id) async {
    try {
      log('SaleRepository: Fetching sale by id: $id');

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
      log('SaleRepository: Error fetching sale - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<PendingSaleModel>> getPendingSales() async {
    try {
      log('SaleRepository: Fetching pending sales');

      final response = await _client
          .from('sales')
          .select('''
            *,
            customer:customer_id(id, name),
            warehouse:warehouse_id(id, name)
          ''')
          .eq('sale_status', 'pending')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => _mapSupabaseToPendingSaleModel(json))
          .toList();
    } catch (e) {
      log('SaleRepository: Error fetching pending sales - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<PendingSaleDetailsModel?> getPendingSaleDetails(String id) async {
    try {
      log('SaleRepository: Fetching pending sale details: $id');

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
      log('SaleRepository: Error fetching pending sale details - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<DueSaleModel>> getDueSales() async {
    try {
      log('SaleRepository: Fetching due sales');

      final response = await _client
          .from('sales')
          .select('''
            *,
            customer:customer_id(id, name, phone_number)
          ''')
          .gt('remaining_amount', 0)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => _mapSupabaseToDueSaleModel(json))
          .toList();
    } catch (e) {
      log('SaleRepository: Error fetching due sales - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<SaleDetailModel> createSale({
    required String customerId,
    required String warehouseId,
    String? shiftId,
    String? cashierId,
    required List<Map<String, dynamic>> items,
    required double grandTotal,
    double? taxAmount,
    double? discount,
    String? note,
    String? couponCode,
    List<Map<String, dynamic>>? payments,
    bool isPending = false,
  }) async {
    try {
      log('SaleRepository: Creating sale for customer: $customerId');

      final response = await _client.rpc('create_sale_with_items', params: {
        'p_customer_id': customerId,
        'p_warehouse_id': warehouseId,
        'p_shift_id': shiftId,
        'p_cashier_id': cashierId,
        'p_items': items,
        'p_grand_total': grandTotal,
        'p_tax_amount': taxAmount ?? 0.0,
        'p_discount': discount ?? 0.0,
        'p_note': note ?? '',
        'p_coupon_code': couponCode,
        'p_payments': payments ?? [],
        'p_is_pending': isPending,
      });

      log('SaleRepository: Sale created successfully');
      final String? saleId = response is Map ? response['sale_id'] : response.toString();
      if (saleId == null) throw Exception('Failed to retrieve created sale ID');
      
      final sale = await getSaleById(saleId);
      if (sale == null) throw Exception('Failed to retrieve created sale');
      return sale;
    } catch (e) {
      log('SaleRepository: Error creating sale - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> completePendingSale(String saleId) async {
    try {
      log('SaleRepository: Completing pending sale: $saleId');
      await _client.from('sales').update({'sale_status': 'completed'}).eq('id', saleId);
      return true;
    } catch (e) {
      log('SaleRepository: Error completing sale - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> cancelSale(String saleId) async {
    try {
      log('SaleRepository: Cancelling sale: $saleId');
      await _client.rpc('cancel_sale', params: {'p_sale_id': saleId});
      return true;
    } catch (e) {
      log('SaleRepository: Error cancelling sale - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> applyCoupon(String saleId, String couponCode) async {
    try {
      log('SaleRepository: Applying coupon $couponCode to sale $saleId');
      final result = await _client.rpc('apply_sale_coupon', params: {
        'p_sale_id': saleId,
        'p_coupon_code': couponCode,
      });
      return result['success'] == true;
    } catch (e) {
      log('SaleRepository: Error applying coupon - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<SaleItemModel>> searchSalesByReference(String query) async {
    try {
      log('SaleRepository: Searching sales by reference: $query');
      final response = await _client
          .from('sales')
          .select('*, customer:customer_id(id, name)')
          .ilike('reference', '%$query%')
          .order('created_at', ascending: false)
          .limit(20);

      return (response as List).map((json) => _mapSupabaseToSaleItemModel(json)).toList();
    } catch (e) {
      log('SaleRepository: Error searching sales - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> payDue(String saleId, String customerId, double amount, String bankAccountId) async {
    try {
      log('SaleRepository: Processing due payment for sale: $saleId, amount: $amount');

      // 1. Get current sale data
      final sale = await _client
          .from('sales')
          .select('paid_amount, remaining_amount, grand_total')
          .eq('id', saleId)
          .single();

      final currentPaid = (sale['paid_amount'] as num?)?.toDouble() ?? 0.0;
      final currentRemaining = (sale['remaining_amount'] as num?)?.toDouble() ?? 0.0;

      if (amount > currentRemaining) {
        throw Exception('Payment amount exceeds remaining due');
      }

      final newPaid = currentPaid + amount;
      final newRemaining = currentRemaining - amount;
      final isDue = newRemaining > 0;

      // 2. Record the payment in due_payments table
      await _client.from('due_payments').insert({
        'sale_id': saleId,
        'amount': amount,
        'date': DateTime.now().toIso8601String().substring(0, 10),
        'financial_account_id': bankAccountId,
      });

      // 3. Update the sale record
      await _client.from('sales').update({
        'paid_amount': newPaid,
        'remaining_amount': newRemaining,
        'is_due': isDue,
      }).eq('id', saleId);

      // 4. Update customer due status if fully paid
      if (!isDue) {
        // Check if customer has any other dues
        final otherDues = await _client
            .from('sales')
            .select('id')
            .eq('customer_id', customerId)
            .gt('remaining_amount', 0)
            .neq('id', saleId)
            .limit(1);

        if ((otherDues as List).isEmpty) {
          await _client.from('customers').update({
            'is_due': false,
            'amount_due': 0,
          }).eq('id', customerId);
        }
      }

      log('SaleRepository: Due payment processed successfully');
      return true;
    } catch (e) {
      log('SaleRepository: Error processing due payment - $e');
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
              id: item['id'] ?? '',
              productId: item['product']?['id'] ?? item['product_id'] ?? '',
              productName: item['product']?['name'] ?? 'Unknown',
              productImage: item['product']?['image_url'] ?? '',
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
      cashier: CashierInfo(id: '', email: ''),
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
