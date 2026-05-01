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
    required String arName,
    required String code,
    String? baseUnitId,
    String? operator,
    double? operatorValue,
  });
  Future<void> updateUnit({
    required String id,
    required String name,
    required String arName,
    required String code,
    String? baseUnitId,
    String? operator,
    double? operatorValue,
  });
  Future<void> deleteUnit(String id);
}

/// Hybrid repository that supports both Dio and Supabase for units
class UnitRepository implements UnitRepositoryInterface {
  late final UnitRepositoryInterface _dataSource;

  UnitRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('units')) {
      log('UnitRepository: Using Supabase');
      _dataSource = _UnitSupabaseDataSource();
    } else {
      log('UnitRepository: Using Dio (legacy)');
      _dataSource = _UnitDioDataSource();
    }
  }

  @override
  Future<List<UnitModel>> getAllUnits() => _dataSource.getAllUnits();

  @override
  Future<void> updateUnitStatus(String id, bool status) =>
      _dataSource.updateUnitStatus(id, status);

  @override
  Future<void> createUnit({
    required String name,
    required String arName,
    required String code,
    String? baseUnitId,
    String? operator,
    double? operatorValue,
  }) =>
      _dataSource.createUnit(
        name: name,
        arName: arName,
        code: code,
        baseUnitId: baseUnitId,
        operator: operator,
        operatorValue: operatorValue,
      );

  @override
  Future<void> updateUnit({
    required String id,
    required String name,
    required String arName,
    required String code,
    String? baseUnitId,
    String? operator,
    double? operatorValue,
  }) =>
      _dataSource.updateUnit(
        id: id,
        name: name,
        arName: arName,
        code: code,
        baseUnitId: baseUnitId,
        operator: operator,
        operatorValue: operatorValue,
      );

  @override
  Future<void> deleteUnit(String id) => _dataSource.deleteUnit(id);

  void enableSupabase() {
    MigrationService.enableSupabase('units');
    _initializeDataSource();
  }

  void enableDio() {
    MigrationService.enableDio('units');
    _initializeDataSource();
  }
}

/// Supabase implementation for Unit data source
class _UnitSupabaseDataSource implements UnitRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<List<UnitModel>> getAllUnits() async {
    try {
      log('UnitSupabase: Fetching all units');

      final response = await _client
          .from('units')
          .select('*, base_unit:base_unit_id(*)')
          .order('name');

      final units = (response as List)
          .map((json) => _mapSupabaseToUnitModel(json))
          .toList();

      log('UnitSupabase: Fetched ${units.length} units');
      return units;
    } catch (e) {
      log('UnitSupabase: Error fetching units - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> updateUnitStatus(String id, bool status) async {
    try {
      log('UnitSupabase: Updating unit status: $id to $status');
      await _client.from('units').update({'status': status}).eq('id', id);
    } catch (e) {
      log('UnitSupabase: Error updating unit status - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> createUnit({
    required String name,
    required String arName,
    required String code,
    String? baseUnitId,
    String? operator,
    double? operatorValue,
  }) async {
    try {
      log('UnitSupabase: Creating unit: $name');
      await _client.from('units').insert({
        'name': name,
        'ar_name': arName,
        'code': code,
        'base_unit_id': baseUnitId,
        'operator': operator,
        'operator_value': operatorValue,
        'status': true,
      });
    } catch (e) {
      log('UnitSupabase: Error creating unit - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> updateUnit({
    required String id,
    required String name,
    required String arName,
    required String code,
    String? baseUnitId,
    String? operator,
    double? operatorValue,
  }) async {
    try {
      log('UnitSupabase: Updating unit: $id');
      await _client.from('units').update({
        'name': name,
        'ar_name': arName,
        'code': code,
        'base_unit_id': baseUnitId,
        'operator': operator,
        'operator_value': operatorValue,
      }).eq('id', id);
    } catch (e) {
      log('UnitSupabase: Error updating unit - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteUnit(String id) async {
    try {
      log('UnitSupabase: Deleting unit: $id');
      await _client.from('units').delete().eq('id', id);
    } catch (e) {
      log('UnitSupabase: Error deleting unit - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  /// Map Supabase response to UnitModel
  UnitModel _mapSupabaseToUnitModel(Map<String, dynamic> json) {
    final baseUnit = json['base_unit'] as Map<String, dynamic>?;

    return UnitModel(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      arName: json['ar_name'] as String,
      baseUnit: baseUnit != null
          ? BaseUnit(
              id: baseUnit['id'] as String,
              code: baseUnit['code'] as String,
              name: baseUnit['name'] as String,
              arName: baseUnit['ar_name'] as String,
            )
          : null,
      operator: json['operator'] as String? ?? '',
      operatorValue: (json['operator_value'] as num?)?.toDouble() ?? 1.0,
      status: json['status'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      version: json['version'] as int? ?? 0,
    );
  }
}

/// Dio implementation for Unit data source (legacy)
class _UnitDioDataSource implements UnitRepositoryInterface {
  @override
  Future<List<UnitModel>> getAllUnits() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.getUnits);
      if (response.statusCode == 200) {
        final data = UnitResponse.fromJson(response.data);
        return data.data.units;
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> updateUnitStatus(String id, bool status) async {
    try {
      final response = await DioHelper.putData(
        url: EndPoint.updateUnitStatus(id),
        data: {'status': status},
      );
      if (response.statusCode != 200) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> createUnit({
    required String name,
    required String arName,
    required String code,
    String? baseUnitId,
    String? operator,
    double? operatorValue,
  }) async {
    try {
      final response = await DioHelper.postData(
        url: EndPoint.createUnit,
        data: {
          'name': name,
          'ar_name': arName,
          'code': code,
          'baseUnit_id': baseUnitId,
          'operator': operator,
          'operatorValue': operatorValue,
        },
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> updateUnit({
    required String id,
    required String name,
    required String arName,
    required String code,
    String? baseUnitId,
    String? operator,
    double? operatorValue,
  }) async {
    try {
      final response = await DioHelper.putData(
        url: EndPoint.updateUnit(id),
        data: {
          'name': name,
          'ar_name': arName,
          'code': code,
          'baseUnit_id': baseUnitId,
          'operator': operator,
          'operatorValue': operatorValue,
        },
      );
      if (response.statusCode != 200) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteUnit(String id) async {
    try {
      final response = await DioHelper.deleteData(url: EndPoint.deleteUnit(id));
      if (response.statusCode != 200) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }
}
