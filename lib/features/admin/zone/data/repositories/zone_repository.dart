import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import 'package:GoSystem/features/admin/zone/model/zone_model.dart';

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

/// Repository implementation using Supabase for zones
class ZoneRepository implements ZoneRepositoryInterface {
  final _ZoneSupabaseDataSource _dataSource = _ZoneSupabaseDataSource();

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
