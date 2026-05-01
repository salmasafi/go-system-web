import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/migration/migration_service.dart';
import '../../../../../core/services/dio_helper.dart';
import '../../../../../core/services/endpoints.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../../../../core/utils/error_handler.dart';
import 'package:systego/features/admin/city/model/city_model.dart';
import 'package:systego/features/admin/country/model/country_model.dart';

/// Interface for city data operations
abstract class CityRepositoryInterface {
  Future<CityData> getCities();
  Future<void> createCity({
    required String name,
    required String arName,
    required String countryId,
    required String shipingCost,
  });
  Future<void> updateCity({
    required String cityId,
    required String name,
    required String arName,
    required String countryId,
    required String shipingCost,
  });
  Future<void> deleteCity(String cityId);
}

/// Hybrid repository that supports both Dio and Supabase for cities
class CityRepository implements CityRepositoryInterface {
  late final CityRepositoryInterface _dataSource;

  CityRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('locations')) {
      log('CityRepository: Using Supabase');
      _dataSource = _CitySupabaseDataSource();
    } else {
      log('CityRepository: Using Dio (legacy)');
      _dataSource = _CityDioDataSource();
    }
  }

  @override
  Future<CityData> getCities() => _dataSource.getCities();

  @override
  Future<void> createCity({
    required String name,
    required String arName,
    required String countryId,
    required String shipingCost,
  }) => _dataSource.createCity(
    name: name,
    arName: arName,
    countryId: countryId,
    shipingCost: shipingCost,
  );

  @override
  Future<void> updateCity({
    required String cityId,
    required String name,
    required String arName,
    required String countryId,
    required String shipingCost,
  }) => _dataSource.updateCity(
    cityId: cityId,
    name: name,
    arName: arName,
    countryId: countryId,
    shipingCost: shipingCost,
  );

  @override
  Future<void> deleteCity(String cityId) => _dataSource.deleteCity(cityId);
}

/// Supabase implementation for City data source
class _CitySupabaseDataSource implements CityRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<CityData> getCities() async {
    try {
      log('CitySupabase: Fetching all cities and countries');

      // Fetch cities
      final citiesResponse = await _client
          .from('cities')
          .select()
          .order('name');
      final cities = (citiesResponse as List)
          .map((json) => _mapSupabaseToCityModel(json))
          .toList();

      // Fetch countries
      final countriesResponse = await _client
          .from('countries')
          .select()
          .order('name');
      final countries = (countriesResponse as List)
          .map((json) => CountryModel.fromJson(json))
          .toList();

      return CityData(cities: cities, countries: countries, message: 'Success');
    } catch (e) {
      log('CitySupabase: Error fetching cities - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> createCity({
    required String name,
    required String arName,
    required String countryId,
    required String shipingCost,
  }) async {
    try {
      log('CitySupabase: Creating city: $name');
      await _client.from('cities').insert({
        'name': name,
        'ar_name': arName,
        'country_id': countryId,
        'shipping_cost': double.tryParse(shipingCost) ?? 0.0,
      });
    } catch (e) {
      log('CitySupabase: Error creating city - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> updateCity({
    required String cityId,
    required String name,
    required String arName,
    required String countryId,
    required String shipingCost,
  }) async {
    try {
      log('CitySupabase: Updating city: $cityId');
      await _client
          .from('cities')
          .update({
            'name': name,
            'ar_name': arName,
            'country_id': countryId,
            'shipping_cost': double.tryParse(shipingCost) ?? 0.0,
          })
          .eq('id', cityId);
    } catch (e) {
      log('CitySupabase: Error updating city - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteCity(String cityId) async {
    try {
      log('CitySupabase: Deleting city: $cityId');
      await _client.from('cities').delete().eq('id', cityId);
    } catch (e) {
      log('CitySupabase: Error deleting city - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  CityModel _mapSupabaseToCityModel(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      arName: json['ar_name'] ?? '',
      country: json['country_id'] != null
          ? CountryModel(
              id: json['country_id'],
              name: '',
              arName: '',
              isDefault: false,
              version: 0,
            )
          : null,
      shipingCost: json['shipping_cost'] ?? 0,
      version: json['version'] ?? 1,
    );
  }
}

/// Dio implementation for City data source (legacy)
class _CityDioDataSource implements CityRepositoryInterface {
  @override
  Future<CityData> getCities() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.getCities);
      if (response.statusCode == 200) {
        final model = CityResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
        return model.data;
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> createCity({
    required String name,
    required String arName,
    required String countryId,
    required String shipingCost,
  }) async {
    try {
      final response = await DioHelper.postData(
        url: EndPoint.createCity,
        data: {
          "name": name,
          "ar_name": arName,
          "country": countryId,
          "shipingCost": shipingCost,
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
  Future<void> updateCity({
    required String cityId,
    required String name,
    required String arName,
    required String countryId,
    required String shipingCost,
  }) async {
    try {
      final response = await DioHelper.putData(
        url: EndPoint.updateCity(cityId),
        data: {
          'name': name,
          "ar_name": arName,
          "country": countryId,
          "shipingCost": shipingCost,
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
  Future<void> deleteCity(String cityId) async {
    try {
      final response = await DioHelper.deleteData(
        url: EndPoint.deleteCity(cityId),
      );
      if (response.statusCode != 200) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }
}
