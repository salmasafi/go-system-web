import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/migration/migration_service.dart';
import '../../../../../core/services/dio_helper.dart';
import '../../../../../core/services/endpoints.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../../../../core/utils/error_handler.dart';
import 'package:systego/features/admin/country/model/country_model.dart';

/// Interface for country data operations
abstract class CountryRepositoryInterface {
  Future<List<CountryModel>> getCountries();
  Future<void> createCountry({
    required String name,
    required String arName,
  });
  Future<void> updateCountry({
    required String countryId,
    required String name,
    required String arName,
  });
  Future<void> deleteCountry(String countryId);
  Future<void> selectCountry(String countryId);
}

/// Hybrid repository that supports both Dio and Supabase for countries
class CountryRepository implements CountryRepositoryInterface {
  late final CountryRepositoryInterface _dataSource;

  CountryRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('locations')) {
      log('CountryRepository: Using Supabase');
      _dataSource = _CountrySupabaseDataSource();
    } else {
      log('CountryRepository: Using Dio (legacy)');
      _dataSource = _CountryDioDataSource();
    }
  }

  @override
  Future<List<CountryModel>> getCountries() => _dataSource.getCountries();

  @override
  Future<void> createCountry({
    required String name,
    required String arName,
  }) => _dataSource.createCountry(name: name, arName: arName);

  @override
  Future<void> updateCountry({
    required String countryId,
    required String name,
    required String arName,
  }) => _dataSource.updateCountry(countryId: countryId, name: name, arName: arName);

  @override
  Future<void> deleteCountry(String countryId) => _dataSource.deleteCountry(countryId);

  @override
  Future<void> selectCountry(String countryId) => _dataSource.selectCountry(countryId);
}

/// Supabase implementation for Country data source
class _CountrySupabaseDataSource implements CountryRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<List<CountryModel>> getCountries() async {
    try {
      log('CountrySupabase: Fetching all countries');
      final response = await _client.from('countries').select().order('name');
      return (response as List).map((json) => _mapSupabaseToCountryModel(json)).toList();
    } catch (e) {
      log('CountrySupabase: Error fetching countries - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> createCountry({
    required String name,
    required String arName,
  }) async {
    try {
      log('CountrySupabase: Creating country: $name');
      await _client.from('countries').insert({
        'name': name,
        'ar_name': arName,
      });
    } catch (e) {
      log('CountrySupabase: Error creating country - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> updateCountry({
    required String countryId,
    required String name,
    required String arName,
  }) async {
    try {
      log('CountrySupabase: Updating country: $countryId');
      await _client.from('countries').update({
        'name': name,
        'ar_name': arName,
      }).eq('id', countryId);
    } catch (e) {
      log('CountrySupabase: Error updating country - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteCountry(String countryId) async {
    try {
      log('CountrySupabase: Deleting country: $countryId');
      await _client.from('countries').delete().eq('id', countryId);
    } catch (e) {
      log('CountrySupabase: Error deleting country - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> selectCountry(String countryId) async {
    try {
      log('CountrySupabase: Setting default country: $countryId');
      // Legacy API has 'isDefault', we might want to handle it here too if needed
      // For now, assuming it's a simple update
    } catch (e) {
      log('CountrySupabase: Error selecting country - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  CountryModel _mapSupabaseToCountryModel(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      arName: json['ar_name'] ?? '',
      isDefault: json['is_default'] ?? false,
      version: json['version'] ?? 1,
    );
  }
}

/// Dio implementation for Country data source (legacy)
class _CountryDioDataSource implements CountryRepositoryInterface {
  @override
  Future<List<CountryModel>> getCountries() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.getCountries);
      if (response.statusCode == 200) {
        final model = CountryResponse.fromJson(response.data);
        return model.data.countries;
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> createCountry({
    required String name,
    required String arName,
  }) async {
    try {
      final response = await DioHelper.postData(
        url: EndPoint.createCountry,
        data: {'name': name, 'ar_name': arName},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> updateCountry({
    required String countryId,
    required String name,
    required String arName,
  }) async {
    try {
      final response = await DioHelper.putData(
        url: EndPoint.updateCountry(countryId),
        data: {'name': name, 'ar_name': arName},
      );
      if (response.statusCode != 200) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteCountry(String countryId) async {
    try {
      final response = await DioHelper.deleteData(url: EndPoint.deleteCountry(countryId));
      if (response.statusCode != 200) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> selectCountry(String countryId) async {
    try {
      final response = await DioHelper.putData(
        url: EndPoint.selectCountry(countryId),
        data: {'isDefault': true},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }
}
