import 'dart:developer';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/migration/migration_service.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/storage_service.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../model/adjustment_model.dart';

// ─────────────────────────────────────────────
// Supabase-specific model (matches adjustments table)
// ─────────────────────────────────────────────

class SupabaseAdjustmentModel {
  final String id;
  final String reference;
  final String warehouseId;
  final String? warehouseName;
  final String type; // 'increase' | 'decrease'
  final String reason;
  final double totalAmount;
  final String status;
  final String? note;
  final String? attachmentUrl;
  final DateTime createdAt;
  final List<SupabaseAdjustmentItem> items;

  SupabaseAdjustmentModel({
    required this.id,
    required this.reference,
    required this.warehouseId,
    this.warehouseName,
    required this.type,
    required this.reason,
    required this.totalAmount,
    required this.status,
    this.note,
    this.attachmentUrl,
    required this.createdAt,
    this.items = const [],
  });

  factory SupabaseAdjustmentModel.fromJson(Map<String, dynamic> json) {
    final warehouse = json['warehouse'] as Map<String, dynamic>?;
    return SupabaseAdjustmentModel(
      id: json['id'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      warehouseId: json['warehouse_id'] as String? ?? '',
      warehouseName: warehouse?['name'] as String?,
      type: json['type'] as String? ?? 'increase',
      reason: json['reason'] as String? ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'completed',
      note: json['note'] as String?,
      attachmentUrl: json['attachment_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      items: (json['items'] as List? ?? [])
          .map((e) => SupabaseAdjustmentItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convert to legacy AdjustmentModel for backward compatibility
  AdjustmentModel toLegacyModel() {
    return AdjustmentModel(
      id: id,
      warehouseId: warehouseId,
      productId: items.isNotEmpty ? items.first.productId : '',
      quantity: items.fold(0, (sum, item) => sum + item.quantity),
      selectReasonId: reason,
      note: note ?? '',
      image: attachmentUrl,
      createdAt: createdAt,
      version: 0,
    );
  }
}

class SupabaseAdjustmentItem {
  final String id;
  final String adjustmentId;
  final String productId;
  final String? productName;
  final int quantity;
  final int currentStock;
  final int newStock;
  final double unitCost;
  final double totalCost;
  final String? reason;

  SupabaseAdjustmentItem({
    required this.id,
    required this.adjustmentId,
    required this.productId,
    this.productName,
    required this.quantity,
    required this.currentStock,
    required this.newStock,
    required this.unitCost,
    required this.totalCost,
    this.reason,
  });

  factory SupabaseAdjustmentItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    return SupabaseAdjustmentItem(
      id: json['id'] as String? ?? '',
      adjustmentId: json['adjustment_id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      productName: product?['name'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      currentStock: (json['current_stock'] as num?)?.toInt() ?? 0,
      newStock: (json['new_stock'] as num?)?.toInt() ?? 0,
      unitCost: (json['unit_cost'] as num?)?.toDouble() ?? 0.0,
      totalCost: (json['total_cost'] as num?)?.toDouble() ?? 0.0,
      reason: json['reason'] as String?,
    );
  }
}

// ─────────────────────────────────────────────
// Interface
// ─────────────────────────────────────────────

abstract class AdjustmentRepositoryInterface {
  Future<List<SupabaseAdjustmentModel>> getAllAdjustments();
  Future<SupabaseAdjustmentModel?> getAdjustmentById(String id);
  Future<SupabaseAdjustmentModel> createAdjustment({
    required String warehouseId,
    required String type,
    required String reason,
    required List<Map<String, dynamic>> items,
    String? note,
    File? attachmentFile,
  });
  Future<bool> reverseAdjustment(String adjustmentId);
  Future<void> updateAdjustment({
    required String id,
    required String warehouseId,
    required String productId,
    required int quantity,
    required String reasonId,
    required String note,
    File? imageFile,
  });
}

// ─────────────────────────────────────────────
// Hybrid Repository
// ─────────────────────────────────────────────

/// Adjustment repository using Supabase as the primary data source.
class AdjustmentRepository implements AdjustmentRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;
  final StorageService _storage =
      StorageService(SupabaseClientWrapper.instance);

  static const String _table = 'adjustments';
  static const String _selectQuery = '''
    *,
    warehouse:warehouse_id(id, name),
    items:adjustment_items(
      *,
      product:product_id(id, name, code)
    )
  ''';

  @override
  Future<List<SupabaseAdjustmentModel>> getAllAdjustments() async {
    try {
      log('AdjustmentRepository: Fetching all adjustments');
      final response = await _client
          .from(_table)
          .select(_selectQuery)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) =>
              SupabaseAdjustmentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('AdjustmentRepository: Error fetching adjustments - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<SupabaseAdjustmentModel?> getAdjustmentById(String id) async {
    try {
      log('AdjustmentRepository: Fetching adjustment by id: $id');
      final response = await _client
          .from(_table)
          .select(_selectQuery)
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return SupabaseAdjustmentModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      log('AdjustmentRepository: Error fetching adjustment - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<SupabaseAdjustmentModel> createAdjustment({
    required String warehouseId,
    required String type,
    required String reason,
    required List<Map<String, dynamic>> items,
    String? note,
    File? attachmentFile,
  }) async {
    try {
      log('AdjustmentRepository: Creating adjustment for warehouse: $warehouseId');

      // Upload attachment if provided
      String? attachmentUrl;
      if (attachmentFile != null) {
        attachmentUrl = await _storage.uploadImage(
          file: attachmentFile,
          folder: 'adjustment_attachments',
          fileName: 'adj_${DateTime.now().millisecondsSinceEpoch}.jpg',
          maxWidth: 1200,
        );
      }

      // Call RPC for atomic transaction
      final response = await _client.rpc('create_adjustment', params: {
        'p_warehouse_id': warehouseId,
        'p_type': type,
        'p_reason': reason,
        'p_items': items,
        'p_note': note ?? '',
        'p_attachment_url': attachmentUrl ?? '',
      });

      log('AdjustmentRepository: Adjustment created - ${response['adjustment_id']}');
      final created =
          await getAdjustmentById(response['adjustment_id'] as String);
      return created!;
    } catch (e) {
      log('AdjustmentRepository: Error creating adjustment - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> reverseAdjustment(String adjustmentId) async {
    try {
      log('AdjustmentRepository: Reversing adjustment: $adjustmentId');
      await _client.rpc('reverse_adjustment', params: {
        'p_adjustment_id': adjustmentId,
      });
      return true;
    } catch (e) {
      log('AdjustmentRepository: Error reversing adjustment - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> updateAdjustment({
    required String id,
    required String warehouseId,
    required String productId,
    required int quantity,
    required String reasonId,
    required String note,
    File? imageFile,
  }) async {
    try {
      log('AdjustmentRepository: Updating adjustment: $id');

      // Upload attachment if provided
      String? attachmentUrl;
      if (imageFile != null) {
        attachmentUrl = await _storage.uploadImage(
          file: imageFile,
          folder: 'adjustment_attachments',
          fileName: 'adj_${id}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          maxWidth: 1200,
        );
      }

      await _client.from(_table).update({
        'warehouse_id': warehouseId,
        'reason': reasonId,
        'note': note,
        if (attachmentUrl != null) 'attachment_url': attachmentUrl,
      }).eq('id', id);

      // Note: Updating items is complex because it affects inventory.
      // Usually, adjustments are reversed and recreated.
      // For now, only update top-level fields.
    } catch (e) {
      log('AdjustmentRepository: Error updating adjustment - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }
}

// ─────────────────────────────────────────────
// Supabase Implementation


