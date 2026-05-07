import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/migration/migration_service.dart';
import '../../../../../core/services/dio_helper.dart';
import '../../../../../core/services/endpoints.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/storage_service.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../models/product_model.dart';

/// Interface for product data operations
abstract class ProductRepositoryInterface {
  Future<List<Product>> getAllProducts();
  Future<Product?> getProductById(String id);
  Future<List<Product>> searchProductsByCode(String code);
  Future<List<Product>> getProductsByWarehouse(String warehouseId);
  Future<Product> createProduct(Product product, {List<File>? images});
  Future<Product> updateProduct(String id, Product product, {List<File>? images});
  Future<void> deleteProduct(String id);
  Future<String?> generateProductCode();
  Future<Map<String, dynamic>> getProductFilters();
}

/// Product repository using Supabase as the primary data source.
class ProductRepository implements ProductRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;
  final StorageService _storage = StorageService(SupabaseClientWrapper.instance);

  @override
  Future<Map<String, dynamic>> getProductFilters() async {
    try {
      log('ProductRepository: Fetching product filters');
      // For now returning empty lists as categories/brands/units are handled via their own repositories
      return {
        'success': true,
        'data': {
          'categories': [],
          'brands': [],
          'units': [],
          'taxes': [],
        }
      };
    } catch (e) {
      log('ProductRepository: Error fetching product filters - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<Product>> getAllProducts() async {
    try {
      log('ProductRepository: Fetching all products');

      final response = await _client
          .from('products')
          .select('''
            *,
            categories:product_categories(category:category_id(*)),
            brand:brand_id(*)
          ''')
          .order('created_at', ascending: false);

      final products = (response as List)
          .map((json) => _mapSupabaseToProduct(json))
          .toList();

      log('ProductRepository: Fetched ${products.length} products');
      return products;
    } catch (e) {
      log('ProductRepository: Error fetching products - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<Product?> getProductById(String id) async {
    try {
      log('ProductRepository: Fetching product by id: $id');

      final response = await _client
          .from('products')
          .select('''
            *,
            categories:product_categories(category:category_id(*)),
            brand:brand_id(*),
            warehouses:product_warehouses(warehouse:warehouse_id(*), quantity)
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return _mapSupabaseToProduct(response);
    } catch (e) {
      log('ProductRepository: Error fetching product - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<Product>> searchProductsByCode(String code) async {
    try {
      log('ProductRepository: Searching products by code: $code');

      final response = await _client
          .from('products')
          .select('''
            *,
            categories:product_categories(category:category_id(*)),
            brand:brand_id(*)
          ''')
          .or('code.ilike.%$code%,name.ilike.%$code%')
          .order('name');

      final products = (response as List)
          .map((json) => _mapSupabaseToProduct(json))
          .toList();

      log('ProductRepository: Found ${products.length} products');
      return products;
    } catch (e) {
      log('ProductRepository: Error searching products - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<Product>> getProductsByWarehouse(String warehouseId) async {
    try {
      log('ProductRepository: Fetching products for warehouse: $warehouseId');

      final response = await _client
          .from('product_warehouses')
          .select('''
            quantity,
            product:product_id(*, categories:product_categories(category:category_id(*)), brand:brand_id(*))
          ''')
          .eq('warehouse_id', warehouseId);

      final products = (response as List)
          .map((json) {
            final productData = json['product'] as Map<String, dynamic>;
            productData['quantity'] = json['quantity'];
            return _mapSupabaseToProduct(productData);
          })
          .toList();

      log('ProductRepository: Fetched ${products.length} products for warehouse');
      return products;
    } catch (e) {
      log('ProductRepository: Error fetching warehouse products - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<Product> createProduct(Product product, {List<File>? images}) async {
    try {
      log('ProductRepository: Creating product: ${product.name}');

      // Upload images if provided
      String? mainImageUrl;
      List<String> galleryUrls = [];
      
      if (images != null && images.isNotEmpty) {
        // First image is main image
        mainImageUrl = await _storage.uploadImage(
          file: images.first,
          folder: 'products',
          fileName: '${product.name.replaceAll(' ', '_')}_main.jpg',
          maxWidth: 1200,
        );

        // Remaining images go to gallery
        for (int i = 1; i < images.length; i++) {
          final url = await _storage.uploadImage(
            file: images[i],
            folder: 'products',
            fileName: '${product.name.replaceAll(' ', '_')}_gallery_$i.jpg',
            maxWidth: 1200,
          );
          galleryUrls.add(url);
        }
      }

      // Insert product
      final productResponse = await _client
          .from('products')
          .insert({
            'name': product.name,
            'code': await generateProductCode(),
            'description': product.description,
            'image': mainImageUrl ?? product.image,
            'brand_id': product.brandId.id.isNotEmpty ? product.brandId.id : null,
            'sale_unit': product.saleUnit,
            'purchase_unit': product.purchaseUnit,
            'price': product.price,
            'quantity': product.quantity,
            'exp_ability': product.expAbility,
            'date_of_expiry': product.dateOfExpiry?.toIso8601String(),
            'minimum_quantity_sale': product.minimumQuantitySale,
            'low_stock': product.lowStock,
            'whole_price': product.wholePrice,
            'start_quantaty': product.startQuantaty,
            'taxes_id': product.taxesId,
            'product_has_imei': product.productHasImei,
            'show_quantity': product.showQuantity,
            'maximum_to_show': product.maximumToShow,
            'is_featured': product.isFeatured,
            'gallery_product': galleryUrls.isNotEmpty ? galleryUrls : product.galleryProduct,
          })
          .select()
          .single();

      final productId = productResponse['id'] as String;

      // Insert product categories
      for (final category in product.categoryId) {
        await _client.from('product_categories').insert({
          'product_id': productId,
          'category_id': category.id,
        });
      }

      log('ProductRepository: Created product successfully');
      return _mapSupabaseToProduct(productResponse);
    } catch (e) {
      log('ProductRepository: Error creating product - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<Product> updateProduct(String id, Product product, {List<File>? images}) async {
    try {
      log('ProductRepository: Updating product: $id');

      // Get current product to handle image updates
      final current = await getProductById(id);

      // Upload new images if provided
      String? mainImageUrl;
      List<String> galleryUrls = [];
      
      if (images != null && images.isNotEmpty) {
        // Delete old images if exists
        if (current?.image != null && current!.image.isNotEmpty) {
          try {
            final oldPath = current.image.split('/').last;
            await _storage.deleteImage('products/$oldPath');
          } catch (e) {
            log('ProductRepository: Failed to delete old main image - $e');
          }
        }

        // Upload new main image
        mainImageUrl = await _storage.uploadImage(
          file: images.first,
          folder: 'products',
          fileName: '${product.name.replaceAll(' ', '_')}_main_${DateTime.now().millisecondsSinceEpoch}.jpg',
          maxWidth: 1200,
        );

        // Upload gallery images
        for (int i = 1; i < images.length; i++) {
          final url = await _storage.uploadImage(
            file: images[i],
            folder: 'products',
            fileName: '${product.name.replaceAll(' ', '_')}_gallery_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
            maxWidth: 1200,
          );
          galleryUrls.add(url);
        }
      }

      // Update product
      final updateData = {
        'name': product.name,
        'description': product.description,
        'brand_id': product.brandId.id.isNotEmpty ? product.brandId.id : null,
        'sale_unit': product.saleUnit,
        'purchase_unit': product.purchaseUnit,
        'price': product.price,
        'quantity': product.quantity,
        'exp_ability': product.expAbility,
        'date_of_expiry': product.dateOfExpiry?.toIso8601String(),
        'minimum_quantity_sale': product.minimumQuantitySale,
        'low_stock': product.lowStock,
        'whole_price': product.wholePrice,
        'start_quantaty': product.startQuantaty,
        'taxes_id': product.taxesId,
        'product_has_imei': product.productHasImei,
        'show_quantity': product.showQuantity,
        'maximum_to_show': product.maximumToShow,
        'is_featured': product.isFeatured,
        if (mainImageUrl != null) 'image': mainImageUrl,
        if (galleryUrls.isNotEmpty) 'gallery_product': galleryUrls,
      };

      final response = await _client
          .from('products')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      log('ProductRepository: Updated product successfully');
      return _mapSupabaseToProduct(response);
    } catch (e) {
      log('ProductRepository: Error updating product - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      log('ProductRepository: Deleting product: $id');

      // Get product to delete images
      final product = await getProductById(id);
      if (product?.image != null && product!.image.isNotEmpty) {
        try {
          final imagePath = product.image.split('/').last;
          await _storage.deleteImage('products/$imagePath');
        } catch (e) {
          log('ProductRepository: Failed to delete image - $e');
        }
      }

      // Delete gallery images
      if (product?.galleryProduct != null) {
        for (final imageUrl in product!.galleryProduct) {
          try {
            final imagePath = imageUrl.split('/').last;
            await _storage.deleteImage('products/$imagePath');
          } catch (e) {
            log('ProductRepository: Failed to delete gallery image - $e');
          }
        }
      }

      await _client.from('products').delete().eq('id', id);

      log('ProductRepository: Deleted product successfully');
    } catch (e) {
      log('ProductRepository: Error deleting product - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<String?> generateProductCode() async {
    try {
      // Generate a unique product code
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = (timestamp % 10000).toString().padLeft(4, '0');
      return 'PRD-$random';
    } catch (e) {
      log('ProductRepository: Error generating code - $e');
      return null;
    }
  }

  /// Map Supabase response to Product model
  Product _mapSupabaseToProduct(Map<String, dynamic> json) {
    // Parse categories from nested structure
    final categoriesData = json['categories'] as List<dynamic>? ?? [];
    final categories = categoriesData.map((c) {
      final cat = c['category'] as Map<String, dynamic>?;
      if (cat == null) return null;
      return Category(
        id: cat['id'] ?? '',
        name: cat['name'] ?? '',
        image: cat['image'] ?? '',
        productQuantity: cat['product_quantity'] ?? 0,
        parentId: cat['parent_id'],
        createdAt: DateTime.tryParse(cat['created_at'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(cat['updated_at'] ?? '') ?? DateTime.now(),
      );
    }).whereType<Category>().toList();

    // Parse brand
    final brandData = json['brand'] as Map<String, dynamic>?;
    final brand = brandData != null
        ? Brand(
            id: brandData['id'] ?? '',
            name: brandData['name'] ?? '',
            logo: brandData['logo'] ?? '',
            createdAt: DateTime.tryParse(brandData['created_at'] ?? '') ?? DateTime.now(),
            updatedAt: DateTime.tryParse(brandData['updated_at'] ?? '') ?? DateTime.now(),
          )
        : Brand.empty();

    return Product(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      categoryId: categories,
      brandId: brand,
      saleUnit: json['sale_unit'] ?? '',
      purchaseUnit: json['purchase_unit'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 0,
      description: json['description'] ?? '',
      expAbility: json['exp_ability'] ?? false,
      dateOfExpiry: json['date_of_expiery'] != null
          ? DateTime.tryParse(json['date_of_expiery'])
          : null,
      minimumQuantitySale: json['minimum_quantity_sale'] ?? 0,
      lowStock: json['low_stock'] ?? 0,
      wholePrice: (json['whole_price'] as num?)?.toDouble() ?? 0.0,
      startQuantaty: json['start_quantaty'] ?? 0,
      taxesId: json['taxes_id'],
      productHasImei: json['product_has_imei'] ?? false,
      showQuantity: json['show_quantity'] ?? false,
      maximumToShow: json['maximum_to_show'] ?? 0,
      galleryProduct: (json['gallery_product'] as List<dynamic>?)?.cast<String>() ?? [],
      isFeatured: json['is_featured'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  // Helper methods for enabling/disabling Supabase are no longer needed
  // as the repository is now Supabase-only.
}
