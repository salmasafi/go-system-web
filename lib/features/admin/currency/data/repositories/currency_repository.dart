import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import 'package:GoSystem/features/admin/currency/model/currency_model.dart';

/// Interface for currency data operations
abstract class CurrencyRepositoryInterface {
  Future<List<CurrencyModel>> getCurrencies();
  Future<void> createCurrency({
    required String name,
    required double amount,
    required bool isDefault,
  });
  Future<void> updateCurrency({
    required String currencyId,
    required String name,
    required double amount,
    required bool isDefault,
  });
  Future<void> deleteCurrency(String currencyId);
}

/// Repository implementation using Supabase for currencies
class CurrencyRepository implements CurrencyRepositoryInterface {
  final _CurrencySupabaseDataSource _dataSource = _CurrencySupabaseDataSource();

  @override
  Future<List<CurrencyModel>> getCurrencies() => _dataSource.getCurrencies();

  @override
  Future<void> createCurrency({
    required String name,
    required double amount,
    required bool isDefault,
  }) => _dataSource.createCurrency(
        name: name,
        amount: amount,
        isDefault: isDefault,
      );

  @override
  Future<void> updateCurrency({
    required String currencyId,
    required String name,
    required double amount,
    required bool isDefault,
  }) => _dataSource.updateCurrency(
        currencyId: currencyId,
        name: name,
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

  String _generateCode(String name) {
    final cleaned = name.trim().replaceAll(RegExp(r'[^a-zA-Z؀-ۿ ]'), '');
    final words = cleaned.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return 'CUR';
    final latin = words.map((w) {
      final ascii = w.replaceAll(RegExp(r'[^\x00-\x7F]'), '');
      return ascii.isNotEmpty ? ascii[0].toUpperCase() : '';
    }).where((c) => c.isNotEmpty).join();
    if (latin.length >= 3) return latin.substring(0, 3).toUpperCase();
    return '${name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase().padRight(3, 'X').substring(0, 3)}_${DateTime.now().millisecondsSinceEpoch % 100}';
  }

  @override
  Future<void> createCurrency({
    required String name,
    required double amount,
    required bool isDefault,
  }) async {
    try {
      log('CurrencySupabase: Creating currency: $name');

      if (isDefault) {
        await _client.from('currencies').update({'is_default': false});
      }

      final baseCode = _generateCode(name);
      var code = baseCode;
      var attempt = 0;
      while (attempt < 10) {
        try {
          await _client.from('currencies').insert({
            'name': name,
            'code': code,
            'is_default': isDefault,
          });
          return;
        } catch (e) {
          attempt++;
          code = '$baseCode$attempt';
        }
      }
      throw Exception('Failed to generate unique currency code');
    } catch (e) {
      log('CurrencySupabase: Error creating currency - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> updateCurrency({
    required String currencyId,
    required String name,
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
      amount: 0.0,
      isDefault: json['is_default'] ?? false,
      version: 1,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'].toString()) : DateTime.now(),
    );
  }
}
