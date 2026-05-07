import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../model/variation_model.dart';

abstract class VariationRepositoryInterface {
  Future<List<VariationModel>> getAllVariations();
  Future<VariationModel> createVariation(VariationModel variation);
  Future<VariationModel> updateVariation(VariationModel variation);
  Future<bool> deleteVariation(String id);
}

class VariationRepository implements VariationRepositoryInterface {
  final _VariationSupabaseDataSource _dataSource = _VariationSupabaseDataSource();

  @override
  Future<List<VariationModel>> getAllVariations() => _dataSource.getAllVariations();

  @override
  Future<VariationModel> createVariation(VariationModel variation) => _dataSource.createVariation(variation);

  @override
  Future<VariationModel> updateVariation(VariationModel variation) => _dataSource.updateVariation(variation);

  @override
  Future<bool> deleteVariation(String id) => _dataSource.deleteVariation(id);
}

class _VariationSupabaseDataSource implements VariationRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<List<VariationModel>> getAllVariations() async {
    try {
      log('VariationSupabase: Fetching all variations');
      final response = await _client.from('variations').select('*, options:variation_options(*)').order('name');
      return (response as List).map((json) => _mapSupabaseToVariationModel(json)).toList();
    } catch (e) {
      log('VariationSupabase: Error fetching variations - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<VariationModel> createVariation(VariationModel variation) async {
    try {
      log('VariationSupabase: Creating variation');
      // 1. Create the variation
      final varData = {
        'name': variation.name,
      };
      final varResponse = await _client.from('variations').insert(varData).select().single();
      final varId = varResponse['id'];

      // 2. Create options if any
      if (variation.options.isNotEmpty) {
        final optionsData = variation.options.map((opt) => {
          'variation_id': varId,
          'name': opt.name,
          'status': opt.status,
        }).toList();
        await _client.from('variation_options').insert(optionsData);
      }

      // 3. Fetch full variation with options
      final fullResponse = await _client.from('variations').select('*, options:variation_options(*)').eq('id', varId).single();
      return _mapSupabaseToVariationModel(fullResponse);
    } catch (e) {
      log('VariationSupabase: Error creating variation - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<VariationModel> updateVariation(VariationModel variation) async {
    try {
      log('VariationSupabase: Updating variation');
      // 1. Update variation name
      await _client.from('variations').update({
        'name': variation.name,
      }).eq('id', variation.id);

      // 2. Handle options (this is simplified, ideally you'd diff them)
      
      final fullResponse = await _client.from('variations').select('*, options:variation_options(*)').eq('id', variation.id).single();
      return _mapSupabaseToVariationModel(fullResponse);
    } catch (e) {
      log('VariationSupabase: Error updating variation - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> deleteVariation(String id) async {
    try {
      log('VariationSupabase: Deleting variation');
      await _client.from('variations').delete().eq('id', id);
      return true;
    } catch (e) {
      log('VariationSupabase: Error deleting variation - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  VariationModel _mapSupabaseToVariationModel(Map<String, dynamic> json) {
    return VariationModel(
      id: json['id'],
      name: json['name'],
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at'] ?? DateTime.now().toIso8601String(),
      version: 0,
      options: (json['options'] as List? ?? []).map((opt) => VariationOption(
        id: opt['id'],
        variationId: opt['variation_id'],
        name: opt['name'],
        status: opt['status'],
        createdAt: opt['created_at'] ?? DateTime.now().toIso8601String(),
        updatedAt: opt['updated_at'] ?? DateTime.now().toIso8601String(),
        version: 0,
      )).toList(),
    );
  }
}
