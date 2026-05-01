import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/migration/migration_service.dart';
import '../../../../../core/services/cache_helper.dart';
import '../../../../../core/services/dio_helper.dart';
import '../../../../../core/services/endpoints.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/storage_service.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../../../../core/utils/error_handler.dart';
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
class BrandRepository implements BrandRepositoryInterface {
  late final BrandRepositoryInterface _dataSource;

  BrandRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('brands')) {
      log('BrandRepository: Using Supabase');
      _dataSource = _BrandSupabaseDataSource();
    } else {
      log('BrandRepository: Using Dio (legacy)');
      _dataSource = _BrandDioDataSource();
    }
  }

  @override
  Future<List<Brands>> getAllBrands() => _dataSource.getAllBrands();

  @override
  Future<Brands?> getBrandById(String id) => _dataSource.getBrandById(id);

  @override
  Future<Brands> createBrand({
    required String name,
    required String arName,
    File? logoFile,
  }) => _dataSource.createBrand(
    name: name,
    arName: arName,
    logoFile: logoFile,
  );

  @override
  Future<Brands> updateBrand({
    required String id,
    required String name,
    required String arName,
    File? logoFile,
  }) => _dataSource.updateBrand(
    id: id,
    name: name,
    arName: arName,
    logoFile: logoFile,
  );

  @override
  Future<void> deleteBrand(String id) => _dataSource.deleteBrand(id);

  void enableSupabase() {
    MigrationService.enableSupabase('brands');
    _initializeDataSource();
  }

  void enableDio() {
    MigrationService.enableDio('brands');
    _initializeDataSource();
  }
}

/// Supabase implementation for Brand data source
class _BrandSupabaseDataSource implements BrandRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;
  final StorageService _storage = StorageService(SupabaseClientWrapper.instance);

  @override
  Future<List<Brands>> getAllBrands() async {
    try {
      log('BrandSupabase: Fetching all brands');

      final response = await _client
          .from('brands')
          .select('*')
          .order('name');

      final brands = (response as List)
          .map((json) => _mapSupabaseToBrand(json))
          .toList();

      log('BrandSupabase: Fetched ${brands.length} brands');
      return brands;
    } catch (e) {
      log('BrandSupabase: Error fetching brands - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<Brands?> getBrandById(String id) async {
    try {
      log('BrandSupabase: Fetching brand by id: $id');

      final response = await _client
          .from('brands')
          .select('*')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return _mapSupabaseToBrand(response);
    } catch (e) {
      log('BrandSupabase: Error fetching brand - $e');
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
      log('BrandSupabase: Creating brand: $name');

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

      log('BrandSupabase: Created brand successfully');
      return _mapSupabaseToBrand(response);
    } catch (e) {
      log('BrandSupabase: Error creating brand - $e');
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
      log('BrandSupabase: Updating brand: $id');

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
            log('BrandSupabase: Failed to delete old logo - $e');
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

      log('BrandSupabase: Updated brand successfully');
      return _mapSupabaseToBrand(response);
    } catch (e) {
      log('BrandSupabase: Error updating brand - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteBrand(String id) async {
    try {
      log('BrandSupabase: Deleting brand: $id');

      // Get brand to delete logo if exists
      final brand = await getBrandById(id);
      if (brand?.logo != null && brand!.logo!.isNotEmpty) {
        try {
          final logoPath = brand.logo!.split('/').last;
          await _storage.deleteImage('brands/$logoPath');
        } catch (e) {
          log('BrandSupabase: Failed to delete logo - $e');
        }
      }

      await _client.from('brands').delete().eq('id', id);

      log('BrandSupabase: Deleted brand successfully');
    } catch (e) {
      log('BrandSupabase: Error deleting brand - $e');
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

/// Dio implementation for Brand data source (legacy)
class _BrandDioDataSource implements BrandRepositoryInterface {
  @override
  Future<List<Brands>> getAllBrands() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.getBrands);

      if (response.statusCode == 200) {
        final model = GeBrandsModel.fromJson(response.data);
        if (model.success == true && model.data?.brands != null) {
          return model.data!.brands!;
        }
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<Brands?> getBrandById(String id) async {
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getBrandById(id),
      );

      if (response.statusCode == 200) {
        final model = GetBrandByIdModel.fromJson(response.data);
        if (model.success == true && model.data?.brand != null) {
          final brandById = model.data!.brand!;
          // Convert BrandById to Brands
          return Brands(
            id: brandById.id,
            name: brandById.name,
            arName: brandById.arName,
            logo: brandById.logo,
            createdAt: brandById.createdAt,
            updatedAt: brandById.updatedAt,
            v: brandById.v,
          );
        }
      }
      return null;
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<Brands> createBrand({
    required String name,
    required String arName,
    File? logoFile,
  }) async {
    try {
      // Convert logo to base64 if provided
      String? base64Logo;
      if (logoFile != null) {
        final bytes = await logoFile.readAsBytes();
        base64Logo = base64Encode(bytes);
      }

      final response = await DioHelper.postData(
        url: EndPoint.createBrand,
        data: {
          'name': name,
          'ar_name': arName,
          if (base64Logo != null) 'logo': base64Logo,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final brand = Brands.fromJson(response.data['data']['brand']);
        return brand;
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
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
      // Convert logo to base64 if provided
      String? base64Logo;
      if (logoFile != null) {
        final bytes = await logoFile.readAsBytes();
        base64Logo = base64Encode(bytes);
      }

      final response = await DioHelper.putData(
        url: EndPoint.updateBrand(id),
        data: {
          'name': name,
          'ar_name': arName,
          if (base64Logo != null) 'logo': base64Logo,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final brand = Brands.fromJson(response.data['data']['brand']);
        return brand;
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteBrand(String id) async {
    try {
      final response = await DioHelper.deleteData(
        url: EndPoint.deleteBrand(id),
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }
}
