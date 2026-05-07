import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/migration/migration_service.dart';
import '../../../../../core/services/dio_helper.dart';
import '../../../../../core/services/endpoints.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../model/unit_model.dart';

/// Interface for unit data operations
abstract class UnitRepositoryInterface {
  Future<List<UnitModel>> getAllUnits();
  Future<void> updateUnitStatus(String id, bool status);
  Future<void> createUnit({
    required String name,
    required String code,
    String? operator,
    double? operatorValue,
  });
  Future<void> updateUnit({
    required String id,
    required String name,
    required String code,
    String? operator,
    double? operatorValue,
  });
  Future<void> deleteUnit(String id);
}

/// Hybrid repository that supports both Dio and Supabase for units
/// Unit repository using Supabase as the primary data source.
class UnitRepository implements UnitRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<List<UnitModel>> getAllUnits() async {
    try {
      log('UnitRepository: Fetching all units');

      final response = await _client
          .from('units')
          .select('*')
          .order('name');

      final units = (response as List)
          .map((json) => _mapSupabaseToUnitModel(json))
          .toList();

      log('UnitRepository: Fetched ${units.length} units');
      return units;
    } catch (e) {
      log('UnitRepository: Error fetching units - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> updateUnitStatus(String id, bool status) async {
    try {
      log('UnitRepository: Updating unit status: $id to $status');
      await _client.from('units').update({'status': status}).eq('id', id);
    } catch (e) {
      log('UnitRepository: Error updating unit status - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> createUnit({
    required String name,
    required String code,
    String? operator,
    double? operatorValue,
  }) async {
    try {
      log('UnitRepository: Creating unit: $name');
      await _client.from('units').insert({
        'name': name,
        'code': code,
        'operator': operator,
        'operator_value': operatorValue,
        'status': true,
      });
    } catch (e) {
      log('UnitRepository: Error creating unit - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> updateUnit({
    required String id,
    required String name,
    required String code,
    String? operator,
    double? operatorValue,
  }) async {
    try {
      log('UnitRepository: Updating unit: $id');
      await _client.from('units').update({
        'name': name,
        'code': code,
        'operator': operator,
        'operator_value': operatorValue,
      }).eq('id', id);
    } catch (e) {
      log('UnitRepository: Error updating unit - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteUnit(String id) async {
    try {
      log('UnitRepository: Deleting unit: $id');
      await _client.from('units').delete().eq('id', id);
    } catch (e) {
      log('UnitRepository: Error deleting unit - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  /// Map Supabase response to UnitModel
  UnitModel _mapSupabaseToUnitModel(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      operator: json['operator']?.toString() ?? '*',
      operatorValue: (json['operator_value'] as num?)?.toDouble() ?? 1.0,
      status: json['status'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : DateTime.now(),
      version: json['version'] as int? ?? 1,
    );
  }
}
