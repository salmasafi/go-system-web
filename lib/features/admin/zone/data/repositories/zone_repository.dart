import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/migration/migration_service.dart';
import '../../../../../core/services/dio_helper.dart';
import '../../../../../core/services/endpoints.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../../../../core/utils/error_handler.dart';
import 'package:systego/features/admin/zone/model/zone_model.dart';

/// Interface for zone data operations
abstract class ZoneRepositoryInterface {
  Future<List<ZoneModel>> getZones();
  Future<void> createZone({
    required String name,
    required String arName,
    required String countryId,
    required String cityId,
    required num cost,
  });
  Future<void> updateZone({
    required String zoneId,
    required String name,
    required String arName,
    required String countryId,
    required String cityId,
    required String cost,
  });
  Future<void> deleteZone(String zoneId);
}

/// Hybrid repository that supports both Dio and Supabase for zones
class ZoneRepository implements ZoneRepositoryInterface {
  late final ZoneRepositoryInterface _dataSource;

  ZoneRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('locations')) {
      log('ZoneRepository: Using Supabase');
      _dataSource = _ZoneSupabaseDataSource();
    } else {
      log('ZoneRepository: Using Dio (legacy)');
      _dataSource = _ZoneDioDataSource();
    }
  }

  @override
  Future<List<ZoneModel>> getZones() => _dataSource.getZones();

  @override
  Future<void> createZone({
    required String name,
    required String arName,
    required String countryId,
    required String cityId,
    required num cost,
  }) => _dataSource.createZone(
        name: name,
        arName: arName,
        countryId: countryId,
        cityId: cityId,
        cost: cost,
      );

  @override
  Future<void> updateZone({
    required String zoneId,
    required String name,
    required String arName,
    required String countryId,
    required String cityId,
    required String cost,
  }) => _dataSource.updateZone(
        zoneId: zoneId,
        name: name,
        arName: arName,
        countryId: countryId,
        cityId: cityId,
        cost: cost,
      );

  @override
  Future<void> deleteZone(String zoneId) => _dataSource.deleteZone(zoneId);
}

/// Supabase implementation for Zone data source
class _ZoneSupabaseDataSource implements ZoneRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<List<ZoneModel>> getZones() async {
    try {
      log('ZoneSupabase: Fetching all zones');
      final response = await _client.from('zones').select().order('name');
      return (response as List).map((json) => _mapSupabaseToZoneModel(json)).toList();
    } catch (e) {
      log('ZoneSupabase: Error fetching zones - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> createZone({
    required String name,
    required String arName,
    required String countryId,
    required String cityId,
    required num cost,
  }) async {
    try {
      log('ZoneSupabase: Creating zone: $name');
      await _client.from('zones').insert({
        'name': name,
        'ar_name': arName,
        'country_id': countryId,
        'city_id': cityId,
        'cost': cost.toDouble(),
      });
    } catch (e) {
      log('ZoneSupabase: Error creating zone - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> updateZone({
    required String zoneId,
    required String name,
    required String arName,
    required String countryId,
    required String cityId,
    required String cost,
  }) async {
    try {
      log('ZoneSupabase: Updating zone: $zoneId');
      await _client.from('zones').update({
        'name': name,
        'ar_name': arName,
        'country_id': countryId,
        'city_id': cityId,
        'cost': double.tryParse(cost) ?? 0.0,
      }).eq('id', zoneId);
    } catch (e) {
      log('ZoneSupabase: Error updating zone - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteZone(String zoneId) async {
    try {
      log('ZoneSupabase: Deleting zone: $zoneId');
      await _client.from('zones').delete().eq('id', zoneId);
    } catch (e) {
      log('ZoneSupabase: Error deleting zone - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  ZoneModel _mapSupabaseToZoneModel(Map<String, dynamic> json) {
    return ZoneModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      arName: json['ar_name'] ?? '',
      country: CountryForZone(
        id: json['country_id'] ?? '',
        name: '',
        arName: '',
      ),
      city: CityForZone(
        id: json['city_id'] ?? '',
        name: '',
        arName: '',
        shipingCost: 0,
      ),
      cost: json['cost'] ?? 0,
      version: json['version'] ?? 1,
    );
  }
}

/// Dio implementation for Zone data source (legacy)
class _ZoneDioDataSource implements ZoneRepositoryInterface {
  @override
  Future<List<ZoneModel>> getZones() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.getZones);
      if (response.statusCode == 200) {
        final model = ZoneResponse.fromJson(response.data as Map<String, dynamic>);
        return model.data.zones;
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> createZone({
    required String name,
    required String arName,
    required String countryId,
    required String cityId,
    required num cost,
  }) async {
    try {
      final response = await DioHelper.postData(
        url: EndPoint.createZone,
        data: {
          "name": name,
          "ar_name": arName,
          "countryId": countryId,
          "cityId": cityId,
          "cost": cost,
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
  Future<void> updateZone({
    required String zoneId,
    required String name,
    required String arName,
    required String countryId,
    required String cityId,
    required String cost,
  }) async {
    try {
      final response = await DioHelper.putData(
        url: EndPoint.updateZone(zoneId),
        data: {
          'name': name,
          "ar_name": arName,
          "countryId": countryId,
          "cityId": cityId,
          "cost": cost,
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
  Future<void> deleteZone(String zoneId) async {
    try {
      final response = await DioHelper.deleteData(url: EndPoint.deleteZone(zoneId));
      if (response.statusCode != 200) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }
}
