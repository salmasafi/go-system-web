import 'dart:developer';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/migration/migration_service.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/storage_service.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../models/adjustment_model.dart';

/// Interface for adjustment data operations
abstract class AdjustmentRepositoryInterface {
  Future<List<AdjustmentModel>> getAllAdjustments({int? limit, int? offset});
  Future<AdjustmentModel?> getAdjustmentById(String id);
  Future<AdjustmentModel> createAdjustment({
    required String warehouseId,
    required String type, // 'increase' or 'decrease'
    required String reason,
    required List<Map<String, dynamic>> items,
    String? note,
    File? attachmentFile,
  });
  Future<bool> cancelAdjustment(String id);
  Future<List<AdjustmentModel>> getAdjustmentsByWarehouse(String warehouseId);
}

/// Hybrid repository that supports both Dio and Supabase for adjustments
class AdjustmentRepository implements AdjustmentRepositoryInterface {
  late final AdjustmentRepositoryInterface _dataSource;

  AdjustmentRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('adjustments')) {
      log('AdjustmentRepository: Using Supabase');
      _dataSource = _AdjustmentSupabaseDataSource();
    } else {
      log('AdjustmentRepository: Using Dio (legacy) - Not implemented');
      throw UnimplementedError('Dio implementation for adjustments not available');
    }
  }

  @override
  Future<List<AdjustmentModel>> getAllAdjustments({int? limit, int? offset}) =>
      _dataSource.getAllAdjustments(limit: limit, offset: offset);

  @override
  Future<AdjustmentModel?> getAdjustmentById(String id) =>
      _dataSource.getAdjustmentById(id);

  @override
  Future<AdjustmentModel> createAdjustment({
    required String warehouseId,
    required String type,
    required String reason,
    required List<Map<String, dynamic>> items,
    String? note,
    File? attachmentFile,
  }) => _dataSource.createAdjustment(
    warehouseId: warehouseId,
    type: type,
    reason: reason,
    items: items,
    note: note,
    attachmentFile: attachmentFile,
  );

  @override
  Future<bool> cancelAdjustment(String id) =>
      _dataSource.cancelAdjustment(id);

  @override
  Future<List<AdjustmentModel>> getAdjustmentsByWarehouse(String warehouseId) =>
      _dataSource.getAdjustmentsByWarehouse(warehouseId);

  void enableSupabase() {
    MigrationService.enableSupabase('adjustments');
    _initializeDataSource();
  }

  void enableDio() {
    MigrationService.enableDio('adjustments');
    _initializeDataSource();
  }
}

/// Supabase implementation for Adjustment data source
class _AdjustmentSupabaseDataSource implements AdjustmentRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;
  final StorageService _storage = StorageService(SupabaseClientWrapper.instance);

  @override
  Future<List<AdjustmentModel>> getAllAdjustments({int? limit, int? offset}) async {
    try {
      log('AdjustmentSupabase: Fetching all adjustments');

      var query = _client
          .from('adjustments')
          .select('''
            *,
            warehouse:warehouse_id(id, name),
            items:adjustment_items(
              *,
              product:product_id(id, name, code)
            ),
            created_by_user:created_by(id, email, full_name)
          ''')
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;

      return (response as List)
          .map((json) => _mapSupabaseToAdjustmentModel(json))
          .toList();
    } catch (e) {
      log('AdjustmentSupabase: Error fetching adjustments - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<AdjustmentModel?> getAdjustmentById(String id) async {
    try {
      log('AdjustmentSupabase: Fetching adjustment by id: $id');

      final response = await _client
          .from('adjustments')
          .select('''
            *,
            warehouse:warehouse_id(id, name),
            items:adjustment_items(
              *,
              product:product_id(id, name, code)
            ),
            created_by_user:created_by(id, email, full_name)
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return _mapSupabaseToAdjustmentModel(response);
    } catch (e) {
      log('AdjustmentSupabase: Error fetching adjustment - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<AdjustmentModel> createAdjustment({
    required String warehouseId,
    required String type,
    required String reason,
    required List<Map<String, dynamic>> items,
    String? note,
    File? attachmentFile,
  }) async {
    try {
      log('AdjustmentSupabase: Creating adjustment for warehouse: $warehouseId');

      // Upload attachment if provided
      String? attachmentUrl;
      if (attachmentFile != null) {
        attachmentUrl = await _storage.uploadImage(
          file: attachmentFile,
          folder: 'adjustment_attachments',
          fileName: 'adjustment_${DateTime.now().millisecondsSinceEpoch}.jpg',
          maxWidth: 1200,
        );
      }

      // Use RPC for atomic transaction
      final response = await _client.rpc('create_adjustment', params: {
        'p_warehouse_id': warehouseId,
        'p_type': type,
        'p_reason': reason,
        'p_items': items,
        'p_note': note ?? '',
        'p_attachment_url': attachmentUrl ?? '',
      });

      log('AdjustmentSupabase: Adjustment created successfully');
      return await getAdjustmentById(response['adjustment_id']) as AdjustmentModel;
    } catch (e) {
      log('AdjustmentSupabase: Error creating adjustment - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> cancelAdjustment(String id) async {
    try {
      log('AdjustmentSupabase: Cancelling adjustment: $id');

      await _client
          .from('adjustments')
          .update({'status': 'cancelled', 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', id);

      return true;
    } catch (e) {
      log('AdjustmentSupabase: Error cancelling adjustment - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<AdjustmentModel>> getAdjustmentsByWarehouse(String warehouseId) async {
    try {
      log('AdjustmentSupabase: Fetching adjustments for warehouse: $warehouseId');

      final response = await _client
          .from('adjustments')
          .select('''
            *,
            warehouse:warehouse_id(id, name),
            items:adjustment_items(
              *,
              product:product_id(id, name, code)
            ),
            created_by_user:created_by(id, email, full_name)
          ''')
          .eq('warehouse_id', warehouseId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => _mapSupabaseToAdjustmentModel(json))
          .toList();
    } catch (e) {
      log('AdjustmentSupabase: Error fetching warehouse adjustments - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  /// Map Supabase response to AdjustmentModel
  AdjustmentModel _mapSupabaseToAdjustmentModel(Map<String, dynamic> json) {
    final warehouse = json['warehouse'] as Map<String, dynamic>?;
    final createdBy = json['created_by_user'] as Map<String, dynamic>?;
    final items = (json['items'] as List? ?? [])
        .map((item) {
          final product = item['product'] as Map<String, dynamic>?;
          return AdjustmentItemModel(
            id: item['id'] ?? '',
            adjustmentId: item['adjustment_id'] ?? '',
            productId: item['product_id'] ?? '',
            productName: product?['name'] ?? 'Unknown',
            productCode: product?['code'] ?? '',
            quantity: (item['quantity'] as num?)?.toInt() ?? 0,
            currentStock: (item['current_stock'] as num?)?.toInt() ?? 0,
            newStock: (item['new_stock'] as num?)?.toInt() ?? 0,
            unitCost: (item['unit_cost'] as num?)?.toDouble() ?? 0.0,
            totalCost: (item['total_cost'] as num?)?.toDouble() ?? 0.0,
            reason: item['reason'] ?? '',
          );
        })
        .toList();

    return AdjustmentModel(
      id: json['id'] ?? '',
      reference: json['reference'] ?? '',
      warehouseId: json['warehouse_id'] ?? '',
      warehouseName: warehouse?['name'] ?? '',
      type: json['type'] ?? 'increase',
      reason: json['reason'] ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'completed',
      note: json['note'] ?? '',
      attachmentUrl: json['attachment_url'],
      createdAt: json['created_at'] ?? '',
      createdBy: createdBy?['full_name'] ?? createdBy?['email'] ?? '',
      items: items,
    );
  }
}
