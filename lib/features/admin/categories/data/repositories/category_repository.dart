import 'dart:developer';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/storage_service.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../model/get_categories_model.dart';

/// Interface for category data operations
abstract class CategoryRepositoryInterface {
  Future<List<CategoryItem>> getAllCategories();
  Future<CategoryItem?> getCategoryById(String id);
  Future<CategoryItem> createCategory({
    required String name,
    required String arName,
    String? parentId,
    File? imageFile,
  });
  Future<CategoryItem> updateCategory({
    required String id,
    required String name,
    required String arName,
    String? parentId,
    File? imageFile,
  });
  Future<void> deleteCategory(String id);
}

/// Repository implementation using Supabase for categories
class CategoryRepository implements CategoryRepositoryInterface {
  final _CategorySupabaseDataSource _dataSource = _CategorySupabaseDataSource();

  @override
  Future<List<CategoryItem>> getAllCategories() => _dataSource.getAllCategories();

  @override
  Future<CategoryItem?> getCategoryById(String id) => _dataSource.getCategoryById(id);

  @override
  Future<CategoryItem> createCategory({
    required String name,
    required String arName,
    String? parentId,
    File? imageFile,
  }) => _dataSource.createCategory(
    name: name,
    arName: arName,
    parentId: parentId,
    imageFile: imageFile,
  );

  @override
  Future<CategoryItem> updateCategory({
    required String id,
    required String name,
    required String arName,
    String? parentId,
    File? imageFile,
  }) => _dataSource.updateCategory(
    id: id,
    name: name,
    arName: arName,
    parentId: parentId,
    imageFile: imageFile,
  );

  @override
  Future<void> deleteCategory(String id) => _dataSource.deleteCategory(id);
}

/// Supabase implementation for Category data source
class _CategorySupabaseDataSource implements CategoryRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;
  final StorageService _storage = StorageService(SupabaseClientWrapper.instance);

  @override
  Future<List<CategoryItem>> getAllCategories() async {
    try {
      log('CategorySupabase: Fetching all categories');

      final response = await _client
          .from('categories')
          .select('*, parent:parent_id(id, name, ar_name), product_categories(count)')
          .order('name');

      final categories = (response as List)
          .map((json) => _mapSupabaseToCategoryItem(json))
          .toList();

      log('CategorySupabase: Fetched ${categories.length} categories');
      return categories;
    } catch (e) {
      log('CategorySupabase: Error fetching categories - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<CategoryItem?> getCategoryById(String id) async {
    try {
      log('CategorySupabase: Fetching category by id: $id');

      final response = await _client
          .from('categories')
          .select('*, parent:parent_id(id, name, ar_name), product_categories(count)')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return _mapSupabaseToCategoryItem(response);
    } catch (e) {
      log('CategorySupabase: Error fetching category - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<CategoryItem> createCategory({
    required String name,
    required String arName,
    String? parentId,
    File? imageFile,
  }) async {
    try {
      log('CategorySupabase: Creating category: $name');

      // Upload image if provided
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _storage.uploadImage(
          file: imageFile,
          folder: 'categories',
          fileName: '${name.replaceAll(' ', '_')}.jpg',
          maxWidth: 800,
        );
      }

      final response = await _client
          .from('categories')
          .insert({
            'name': name,
            'ar_name': arName,
            'parent_id': parentId,
            'image': imageUrl,
          })
          .select('*, parent:parent_id(id, name, ar_name)')
          .single();

      log('CategorySupabase: Created category successfully');
      return _mapSupabaseToCategoryItem(response);
    } catch (e) {
      log('CategorySupabase: Error creating category - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<CategoryItem> updateCategory({
    required String id,
    required String name,
    required String arName,
    String? parentId,
    File? imageFile,
  }) async {
    try {
      log('CategorySupabase: Updating category: $id');

      // Get current category to check for image update
      final current = await getCategoryById(id);

      // Upload new image if provided
      String? imageUrl;
      if (imageFile != null) {
        // Delete old image if exists
        if (current?.image != null && current!.image.isNotEmpty) {
          try {
            final oldPath = current.image.split('/').last;
            await _storage.deleteImage('categories/$oldPath');
          } catch (e) {
            log('CategorySupabase: Failed to delete old image - $e');
          }
        }

        imageUrl = await _storage.uploadImage(
          file: imageFile,
          folder: 'categories',
          fileName: '${name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          maxWidth: 800,
        );
      }

      final updateData = {
        'name': name,
        'ar_name': arName,
        'parent_id': parentId,
        if (imageUrl != null) 'image': imageUrl,
      };

      final response = await _client
          .from('categories')
          .update(updateData)
          .eq('id', id)
          .select('*, parent:parent_id(id, name, ar_name)')
          .single();

      log('CategorySupabase: Updated category successfully');
      return _mapSupabaseToCategoryItem(response);
    } catch (e) {
      log('CategorySupabase: Error updating category - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      log('CategorySupabase: Deleting category: $id');

      // Get category to delete image if exists
      final category = await getCategoryById(id);
      if (category?.image != null && category!.image.isNotEmpty) {
        try {
          final imagePath = category.image.split('/').last;
          await _storage.deleteImage('categories/$imagePath');
        } catch (e) {
          log('CategorySupabase: Failed to delete image - $e');
        }
      }

      await _client.from('categories').delete().eq('id', id);

      log('CategorySupabase: Deleted category successfully');
    } catch (e) {
      log('CategorySupabase: Error deleting category - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  /// Map Supabase response to CategoryItem model
  CategoryItem _mapSupabaseToCategoryItem(Map<String, dynamic> json) {
    final parent = json['parent'] as Map<String, dynamic>?;

    return CategoryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      arName: json['ar_name'] ?? '',
      image: json['image'] ?? '',
      productQuantity: ((json['product_categories'] as List?)?.isNotEmpty == true
          ? (json['product_categories'][0]['count'] as num?)?.toInt()
          : null) ?? json['product_quantity'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      version: json['version'] ?? 1,
      parentId: parent != null
          ? ParentCategory(
              id: parent['id'] as String,
              name: parent['name'] as String,
              arName: parent['ar_name'] ?? '',
            )
          : null,
    );
  }
}
