import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/migration/migration_service.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/core/supabase/supabase_error_handler.dart';
import '../../model/transfer_model.dart';

// ─────────────────────────────────────────────
// Supabase-specific model (matches transfers + transfer_items tables)
// ─────────────────────────────────────────────

class SupabaseTransferModel {
  final String id;
  final String fromWarehouseId;
  final String? fromWarehouseName;
  final String toWarehouseId;
  final String? toWarehouseName;
  final String status; // 'pending', 'completed', 'cancelled'
  final String? reference;
  final String? notes;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<SupabaseTransferItem> items;

  SupabaseTransferModel({
    required this.id,
    required this.fromWarehouseId,
    this.fromWarehouseName,
    required this.toWarehouseId,
    this.toWarehouseName,
    required this.status,
    this.reference,
    this.notes,
    required this.createdAt,
    this.completedAt,
    this.items = const [],
  });

  factory SupabaseTransferModel.fromJson(Map<String, dynamic> json) {
    final fromWh = json['from_warehouse'] as Map<String, dynamic>?;
    final toWh = json['to_warehouse'] as Map<String, dynamic>?;
    return SupabaseTransferModel(
      id: json['id'] as String? ?? '',
      fromWarehouseId: json['from_warehouse_id'] as String? ?? '',
      fromWarehouseName: fromWh?['name'] as String?,
      toWarehouseId: json['to_warehouse_id'] as String? ?? '',
      toWarehouseName: toWh?['name'] as String?,
      status: json['status'] as String? ?? 'pending',
      reference: json['reference'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      items: (json['items'] as List? ?? [])
          .map((e) =>
              SupabaseTransferItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convert to legacy TransferModel for backward compatibility
  TransferModel toLegacyModel() {
    return TransferModel(
      id: id,
      fromWarehouse: fromWarehouseName != null
          ? WarehouseLiteModel(
              id: fromWarehouseId, name: fromWarehouseName!)
          : null,
      toWarehouse: toWarehouseName != null
          ? WarehouseLiteModel(id: toWarehouseId, name: toWarehouseName!)
          : null,
      products: items
          .map((item) => TransferProductModel(
                id: item.id,
                quantity: item.quantity,
                productName: item.productName ?? 'Unknown',
                productId: item.productId,
              ))
          .toList(),
      status: status,
      date: createdAt.toIso8601String(),
      reference: reference ?? '',
    );
  }
}

class SupabaseTransferItem {
  final String id;
  final String transferId;
  final String productId;
  final String? productName;
  final int quantity;
  final int receivedQuantity;
  final String status;
  final String? notes;

  SupabaseTransferItem({
    required this.id,
    required this.transferId,
    required this.productId,
    this.productName,
    required this.quantity,
    required this.receivedQuantity,
    required this.status,
    this.notes,
  });

  factory SupabaseTransferItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    return SupabaseTransferItem(
      id: json['id'] as String? ?? '',
      transferId: json['transfer_id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      productName: product?['name'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      receivedQuantity: (json['received_quantity'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
    );
  }
}

// ─────────────────────────────────────────────
// Interface
// ─────────────────────────────────────────────

abstract class TransferRepositoryInterface {
  Future<List<SupabaseTransferModel>> getAllTransfers();
  Future<List<SupabaseTransferModel>> getIncomingTransfers(String warehouseId);
  Future<List<SupabaseTransferModel>> getOutgoingTransfers(String warehouseId);
  Future<SupabaseTransferModel?> getTransferById(String id);
  Future<SupabaseTransferModel> createTransfer({
    required String fromWarehouseId,
    required String toWarehouseId,
    required List<Map<String, dynamic>> items,
    String? notes,
  });
  Future<bool> approveTransfer(String transferId);
  Future<bool> validateSourceWarehouseQuantity({
    required String warehouseId,
    required List<Map<String, dynamic>> items,
  });
}

// ─────────────────────────────────────────────
// Hybrid Repository
// ─────────────────────────────────────────────

class TransferRepository implements TransferRepositoryInterface {
  late TransferRepositoryInterface _dataSource;

  TransferRepository() {
    _dataSource = _TransferSupabaseDataSource();
  }

  @override
  Future<List<SupabaseTransferModel>> getAllTransfers() =>
      _dataSource.getAllTransfers();

  @override
  Future<List<SupabaseTransferModel>> getIncomingTransfers(
          String warehouseId) =>
      _dataSource.getIncomingTransfers(warehouseId);

  @override
  Future<List<SupabaseTransferModel>> getOutgoingTransfers(
          String warehouseId) =>
      _dataSource.getOutgoingTransfers(warehouseId);

  @override
  Future<SupabaseTransferModel?> getTransferById(String id) =>
      _dataSource.getTransferById(id);

  @override
  Future<SupabaseTransferModel> createTransfer({
    required String fromWarehouseId,
    required String toWarehouseId,
    required List<Map<String, dynamic>> items,
    String? notes,
  }) =>
      _dataSource.createTransfer(
        fromWarehouseId: fromWarehouseId,
        toWarehouseId: toWarehouseId,
        items: items,
        notes: notes,
      );

  @override
  Future<bool> approveTransfer(String transferId) =>
      _dataSource.approveTransfer(transferId);

  @override
  Future<bool> validateSourceWarehouseQuantity({
    required String warehouseId,
    required List<Map<String, dynamic>> items,
  }) =>
      _dataSource.validateSourceWarehouseQuantity(
        warehouseId: warehouseId,
        items: items,
      );


}

// ─────────────────────────────────────────────
// Supabase Implementation
// ─────────────────────────────────────────────

class _TransferSupabaseDataSource implements TransferRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  static const String _table = 'transfers';
  static const String _selectQuery = '''
    *,
    from_warehouse:from_warehouse_id(id, name),
    to_warehouse:to_warehouse_id(id, name),
    items:transfer_items(
      *,
      product:product_id(id, name, code)
    )
  ''';

  @override
  Future<List<SupabaseTransferModel>> getAllTransfers() async {
    try {
      log('TransferSupabase: Fetching all transfers');
      final response = await _client
          .from(_table)
          .select(_selectQuery)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) =>
              SupabaseTransferModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('TransferSupabase: Error fetching transfers - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<SupabaseTransferModel>> getIncomingTransfers(
      String warehouseId) async {
    try {
      log('TransferSupabase: Fetching incoming transfers for warehouse: $warehouseId');
      final response = await _client
          .from(_table)
          .select(_selectQuery)
          .eq('to_warehouse_id', warehouseId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) =>
              SupabaseTransferModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('TransferSupabase: Error fetching incoming transfers - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<SupabaseTransferModel>> getOutgoingTransfers(
      String warehouseId) async {
    try {
      log('TransferSupabase: Fetching outgoing transfers for warehouse: $warehouseId');
      final response = await _client
          .from(_table)
          .select(_selectQuery)
          .eq('from_warehouse_id', warehouseId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) =>
              SupabaseTransferModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('TransferSupabase: Error fetching outgoing transfers - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<SupabaseTransferModel?> getTransferById(String id) async {
    try {
      log('TransferSupabase: Fetching transfer by id: $id');
      final response = await _client
          .from(_table)
          .select(_selectQuery)
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return SupabaseTransferModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      log('TransferSupabase: Error fetching transfer - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<SupabaseTransferModel> createTransfer({
    required String fromWarehouseId,
    required String toWarehouseId,
    required List<Map<String, dynamic>> items,
    String? notes,
  }) async {
    try {
      log('TransferSupabase: Creating transfer from $fromWarehouseId to $toWarehouseId');

      // Validate source warehouse has enough stock first
      await validateSourceWarehouseQuantity(
        warehouseId: fromWarehouseId,
        items: items,
      );

      // Generate reference
      final reference =
          'TRF-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      // Insert transfer record
      final transfer = await _client.from(_table).insert({
        'from_warehouse_id': fromWarehouseId,
        'to_warehouse_id': toWarehouseId,
        'status': 'pending',
        'reference': reference,
        'notes': notes,
      }).select('id').single();

      final transferId = transfer['id'] as String;

      // Insert transfer items
      final transferItems = items
          .map((item) => {
                'transfer_id': transferId,
                'product_id': item['product_id'],
                'quantity': item['quantity'],
                'status': 'pending',
              })
          .toList();

      await _client.from('transfer_items').insert(transferItems);

      log('TransferSupabase: Transfer created: $transferId');
      final created = await getTransferById(transferId);
      return created!;
    } catch (e) {
      log('TransferSupabase: Error creating transfer - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> approveTransfer(String transferId) async {
    try {
      log('TransferSupabase: Approving transfer: $transferId');

      // Get transfer details
      final transfer = await getTransferById(transferId);
      if (transfer == null) throw Exception('Transfer not found');

      // Move quantities: deduct from source, add to destination
      for (final item in transfer.items) {
        await _client.rpc('transfer_product_between_warehouses', params: {
          'p_from_warehouse_id': transfer.fromWarehouseId,
          'p_to_warehouse_id': transfer.toWarehouseId,
          'p_product_id': item.productId,
          'p_quantity': item.quantity,
        });

        // Mark item as received
        await _client
            .from('transfer_items')
            .update({'status': 'received', 'received_quantity': item.quantity})
            .eq('id', item.id);
      }

      // Update transfer status
      await _client.from(_table).update({
        'status': 'completed',
        'completed_at': DateTime.now().toIso8601String(),
      }).eq('id', transferId);

      return true;
    } catch (e) {
      log('TransferSupabase: Error approving transfer - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> validateSourceWarehouseQuantity({
    required String warehouseId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      log('TransferSupabase: Validating source warehouse stock for $warehouseId');

      for (final item in items) {
        final productId = item['product_id'] as String;
        final requestedQty = item['quantity'] as int;

        final result = await _client
            .from('warehouse_products')
            .select('quantity')
            .eq('warehouse_id', warehouseId)
            .eq('product_id', productId)
            .maybeSingle();

        if (result == null) {
          throw Exception(
              'Product $productId not found in source warehouse');
        }
        final available = (result['quantity'] as num?)?.toInt() ?? 0;
        if (available < requestedQty) {
          throw Exception(
              'Insufficient stock for product $productId. Available: $available, Requested: $requestedQty');
        }
      }
      return true;
    } catch (e) {
      log('TransferSupabase: Validation failed - $e');
      rethrow;
    }
  }
}


