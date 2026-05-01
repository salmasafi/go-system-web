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

/// Warehouse repository using Supabase as the primary data source.
class WarehouseRepository implements WarehouseRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<List<Warehouses>> getAllWarehouses() async {
    try {
      log('WarehouseRepository: Fetching all warehouses');

      final response = await _client
          .from('warehouses')
          .select('*, warehouse_products(count)')
          .order('name');

      final warehouses = (response as List)
          .map((json) => _mapSupabaseToWarehouses(json))
          .toList();

      log('WarehouseRepository: Fetched ${warehouses.length} warehouses');
      return warehouses;
    } catch (e) {
      log('WarehouseRepository: Error fetching warehouses - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<Warehouses?> getWarehouseById(String id) async {
    try {
      log('WarehouseRepository: Fetching warehouse by id: $id');

      final response = await _client
          .from('warehouses')
          .select('*')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return _mapSupabaseToWarehouses(response);
    } catch (e) {
      log('WarehouseRepository: Error fetching warehouse - $e');
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
      log('WarehouseRepository: Creating warehouse: $name');

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

      log('WarehouseRepository: Created warehouse successfully');
      return _mapSupabaseToWarehouses(response);
    } catch (e) {
      log('WarehouseRepository: Error creating warehouse - $e');
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
      log('WarehouseRepository: Updating warehouse: $id');

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

      log('WarehouseRepository: Updated warehouse successfully');
      return _mapSupabaseToWarehouses(response);
    } catch (e) {
      log('WarehouseRepository: Error updating warehouse - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteWarehouse(String id) async {
    try {
      log('WarehouseRepository: Deleting warehouse: $id');

      await _client.from('warehouses').delete().eq('id', id);

      log('WarehouseRepository: Deleted warehouse successfully');
    } catch (e) {
      log('WarehouseRepository: Error deleting warehouse - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<WarehouseProduct>> getWarehouseProducts(String warehouseId) async {
    try {
      log('WarehouseRepository: Fetching products for warehouse: $warehouseId');

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

      log('WarehouseRepository: Fetched ${products.length} products');
      return products;
    } catch (e) {
      log('WarehouseRepository: Error fetching warehouse products - $e');
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
      log('WarehouseRepository: Adding product $productId to warehouse $warehouseId');

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

      log('WarehouseRepository: Product added successfully');
      return true;
    } catch (e) {
      log('WarehouseRepository: Error adding product - $e');
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
      log('WarehouseRepository: Updating quantity for product $productId in warehouse $warehouseId');

      await _client
          .from('warehouse_products')
          .update({'quantity': quantity})
          .eq('warehouse_id', warehouseId)
          .eq('product_id', productId);

      // Update warehouse stats
      await _updateWarehouseStats(warehouseId);

      log('WarehouseRepository: Quantity updated successfully');
      return true;
    } catch (e) {
      log('WarehouseRepository: Error updating quantity - $e');
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
      log('WarehouseRepository: Transferring $quantity of product $productId from $fromWarehouseId to $toWarehouseId');

      // Use RPC for atomic transfer operation
      await _client.rpc('transfer_product_between_warehouses', params: {
        'p_from_warehouse_id': fromWarehouseId,
        'p_to_warehouse_id': toWarehouseId,
        'p_product_id': productId,
        'p_quantity': quantity,
      });

      log('WarehouseRepository: Transfer completed successfully');
      return true;
    } catch (e) {
      log('WarehouseRepository: Error transferring product - $e');
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
      log('WarehouseRepository: Error updating warehouse stats - $e');
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
