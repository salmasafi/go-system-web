import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import 'package:GoSystem/features/admin/country/model/country_model.dart';

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

/// Repository implementation using Supabase for countries
class CountryRepository implements CountryRepositoryInterface {
  final _CountrySupabaseDataSource _dataSource = _CountrySupabaseDataSource();

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
