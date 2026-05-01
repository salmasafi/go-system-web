import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/migration/migration_service.dart';
import '../../../../../core/services/dio_helper.dart';
import '../../../../../core/services/endpoints.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../model/ware_house_model.dart';
import '../../../product/models/warehouse_product.dart';

/// Interface for warehouse data operations
abstract class WarehouseRepositoryInterface {
  Future<List<Warehouses>> getAllWarehouses();
  Future<Warehouses?> getWarehouseById(String id);
  Future<Warehouses> createWarehouse({
    required String name,
    required String address,
    required String phone,
    required String email,
  });
  Future<Warehouses> updateWarehouse({
    required String id,
    required String name,
    required String address,
    required String phone,
    required String email,
  });
  Future<void> deleteWarehouse(String id);
  Future<List<WarehouseProduct>> getWarehouseProducts(String warehouseId);
  Future<bool> addProductToWarehouse({
    required String productId,
    required String warehouseId,
    required int quantity,
    int lowStock,
  });
  Future<bool> updateProductQuantity({
    required String productId,
    required String warehouseId,
    required int quantity,
  });
  Future<bool> transferBetweenWarehouses({
    required String fromWarehouseId,
    required String toWarehouseId,
    required String productId,
    required int quantity,
  });
}

/// Hybrid repository that supports both Dio and Supabase for warehouses
class WarehouseRepository implements WarehouseRepositoryInterface {
  late final WarehouseRepositoryInterface _dataSource;

  WarehouseRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('warehouses')) {
      log('WarehouseRepository: Using Supabase');
      _dataSource = _WarehouseSupabaseDataSource();
    } else {
      log('WarehouseRepository: Using Dio (legacy)');
      _dataSource = _WarehouseDioDataSource();
    }
  }

  @override
  Future<List<Warehouses>> getAllWarehouses() => _dataSource.getAllWarehouses();

  @override
  Future<Warehouses?> getWarehouseById(String id) => _dataSource.getWarehouseById(id);

  @override
  Future<Warehouses> createWarehouse({
    required String name,
    required String address,
    required String phone,
    required String email,
  }) => _dataSource.createWarehouse(
    name: name,
    address: address,
    phone: phone,
    email: email,
  );

  @override
  Future<Warehouses> updateWarehouse({
    required String id,
    required String name,
    required String address,
    required String phone,
    required String email,
  }) => _dataSource.updateWarehouse(
    id: id,
    name: name,
    address: address,
    phone: phone,
    email: email,
  );

  @override
  Future<void> deleteWarehouse(String id) => _dataSource.deleteWarehouse(id);

  @override
  Future<List<WarehouseProduct>> getWarehouseProducts(String warehouseId) =>
      _dataSource.getWarehouseProducts(warehouseId);

  @override
  Future<bool> addProductToWarehouse({
    required String productId,
    required String warehouseId,
    required int quantity,
    int lowStock = 0,
  }) => _dataSource.addProductToWarehouse(
    productId: productId,
    warehouseId: warehouseId,
    quantity: quantity,
    lowStock: lowStock,
  );

  @override
  Future<bool> updateProductQuantity({
    required String productId,
    required String warehouseId,
    required int quantity,
  }) => _dataSource.updateProductQuantity(
    productId: productId,
    warehouseId: warehouseId,
    quantity: quantity,
  );

  @override
  Future<bool> transferBetweenWarehouses({
    required String fromWarehouseId,
    required String toWarehouseId,
    required String productId,
    required int quantity,
  }) => _dataSource.transferBetweenWarehouses(
    fromWarehouseId: fromWarehouseId,
    toWarehouseId: toWarehouseId,
    productId: productId,
    quantity: quantity,
  );

  void enableSupabase() {
    MigrationService.enableSupabase('warehouses');
    _initializeDataSource();
  }

  void enableDio() {
    MigrationService.enableDio('warehouses');
    _initializeDataSource();
  }
}

/// Supabase implementation for Warehouse data source
class _WarehouseSupabaseDataSource implements WarehouseRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<List<Warehouses>> getAllWarehouses() async {
    try {
      log('WarehouseSupabase: Fetching all warehouses');

      final response = await _client
          .from('warehouses')
          .select('*, warehouse_products(count)')
          .order('name');

      final warehouses = (response as List)
          .map((json) => _mapSupabaseToWarehouses(json))
          .toList();

      log('WarehouseSupabase: Fetched ${warehouses.length} warehouses');
      return warehouses;
    } catch (e) {
      log('WarehouseSupabase: Error fetching warehouses - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<Warehouses?> getWarehouseById(String id) async {
    try {
      log('WarehouseSupabase: Fetching warehouse by id: $id');

      final response = await _client
          .from('warehouses')
          .select('*')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return _mapSupabaseToWarehouses(response);
    } catch (e) {
      log('WarehouseSupabase: Error fetching warehouse - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<Warehouses> createWarehouse({
    required String name,
    required String address,
    required String phone,
    required String email,
  }) async {
    try {
      log('WarehouseSupabase: Creating warehouse: $name');

      final response = await _client
          .from('warehouses')
          .insert({
            'name': name,
            'address': address,
            'phone': phone,
            'email': email,
            'number_of_products': 0,
            'stock_quantity': 0,
          })
          .select()
          .single();

      log('WarehouseSupabase: Created warehouse successfully');
      return _mapSupabaseToWarehouses(response);
    } catch (e) {
      log('WarehouseSupabase: Error creating warehouse - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<Warehouses> updateWarehouse({
    required String id,
    required String name,
    required String address,
    required String phone,
    required String email,
  }) async {
    try {
      log('WarehouseSupabase: Updating warehouse: $id');

      final response = await _client
          .from('warehouses')
          .update({
            'name': name,
            'address': address,
            'phone': phone,
            'email': email,
          })
          .eq('id', id)
          .select()
          .single();

      log('WarehouseSupabase: Updated warehouse successfully');
      return _mapSupabaseToWarehouses(response);
    } catch (e) {
      log('WarehouseSupabase: Error updating warehouse - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteWarehouse(String id) async {
    try {
      log('WarehouseSupabase: Deleting warehouse: $id');

      await _client.from('warehouses').delete().eq('id', id);

      log('WarehouseSupabase: Deleted warehouse successfully');
    } catch (e) {
      log('WarehouseSupabase: Error deleting warehouse - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<WarehouseProduct>> getWarehouseProducts(String warehouseId) async {
    try {
      log('WarehouseSupabase: Fetching products for warehouse: $warehouseId');

      final response = await _client
          .from('warehouse_products')
          .select('''
            *,
            product:product_id(id, name, code, image)
          ''')
          .eq('warehouse_id', warehouseId);

      final products = (response as List)
          .map((json) => _mapSupabaseToWarehouseProduct(json))
          .toList();

      log('WarehouseSupabase: Fetched ${products.length} products');
      return products;
    } catch (e) {
      log('WarehouseSupabase: Error fetching warehouse products - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> addProductToWarehouse({
    required String productId,
    required String warehouseId,
    required int quantity,
    int lowStock = 0,
  }) async {
    try {
      log('WarehouseSupabase: Adding product $productId to warehouse $warehouseId');

      // Check if product already exists in warehouse
      final existing = await _client
          .from('warehouse_products')
          .select()
          .eq('warehouse_id', warehouseId)
          .eq('product_id', productId)
          .maybeSingle();

      if (existing != null) {
        // Update existing quantity
        await _client
            .from('warehouse_products')
            .update({
              'quantity': (existing['quantity'] as int) + quantity,
              'low_stock': lowStock,
            })
            .eq('id', existing['id']);
      } else {
        // Insert new warehouse product
        await _client.from('warehouse_products').insert({
          'warehouse_id': warehouseId,
          'product_id': productId,
          'quantity': quantity,
          'low_stock': lowStock,
        });
      }

      // Update warehouse stats
      await _updateWarehouseStats(warehouseId);

      log('WarehouseSupabase: Product added successfully');
      return true;
    } catch (e) {
      log('WarehouseSupabase: Error adding product - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> updateProductQuantity({
    required String productId,
    required String warehouseId,
    required int quantity,
  }) async {
    try {
      log('WarehouseSupabase: Updating quantity for product $productId in warehouse $warehouseId');

      await _client
          .from('warehouse_products')
          .update({'quantity': quantity})
          .eq('warehouse_id', warehouseId)
          .eq('product_id', productId);

      // Update warehouse stats
      await _updateWarehouseStats(warehouseId);

      log('WarehouseSupabase: Quantity updated successfully');
      return true;
    } catch (e) {
      log('WarehouseSupabase: Error updating quantity - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> transferBetweenWarehouses({
    required String fromWarehouseId,
    required String toWarehouseId,
    required String productId,
    required int quantity,
  }) async {
    try {
      log('WarehouseSupabase: Transferring $quantity of product $productId from $fromWarehouseId to $toWarehouseId');

      // Use RPC for atomic transfer operation
      await _client.rpc('transfer_product_between_warehouses', params: {
        'p_from_warehouse_id': fromWarehouseId,
        'p_to_warehouse_id': toWarehouseId,
        'p_product_id': productId,
        'p_quantity': quantity,
      });

      log('WarehouseSupabase: Transfer completed successfully');
      return true;
    } catch (e) {
      log('WarehouseSupabase: Error transferring product - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  /// Update warehouse product count and stock quantity
  Future<void> _updateWarehouseStats(String warehouseId) async {
    try {
      final products = await _client
          .from('warehouse_products')
          .select('quantity')
          .eq('warehouse_id', warehouseId);

      final productCount = products.length;
      final totalQuantity = products.fold<int>(
        0,
        (sum, p) => sum + ((p['quantity'] as num?)?.toInt() ?? 0),
      );

      await _client.from('warehouses').update({
        'number_of_products': productCount,
        'stock_quantity': totalQuantity,
      }).eq('id', warehouseId);
    } catch (e) {
      log('WarehouseSupabase: Error updating warehouse stats - $e');
    }
  }

  /// Map Supabase response to Warehouses model
  Warehouses _mapSupabaseToWarehouses(Map<String, dynamic> json) {
    return Warehouses(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      numberOfProducts: json['number_of_products'] ?? 0,
      stockQuantity: json['stock_quantity'] ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      v: json['version'] ?? 1,
    );
  }

  /// Map Supabase response to WarehouseProduct model
  WarehouseProduct _mapSupabaseToWarehouseProduct(Map<String, dynamic> json) {
    final productData = json['product'] as Map<String, dynamic>?;

    return WarehouseProduct(
      id: json['id'] ?? '',
      warehouseId: json['warehouse_id'] ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      v: json['version'] ?? 1,
      productId: productData != null
          ? ProductId(
              id: productData['id'] ?? '',
              name: productData['name'] ?? '',
            )
          : null,
    );
  }
}

/// Dio implementation for Warehouse data source (legacy)
class _WarehouseDioDataSource implements WarehouseRepositoryInterface {
  @override
  Future<List<Warehouses>> getAllWarehouses() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.getWarehouses);

      if (response.statusCode == 200) {
        final model = WareHouseModel.fromJson(response.data);
        if (model.success == true && model.data?.warehouses != null) {
          return model.data!.warehouses!;
        }
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<Warehouses?> getWarehouseById(String id) async {
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getWareHouseById(id),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final warehouseJson = response.data['data']?['warehouse'];
        if (warehouseJson != null) {
          return Warehouses.fromJson(warehouseJson);
        }
      }
      return null;
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<Warehouses> createWarehouse({
    required String name,
    required String address,
    required String phone,
    required String email,
  }) async {
    try {
      final response = await DioHelper.postData(
        url: EndPoint.createWarehouse,
        data: {
          'name': name,
          'address': address,
          'phone': phone,
          'email': email,
        },
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {
        final warehouseJson = response.data['data']?['warehouse'];
        if (warehouseJson != null) {
          return Warehouses.fromJson(warehouseJson);
        }
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<Warehouses> updateWarehouse({
    required String id,
    required String name,
    required String address,
    required String phone,
    required String email,
  }) async {
    try {
      final response = await DioHelper.putData(
        url: '${EndPoint.updateWarehouse}/$id',
        data: {
          'name': name,
          'address': address,
          'phone': phone,
          'email': email,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final warehouseJson = response.data['data']?['warehouse'];
        if (warehouseJson != null) {
          return Warehouses.fromJson(warehouseJson);
        }
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteWarehouse(String id) async {
    try {
      final response = await DioHelper.deleteData(
        url: '${EndPoint.deleteWarehouse}/$id',
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<WarehouseProduct>> getWarehouseProducts(String warehouseId) async {
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getWareHouseProducts(warehouseId),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final productsData = response.data['data']?['products'] as List<dynamic>?;
        if (productsData != null) {
          return productsData
              .map((json) => WarehouseProduct.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> addProductToWarehouse({
    required String productId,
    required String warehouseId,
    required int quantity,
    int lowStock = 0,
  }) async {
    try {
      final response = await DioHelper.postData(
        url: EndPoint.addProductToWarehouse(warehouseId),
        data: {
          'productId': productId,
          'warehouseId': warehouseId,
          'quantity': quantity,
          'low_stock': lowStock,
        },
      );

      return (response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true;
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> updateProductQuantity({
    required String productId,
    required String warehouseId,
    required int quantity,
  }) async {
    try {
      final response = await DioHelper.putData(
        url: '${EndPoint.getWarehouses}/$warehouseId/products/$productId',
        data: {
          'product_id': productId,
          'warehouse_id': warehouseId,
          'quantity': quantity,
        },
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> transferBetweenWarehouses({
    required String fromWarehouseId,
    required String toWarehouseId,
    required String productId,
    required int quantity,
  }) async {
    try {
      final response = await DioHelper.postData(
        url: '${EndPoint.getWarehouses}/transfer',
        data: {
          'from_warehouse_id': fromWarehouseId,
          'to_warehouse_id': toWarehouseId,
          'product_id': productId,
          'quantity': quantity,
        },
      );

      return (response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true;
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }
}
