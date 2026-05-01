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
}

/// Hybrid repository that supports both Dio and Supabase for products
class ProductRepository implements ProductRepositoryInterface {
  late final ProductRepositoryInterface _dataSource;

  ProductRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('products')) {
      log('ProductRepository: Using Supabase');
      _dataSource = _ProductSupabaseDataSource();
    } else {
      log('ProductRepository: Using Dio (legacy)');
      _dataSource = _ProductDioDataSource();
    }
  }

  @override
  Future<List<Product>> getAllProducts() => _dataSource.getAllProducts();

  @override
  Future<Product?> getProductById(String id) => _dataSource.getProductById(id);

  @override
  Future<List<Product>> searchProductsByCode(String code) => _dataSource.searchProductsByCode(code);

  @override
  Future<List<Product>> getProductsByWarehouse(String warehouseId) => _dataSource.getProductsByWarehouse(warehouseId);

  @override
  Future<Product> createProduct(Product product, {List<File>? images}) => _dataSource.createProduct(product, images: images);

  @override
  Future<Product> updateProduct(String id, Product product, {List<File>? images}) => _dataSource.updateProduct(id, product, images: images);

  @override
  Future<void> deleteProduct(String id) => _dataSource.deleteProduct(id);

  @override
  Future<String?> generateProductCode() => _dataSource.generateProductCode();

  @override
  Future<Map<String, dynamic>> getProductFilters() => _dataSource.getProductFilters();

  void enableSupabase() {
    MigrationService.enableSupabase('products');
    _initializeDataSource();
  }

  void enableDio() {
    MigrationService.enableDio('products');
    _initializeDataSource();
  }
}

/// Supabase implementation for Product data source
class _ProductSupabaseDataSource implements ProductRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;
  final StorageService _storage = StorageService(SupabaseClientWrapper.instance);

  @override
  Future<Map<String, dynamic>> getProductFilters() async {
    try {
      log('ProductSupabase: Fetching product filters');
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
      log('ProductSupabase: Error fetching product filters - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<Product>> getAllProducts() async {
    try {
      log('ProductSupabase: Fetching all products');

      final response = await _client
          .from('products')
          .select('''
            *,
            categories:product_categories(category:category_id(*)),
            brand:brand_id(*),
            prices:product_prices(*, variations:product_price_variations(variation:variation_id(*), option:option_id(*)))
          ''')
          .order('created_at', ascending: false);

      final products = (response as List)
          .map((json) => _mapSupabaseToProduct(json))
          .toList();

      log('ProductSupabase: Fetched ${products.length} products');
      return products;
    } catch (e) {
      log('ProductSupabase: Error fetching products - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<Product?> getProductById(String id) async {
    try {
      log('ProductSupabase: Fetching product by id: $id');

      final response = await _client
          .from('products')
          .select('''
            *,
            categories:product_categories(category:category_id(*)),
            brand:brand_id(*),
            prices:product_prices(*, variations:product_price_variations(variation:variation_id(*), option:option_id(*))),
            warehouses:product_warehouses(warehouse:warehouse_id(*), quantity)
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return _mapSupabaseToProduct(response);
    } catch (e) {
      log('ProductSupabase: Error fetching product - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<Product>> searchProductsByCode(String code) async {
    try {
      log('ProductSupabase: Searching products by code: $code');

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

      log('ProductSupabase: Found ${products.length} products');
      return products;
    } catch (e) {
      log('ProductSupabase: Error searching products - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<Product>> getProductsByWarehouse(String warehouseId) async {
    try {
      log('ProductSupabase: Fetching products for warehouse: $warehouseId');

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

      log('ProductSupabase: Fetched ${products.length} products for warehouse');
      return products;
    } catch (e) {
      log('ProductSupabase: Error fetching warehouse products - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<Product> createProduct(Product product, {List<File>? images}) async {
    try {
      log('ProductSupabase: Creating product: ${product.name}');

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
            'ar_name': product.arName,
            'code': await generateProductCode(),
            'description': product.description,
            'ar_description': product.arDescription,
            'image': mainImageUrl ?? product.image,
            'brand_id': product.brandId.id.isNotEmpty ? product.brandId.id : null,
            'unit': product.unit,
            'price': product.price,
            'quantity': product.quantity,
            'exp_ability': product.expAbility,
            'date_of_expiery': product.dateOfExpiery?.toIso8601String(),
            'minimum_quantity_sale': product.minimumQuantitySale,
            'low_stock': product.lowStock,
            'whole_price': product.wholePrice,
            'start_quantaty': product.startQuantaty,
            'taxes_id': product.taxesId,
            'product_has_imei': product.productHasImei,
            'different_price': product.differentPrice,
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

      // Insert product prices with variations
      for (final price in product.prices) {
        final priceResponse = await _client
            .from('product_prices')
            .insert({
              'product_id': productId,
              'price': price.price,
              'code': price.code,
              'gallery': price.gallery,
              'quantity': price.quantity,
            })
            .select()
            .single();

        final priceId = priceResponse['id'] as String;

        // Insert price variations
        for (final variation in price.variations) {
          for (final option in variation.options) {
            await _client.from('product_price_variations').insert({
              'product_price_id': priceId,
              'variation_id': option.variationId,
              'option_id': option.id,
            });
          }
        }
      }

      log('ProductSupabase: Created product successfully');
      return _mapSupabaseToProduct(productResponse);
    } catch (e) {
      log('ProductSupabase: Error creating product - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<Product> updateProduct(String id, Product product, {List<File>? images}) async {
    try {
      log('ProductSupabase: Updating product: $id');

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
            log('ProductSupabase: Failed to delete old main image - $e');
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
        'ar_name': product.arName,
        'description': product.description,
        'ar_description': product.arDescription,
        'brand_id': product.brandId.id.isNotEmpty ? product.brandId.id : null,
        'unit': product.unit,
        'price': product.price,
        'quantity': product.quantity,
        'exp_ability': product.expAbility,
        'date_of_expiery': product.dateOfExpiery?.toIso8601String(),
        'minimum_quantity_sale': product.minimumQuantitySale,
        'low_stock': product.lowStock,
        'whole_price': product.wholePrice,
        'start_quantaty': product.startQuantaty,
        'taxes_id': product.taxesId,
        'product_has_imei': product.productHasImei,
        'different_price': product.differentPrice,
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

      log('ProductSupabase: Updated product successfully');
      return _mapSupabaseToProduct(response);
    } catch (e) {
      log('ProductSupabase: Error updating product - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      log('ProductSupabase: Deleting product: $id');

      // Get product to delete images
      final product = await getProductById(id);
      if (product?.image != null && product!.image.isNotEmpty) {
        try {
          final imagePath = product.image.split('/').last;
          await _storage.deleteImage('products/$imagePath');
        } catch (e) {
          log('ProductSupabase: Failed to delete image - $e');
        }
      }

      // Delete gallery images
      if (product?.galleryProduct != null) {
        for (final imageUrl in product!.galleryProduct) {
          try {
            final imagePath = imageUrl.split('/').last;
            await _storage.deleteImage('products/$imagePath');
          } catch (e) {
            log('ProductSupabase: Failed to delete gallery image - $e');
          }
        }
      }

      await _client.from('products').delete().eq('id', id);

      log('ProductSupabase: Deleted product successfully');
    } catch (e) {
      log('ProductSupabase: Error deleting product - $e');
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
      log('ProductSupabase: Error generating code - $e');
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

    // Parse prices
    final pricesData = json['prices'] as List<dynamic>? ?? [];
    final prices = pricesData.map((p) => _mapSupabasePrice(p as Map<String, dynamic>)).toList();

    return Product(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      arName: json['ar_name'] ?? '',
      image: json['image'] ?? '',
      categoryId: categories,
      brandId: brand,
      unit: json['unit'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 0,
      description: json['description'] ?? '',
      arDescription: json['ar_description'] ?? '',
      expAbility: json['exp_ability'] ?? false,
      dateOfExpiery: json['date_of_expiery'] != null
          ? DateTime.tryParse(json['date_of_expiery'])
          : null,
      minimumQuantitySale: json['minimum_quantity_sale'] ?? 0,
      lowStock: json['low_stock'] ?? 0,
      wholePrice: (json['whole_price'] as num?)?.toDouble() ?? 0.0,
      startQuantaty: json['start_quantaty'] ?? 0,
      taxesId: json['taxes_id'],
      productHasImei: json['product_has_imei'] ?? false,
      differentPrice: json['different_price'] ?? false,
      showQuantity: json['show_quantity'] ?? false,
      maximumToShow: json['maximum_to_show'] ?? 0,
      galleryProduct: (json['gallery_product'] as List<dynamic>?)?.cast<String>() ?? [],
      isFeatured: json['is_featured'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      prices: prices,
    );
  }

  Price _mapSupabasePrice(Map<String, dynamic> json) {
    final variationsData = json['variations'] as List<dynamic>? ?? [];
    final variations = <VariationDetail>[];

    // Group variations by name
    final variationMap = <String, List<Option>>{};
    for (final v in variationsData) {
      final varData = v['variation'] as Map<String, dynamic>?;
      final optData = v['option'] as Map<String, dynamic>?;
      if (varData != null && optData != null) {
        final name = varData['name'] as String;
        final option = Option(
          id: optData['id'] ?? '',
          variationId: varData['id'] ?? '',
          name: optData['name'] ?? '',
          status: optData['status'] ?? true,
          createdAt: DateTime.tryParse(optData['created_at'] ?? '') ?? DateTime.now(),
          updatedAt: DateTime.tryParse(optData['updated_at'] ?? '') ?? DateTime.now(),
        );
        variationMap.putIfAbsent(name, () => []).add(option);
      }
    }

    variationMap.forEach((name, options) {
      variations.add(VariationDetail(name: name, options: options));
    });

    return Price(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      code: json['code'] ?? '',
      gallery: (json['gallery'] as List<dynamic>?)?.cast<String>() ?? [],
      quantity: json['quantity'] ?? 0,
      variations: variations,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Dio implementation for Product data source (legacy)
class _ProductDioDataSource implements ProductRepositoryInterface {
  @override
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.getProducts);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final productsJson = data['data']['products'] as List<dynamic>? ?? [];
          return productsJson
              .map((json) => Product.fromJson(json as Map<String, dynamic>))
              .toList()
              .reversed
              .toList();
        }
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<Product?> getProductById(String id) async {
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getProductById(id),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final productJson = response.data['data']?['product'];
        if (productJson != null) {
          return Product.fromJson(productJson);
        }
      }
      return null;
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<Product>> searchProductsByCode(String code) async {
    try {
      final response = await DioHelper.getData(
        url: EndPoint.productByCode,
        query: {'code': code},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final productsJson = data['data']['products'] as List<dynamic>? ?? [];
          return productsJson
              .map((json) => Product.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<Product>> getProductsByWarehouse(String warehouseId) async {
    // This might not be available in Dio API, fallback to getAllProducts
    final allProducts = await getAllProducts();
    return allProducts.where((p) => p.quantity > 0).toList();
  }

  @override
  Future<Product> createProduct(Product product, {List<File>? images}) async {
    try {
      // Convert images to base64 if provided
      String? base64Image;
      List<String> base64Gallery = [];
      
      if (images != null && images.isNotEmpty) {
        final bytes = await images.first.readAsBytes();
        base64Image = base64Encode(bytes);

        for (int i = 1; i < images.length; i++) {
          final imgBytes = await images[i].readAsBytes();
          base64Gallery.add(base64Encode(imgBytes));
        }
      }

      final response = await DioHelper.postData(
        url: EndPoint.createProduct,
        data: {
          'name': product.name,
          'ar_name': product.arName,
          'description': product.description,
          'ar_description': product.arDescription,
          'category_ids': product.categoryId.map((c) => c.id).toList(),
          'brand_id': product.brandId.id,
          'unit': product.unit,
          'price': product.price,
          'quantity': product.quantity,
          'exp_ability': product.expAbility,
          'date_of_expiery': product.dateOfExpiery?.toIso8601String(),
          'minimum_quantity_sale': product.minimumQuantitySale,
          'low_stock': product.lowStock,
          'whole_price': product.wholePrice,
          'start_quantaty': product.startQuantaty,
          'taxes_id': product.taxesId,
          'product_has_imei': product.productHasImei,
          'different_price': product.differentPrice,
          'show_quantity': product.showQuantity,
          'maximum_to_show': product.maximumToShow,
          'is_featured': product.isFeatured,
          if (base64Image != null) 'image': base64Image,
          if (base64Gallery.isNotEmpty) 'gallery_product': base64Gallery,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final productJson = response.data['data']?['product'];
        if (productJson != null) {
          return Product.fromJson(productJson);
        }
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<Product> updateProduct(String id, Product product, {List<File>? images}) async {
    try {
      // Convert images to base64 if provided
      String? base64Image;
      List<String> base64Gallery = [];
      
      if (images != null && images.isNotEmpty) {
        final bytes = await images.first.readAsBytes();
        base64Image = base64Encode(bytes);

        for (int i = 1; i < images.length; i++) {
          final imgBytes = await images[i].readAsBytes();
          base64Gallery.add(base64Encode(imgBytes));
        }
      }

      final response = await DioHelper.putData(
        url: EndPoint.updateProduct(id),
        data: {
          'name': product.name,
          'ar_name': product.arName,
          'description': product.description,
          'ar_description': product.arDescription,
          'category_ids': product.categoryId.map((c) => c.id).toList(),
          'brand_id': product.brandId.id,
          'unit': product.unit,
          'price': product.price,
          'quantity': product.quantity,
          'exp_ability': product.expAbility,
          'date_of_expiery': product.dateOfExpiery?.toIso8601String(),
          'minimum_quantity_sale': product.minimumQuantitySale,
          'low_stock': product.lowStock,
          'whole_price': product.wholePrice,
          'start_quantaty': product.startQuantaty,
          'taxes_id': product.taxesId,
          'product_has_imei': product.productHasImei,
          'different_price': product.differentPrice,
          'show_quantity': product.showQuantity,
          'maximum_to_show': product.maximumToShow,
          'is_featured': product.isFeatured,
          if (base64Image != null) 'image': base64Image,
          if (base64Gallery.isNotEmpty) 'gallery_product': base64Gallery,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final productJson = response.data['data']?['product'];
        if (productJson != null) {
          return Product.fromJson(productJson);
        }
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      final response = await DioHelper.deleteData(
        url: EndPoint.deleteProduct(id),
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<String?> generateProductCode() async {
    try {
      final response = await DioHelper.getData(
        url: EndPoint.generateProductCode,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']?['code'] as String?;
      }
      return null;
    } catch (e) {
      log('ProductDio: Error generating code - $e');
      return null;
    }
  }
}
