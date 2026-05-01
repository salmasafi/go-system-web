import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/migration/migration_service.dart';
import '../../../../../core/services/dio_helper.dart';
import '../../../../../core/services/endpoints.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../../../../core/utils/error_handler.dart';
import 'package:systego/features/admin/currency/model/currency_model.dart';

/// Interface for currency data operations
abstract class CurrencyRepositoryInterface {
  Future<List<CurrencyModel>> getCurrencies();
  Future<void> createCurrency({
    required String name,
    required String arName,
    required double amount,
    required bool isDefault,
  });
  Future<void> updateCurrency({
    required String currencyId,
    required String name,
    required String arName,
    required double amount,
    required bool isDefault,
  });
  Future<void> deleteCurrency(String currencyId);
}

/// Hybrid repository that supports both Dio and Supabase for currencies
class CurrencyRepository implements CurrencyRepositoryInterface {
  late final CurrencyRepositoryInterface _dataSource;

  CurrencyRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('financial')) {
      log('CurrencyRepository: Using Supabase');
      _dataSource = _CurrencySupabaseDataSource();
    } else {
      log('CurrencyRepository: Using Dio (legacy)');
      _dataSource = _CurrencyDioDataSource();
    }
  }

  @override
  Future<List<CurrencyModel>> getCurrencies() => _dataSource.getCurrencies();

  @override
  Future<void> createCurrency({
    required String name,
    required String arName,
    required double amount,
    required bool isDefault,
  }) => _dataSource.createCurrency(
        name: name,
        arName: arName,
        amount: amount,
        isDefault: isDefault,
      );

  @override
  Future<void> updateCurrency({
    required String currencyId,
    required String name,
    required String arName,
    required double amount,
    required bool isDefault,
  }) => _dataSource.updateCurrency(
        currencyId: currencyId,
        name: name,
        arName: arName,
        amount: amount,
        isDefault: isDefault,
      );

  @override
  Future<void> deleteCurrency(String currencyId) => _dataSource.deleteCurrency(currencyId);
}

/// Supabase implementation for Currency data source
class _CurrencySupabaseDataSource implements CurrencyRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<List<CurrencyModel>> getCurrencies() async {
    try {
      log('CurrencySupabase: Fetching all currencies');
      final response = await _client.from('currencies').select().order('name');
      return (response as List).map((json) => _mapSupabaseToCurrencyModel(json)).toList();
    } catch (e) {
      log('CurrencySupabase: Error fetching currencies - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> createCurrency({
    required String name,
    required String arName,
    required double amount,
    required bool isDefault,
  }) async {
    try {
      log('CurrencySupabase: Creating currency: $name');
      
      if (isDefault) {
        await _client.from('currencies').update({'is_default': false});
      }

      await _client.from('currencies').insert({
        'name': name,
        'ar_name': arName,
        'exchange_rate': amount,
        'is_default': isDefault,
      });
    } catch (e) {
      log('CurrencySupabase: Error creating currency - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> updateCurrency({
    required String currencyId,
    required String name,
    required String arName,
    required double amount,
    required bool isDefault,
  }) async {
    try {
      log('CurrencySupabase: Updating currency: $currencyId');
      
      if (isDefault) {
        await _client.from('currencies').update({'is_default': false});
      }

      await _client.from('currencies').update({
        'name': name,
        'ar_name': arName,
        'exchange_rate': amount,
        'is_default': isDefault,
      }).eq('id', currencyId);
    } catch (e) {
      log('CurrencySupabase: Error updating currency - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteCurrency(String currencyId) async {
    try {
      log('CurrencySupabase: Deleting currency: $currencyId');
      await _client.from('currencies').delete().eq('id', currencyId);
    } catch (e) {
      log('CurrencySupabase: Error deleting currency - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  CurrencyModel _mapSupabaseToCurrencyModel(Map<String, dynamic> json) {
    return CurrencyModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      arName: json['ar_name'] ?? '',
      amount: (json['exchange_rate'] ?? 0).toDouble(),
      isDefault: json['is_default'] ?? false,
      version: json['version'] ?? 1,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'].toString()) : DateTime.now(),
    );
  }
}

/// Dio implementation for Currency data source (legacy)
class _CurrencyDioDataSource implements CurrencyRepositoryInterface {
  @override
  Future<List<CurrencyModel>> getCurrencies() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.getCurrencies);
      if (response.statusCode == 200) {
        final model = CurrenciesResponse.fromJson(response.data);
        return model.data.currencies;
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> createCurrency({
    required String name,
    required String arName,
    required double amount,
    required bool isDefault,
  }) async {
    try {
      final response = await DioHelper.postData(
        url: EndPoint.createCurrency,
        data: {
          'name': name,
          'ar_name': arName,
          'amount': amount,
          'isdefault': isDefault,
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
  Future<void> updateCurrency({
    required String currencyId,
    required String name,
    required String arName,
    required double amount,
    required bool isDefault,
  }) async {
    try {
      final response = await DioHelper.putData(
        url: EndPoint.updateCurrency(currencyId),
        data: {
          'name': name,
          'ar_name': arName,
          'amount': amount,
          'isdefault': isDefault,
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
  Future<void> deleteCurrency(String currencyId) async {
    try {
      final response = await DioHelper.deleteData(url: EndPoint.deleteCurrency(currencyId));
      if (response.statusCode != 200) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }
}
