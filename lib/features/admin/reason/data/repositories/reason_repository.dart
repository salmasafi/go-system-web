import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../model/reason_model.dart';

/// Interface for reason data operations
abstract class ReasonRepositoryInterface {
  Future<List<ReasonModel>> getAllReasons();
  Future<void> createReason(String reason);
  Future<void> updateReason(String id, String reason);
  Future<void> deleteReason(String id);
}

/// Repository implementation using Supabase for reasons
class ReasonRepository implements ReasonRepositoryInterface {
  final _ReasonSupabaseDataSource _dataSource = _ReasonSupabaseDataSource();

  @override
  Future<List<ReasonModel>> getAllReasons() => _dataSource.getAllReasons();

  @override
  Future<void> createReason(String reason) => _dataSource.createReason(reason);

  @override
  Future<void> updateReason(String id, String reason) =>
      _dataSource.updateReason(id, reason);

  @override
  Future<void> deleteReason(String id) => _dataSource.deleteReason(id);
}

/// Supabase implementation for Reason data source
class _ReasonSupabaseDataSource implements ReasonRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<List<ReasonModel>> getAllReasons() async {
    try {
      log('ReasonSupabase: Fetching all reasons');
      final response = await _client.from('reasons').select().order('reason');
      return (response as List)
          .map((json) => _mapSupabaseToReasonModel(json))
          .toList();
    } catch (e) {
      log('ReasonSupabase: Error fetching reasons - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> createReason(String reason) async {
    try {
      log('ReasonSupabase: Creating reason: $reason');
      await _client.from('reasons').insert({'reason': reason});
    } catch (e) {
      log('ReasonSupabase: Error creating reason - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> updateReason(String id, String reason) async {
    try {
      log('ReasonSupabase: Updating reason: $id');
      await _client.from('reasons').update({'reason': reason}).eq('id', id);
    } catch (e) {
      log('ReasonSupabase: Error updating reason - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteReason(String id) async {
    try {
      log('ReasonSupabase: Deleting reason: $id');
      await _client.from('reasons').delete().eq('id', id);
    } catch (e) {
      log('ReasonSupabase: Error deleting reason - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  ReasonModel _mapSupabaseToReasonModel(Map<String, dynamic> json) {
    return ReasonModel(
      id: json['id'] ?? '',
      reason: json['reason'] ?? '',

      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      // updatedAt: json['updated_at'] != null
      //     ? DateTime.parse(json['updated_at'])
      //     : DateTime.now(),
      version: json['version'] ?? 1,
    );
  }
}
