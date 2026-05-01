import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../../core/migration/migration_service.dart';
import '../../../../../../core/services/dio_helper.dart';
import '../../../../../../core/services/endpoints.dart';
import '../../../../../../core/supabase/supabase_client.dart';
import '../../../../../../core/supabase/supabase_error_handler.dart';
import '../../../../../../core/utils/error_handler.dart';
import '../../model/online_order_model.dart';

// ─────────────────────────────────────────────
// Supabase-specific model
// ─────────────────────────────────────────────

class SupabaseOnlineOrderModel {
  final String id;
  final String orderNumber;
  final String? customerId;
  final String? customerName;
  final String? branchId;
  final String? branchName;
  final double totalAmount;
  final String status;
  final String type;
  final DateTime createdAt;
  final List<SupabaseOnlineOrderItem> items;

  SupabaseOnlineOrderModel({
    required this.id,
    required this.orderNumber,
    this.customerId,
    this.customerName,
    this.branchId,
    this.branchName,
    required this.totalAmount,
    required this.status,
    required this.type,
    required this.createdAt,
    this.items = const [],
  });

  factory SupabaseOnlineOrderModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    final branch = json['branch'] as Map<String, dynamic>?;

    return SupabaseOnlineOrderModel(
      id: json['id'] as String? ?? '',
      orderNumber: json['order_number'] as String? ?? '',
      customerId: json['customer_id'] as String?,
      customerName: customer?['name'] as String?,
      branchId: json['branch_id'] as String?,
      branchName: branch?['name'] as String?,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      type: json['type'] as String? ?? 'delivery',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      items: (json['items'] as List? ?? [])
          .map((e) => SupabaseOnlineOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  OnlineOrderModel toLegacyModel() {
    return OnlineOrderModel(
      id: id,
      orderNumber: orderNumber,
      customerName: customerName ?? 'N/A',
      branch: branchName ?? 'N/A',
      amount: totalAmount,
      status: status,
      dateTime: createdAt.toIso8601String(),
      type: type,
      items: items.map((e) => OnlineOrderItem(
        productId: e.productId,
        productName: e.productName ?? 'Unknown',
        price: e.price,
        wholePrice: e.wholePrice,
        startQuantity: e.startQuantity,
        quantity: e.quantity,
      )).toList(),
    );
  }
}

class SupabaseOnlineOrderItem {
  final String id;
  final String productId;
  final String? productName;
  final int quantity;
  final double price;
  final double? wholePrice;
  final int? startQuantity;

  SupabaseOnlineOrderItem({
    required this.id,
    required this.productId,
    this.productName,
    required this.quantity,
    required this.price,
    this.wholePrice,
    this.startQuantity,
  });

  factory SupabaseOnlineOrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    return SupabaseOnlineOrderItem(
      id: json['id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      productName: product?['name'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      wholePrice: (json['whole_price'] as num?)?.toDouble(),
      startQuantity: (json['start_quantity'] as num?)?.toInt(),
    );
  }
}

// ─────────────────────────────────────────────
// Interface
// ─────────────────────────────────────────────

abstract class OnlineOrdersRepositoryInterface {
  Future<List<OnlineOrderModel>> getPendingOrders();
  Future<List<OnlineOrderModel>> getAllOrders();
  Future<bool> updateOrderStatus(String orderId, String status);
}

// ─────────────────────────────────────────────
// Hybrid Repository
// ─────────────────────────────────────────────

class OnlineOrdersRepository implements OnlineOrdersRepositoryInterface {
  late final OnlineOrdersRepositoryInterface _dataSource;

  OnlineOrdersRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    // Assuming 'online_orders' feature flag
    if (MigrationService.isUsingSupabase('online_orders')) {
      log('OnlineOrdersRepository: Using Supabase');
      _dataSource = _OnlineOrdersSupabaseDataSource();
    } else {
      log('OnlineOrdersRepository: Using Dio (legacy)');
      _dataSource = _OnlineOrdersDioDataSource();
    }
  }

  @override
  Future<List<OnlineOrderModel>> getPendingOrders() => _dataSource.getPendingOrders();

  @override
  Future<List<OnlineOrderModel>> getAllOrders() => _dataSource.getAllOrders();

  @override
  Future<bool> updateOrderStatus(String orderId, String status) => _dataSource.updateOrderStatus(orderId, status);

  void enableSupabase() {
    MigrationService.enableSupabase('online_orders');
    _initializeDataSource();
  }

  void enableDio() {
    MigrationService.enableDio('online_orders');
    _initializeDataSource();
  }
}

// ─────────────────────────────────────────────
// Supabase Implementation
// ─────────────────────────────────────────────

class _OnlineOrdersSupabaseDataSource implements OnlineOrdersRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;
  static const String _table = 'online_orders';
  static const String _selectQuery = '''
    *,
    customer:customers!customer_id(id, name),
    branch:warehouses!branch_id(id, name),
    items:online_order_items(
      *,
      product:products!product_id(id, name)
    )
  ''';

  @override
  Future<List<OnlineOrderModel>> getPendingOrders() async {
    try {
      log('OnlineOrdersSupabase: Fetching pending orders');
      final response = await _client
          .from(_table)
          .select(_selectQuery)
          .inFilter('status', ['pending', 'processing'])
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        final model = SupabaseOnlineOrderModel.fromJson(json as Map<String, dynamic>);
        return model.toLegacyModel();
      }).toList();
    } catch (e) {
      log('OnlineOrdersSupabase: Error fetching pending orders - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<OnlineOrderModel>> getAllOrders() async {
    try {
      log('OnlineOrdersSupabase: Fetching all orders');
      final response = await _client
          .from(_table)
          .select(_selectQuery)
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        final model = SupabaseOnlineOrderModel.fromJson(json as Map<String, dynamic>);
        return model.toLegacyModel();
      }).toList();
    } catch (e) {
      log('OnlineOrdersSupabase: Error fetching all orders - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      log('OnlineOrdersSupabase: Updating order status $orderId -> $status');
      await _client.rpc('update_online_order_status', params: {
        'p_order_id': orderId,
        'p_status': status,
      });
      return true;
    } catch (e) {
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }
}

// ─────────────────────────────────────────────
// Dio (Legacy) Implementation
// ─────────────────────────────────────────────

class _OnlineOrdersDioDataSource implements OnlineOrdersRepositoryInterface {
  @override
  Future<List<OnlineOrderModel>> getPendingOrders() async {
    throw UnimplementedError('Not supported in legacy API');
  }

  @override
  Future<List<OnlineOrderModel>> getAllOrders() async {
    throw UnimplementedError('Not supported in legacy API');
  }

  @override
  Future<bool> updateOrderStatus(String orderId, String status) async {
    throw UnimplementedError('Not supported in legacy API');
  }
}
