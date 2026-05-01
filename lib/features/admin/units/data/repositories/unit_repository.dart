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
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      version: json['version'] as int,
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
        final model = UnitResponse.fromJson(response.data);
        if (model.success) {
          return model.data.units;
        }
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

}
