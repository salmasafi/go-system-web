import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/storage_service.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../model/get_brands_model.dart';
import '../../model/get_brand_by_id_model.dart';

/// Interface for brand data operations
abstract class BrandRepositoryInterface {
  Future<List<Brands>> getAllBrands();
  Future<Brands?> getBrandById(String id);
  Future<Brands> createBrand({
    required String name,
    required String arName,
    File? logoFile,
  });
  Future<Brands> updateBrand({
    required String id,
    required String name,
    required String arName,
    File? logoFile,
  });
  Future<void> deleteBrand(String id);
}

/// Hybrid repository that supports both Dio and Supabase for brands
/// Brand repository using Supabase as the primary data source.
class BrandRepository implements BrandRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;
  final StorageService _storage = StorageService(SupabaseClientWrapper.instance);

  @override
  Future<List<Brands>> getAllBrands() async {
    try {
      log('BrandRepository: Fetching all brands');

      final response = await _client
          .from('brands')
          .select('*')
          .order('name');

      final brands = (response as List)
          .map((json) => _mapSupabaseToBrand(json))
          .toList();

      log('BrandRepository: Fetched ${brands.length} brands');
      return brands;
    } catch (e) {
      log('BrandRepository: Error fetching brands - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<Brands?> getBrandById(String id) async {
    try {
      log('BrandRepository: Fetching brand by id: $id');

      final response = await _client
          .from('brands')
          .select('*')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return _mapSupabaseToBrand(response);
    } catch (e) {
      log('BrandRepository: Error fetching brand - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<Brands> createBrand({
    required String name,
    required String arName,
    File? logoFile,
  }) async {
    try {
      log('BrandRepository: Creating brand: $name');

      // Upload logo if provided
      String? logoUrl;
      if (logoFile != null) {
        logoUrl = await _storage.uploadImage(
          file: logoFile,
          folder: 'brands',
          fileName: '${name.replaceAll(' ', '_')}.jpg',
          maxWidth: 800,
        );
      }

      final response = await _client
          .from('brands')
          .insert({
            'name': name,
            'ar_name': arName,
            'logo': logoUrl,
          })
          .select()
          .single();

      log('BrandRepository: Created brand successfully');
      return _mapSupabaseToBrand(response);
    } catch (e) {
      log('BrandRepository: Error creating brand - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<Brands> updateBrand({
    required String id,
    required String name,
    required String arName,
    File? logoFile,
  }) async {
    try {
      log('BrandRepository: Updating brand: $id');

      // Get current brand to check for logo update
      final current = await getBrandById(id);

      // Upload new logo if provided
      String? logoUrl;
      if (logoFile != null) {
        // Delete old logo if exists
        if (current?.logo != null && current!.logo!.isNotEmpty) {
          try {
            final oldPath = current.logo!.split('/').last;
            await _storage.deleteImage('brands/$oldPath');
          } catch (e) {
            log('BrandRepository: Failed to delete old logo - $e');
          }
        }

        logoUrl = await _storage.uploadImage(
          file: logoFile,
          folder: 'brands',
          fileName: '${name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          maxWidth: 800,
        );
      }

      final updateData = {
        'name': name,
        'ar_name': arName,
        if (logoUrl != null) 'logo': logoUrl,
      };

      final response = await _client
          .from('brands')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      log('BrandRepository: Updated brand successfully');
      return _mapSupabaseToBrand(response);
    } catch (e) {
      log('BrandRepository: Error updating brand - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteBrand(String id) async {
    try {
      log('BrandRepository: Deleting brand: $id');

      // Get brand to delete logo if exists
      final brand = await getBrandById(id);
      if (brand?.logo != null && brand!.logo!.isNotEmpty) {
        try {
          final logoPath = brand.logo!.split('/').last;
          await _storage.deleteImage('brands/$logoPath');
        } catch (e) {
          log('BrandRepository: Failed to delete logo - $e');
        }
      }

      await _client.from('brands').delete().eq('id', id);

      log('BrandRepository: Deleted brand successfully');
    } catch (e) {
      log('BrandRepository: Error deleting brand - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  /// Map Supabase response to Brands model
  Brands _mapSupabaseToBrand(Map<String, dynamic> json) {
    return Brands(
      id: json['id'] as String?,
      name: json['name'] as String?,
      arName: json['ar_name'] as String?,
      logo: json['logo'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      v: json['version'] as int?,
    );
  }
}
