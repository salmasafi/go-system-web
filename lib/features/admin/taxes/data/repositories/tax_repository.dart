import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../model/taxes_model.dart';

abstract class TaxRepositoryInterface {
  Future<List<TaxModel>> getAllTaxes();
  Future<TaxModel> createTax(TaxModel tax);
  Future<TaxModel> updateTax(TaxModel tax);
  Future<bool> deleteTax(String id);
}

class TaxRepository implements TaxRepositoryInterface {
  final _TaxSupabaseDataSource _dataSource = _TaxSupabaseDataSource();

  @override
  Future<List<TaxModel>> getAllTaxes() => _dataSource.getAllTaxes();

  @override
  Future<TaxModel> createTax(TaxModel tax) => _dataSource.createTax(tax);

  @override
  Future<TaxModel> updateTax(TaxModel tax) => _dataSource.updateTax(tax);

  @override
  Future<bool> deleteTax(String id) => _dataSource.deleteTax(id);
}

class _TaxSupabaseDataSource implements TaxRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<List<TaxModel>> getAllTaxes() async {
    try {
      log('TaxSupabase: Fetching all taxes');
      final response = await _client.from('taxes').select().order('name');
      return (response as List).map((json) => TaxModel.fromJson(json)).toList();
    } catch (e) {
      log('TaxSupabase: Error fetching taxes - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<TaxModel> createTax(TaxModel tax) async {
    try {
      log('TaxSupabase: Creating tax');
      final data = {
        'name': tax.name,
        'amount': tax.amount,
        'type': tax.type,
        'status': tax.status,
      };
      final response = await _client.from('taxes').insert(data).select().single();
      return TaxModel.fromJson(response);
    } catch (e) {
      log('TaxSupabase: Error creating tax - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<TaxModel> updateTax(TaxModel tax) async {
    try {
      log('TaxSupabase: Updating tax');
      final data = {
        'name': tax.name,
        'amount': tax.amount,
        'type': tax.type,
        'status': tax.status,
      };
      final response = await _client.from('taxes').update(data).eq('id', tax.id).select().single();
      return TaxModel.fromJson(response);
    } catch (e) {
      log('TaxSupabase: Error updating tax - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> deleteTax(String id) async {
    try {
      log('TaxSupabase: Deleting tax');
      await _client.from('taxes').delete().eq('id', id);
      return true;
    } catch (e) {
      log('TaxSupabase: Error deleting tax - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }
}
