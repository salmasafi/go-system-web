import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../model/pandel_model.dart';

abstract class BundleRepositoryInterface {
  Future<List<PandelModel>> getAllBundles();
  Future<PandelModel> createBundle(PandelModel bundle);
  Future<PandelModel> updateBundle(PandelModel bundle);
  Future<bool> deleteBundle(String id);
}

class BundleRepository implements BundleRepositoryInterface {
  final _BundleSupabaseDataSource _dataSource = _BundleSupabaseDataSource();

  @override
  Future<List<PandelModel>> getAllBundles() => _dataSource.getAllBundles();

  @override
  Future<PandelModel> createBundle(PandelModel bundle) => _dataSource.createBundle(bundle);

  @override
  Future<PandelModel> updateBundle(PandelModel bundle) => _dataSource.updateBundle(bundle);

  @override
  Future<bool> deleteBundle(String id) => _dataSource.deleteBundle(id);
}

class _BundleSupabaseDataSource implements BundleRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<List<PandelModel>> getAllBundles() async {
    try {
      log('BundleSupabase: Fetching all bundles');
      // Fetch bundles with their products and warehouses
      final response = await _client.from('bundles').select('''
        *,
        bundle_products(
          *,
          product:products(*),
          product_price:product_prices(*)
        ),
        bundle_warehouses(*)
      ''').order('created_at', ascending: false);

      return (response as List).map((json) => _mapSupabaseToPandelModel(json)).toList();
    } catch (e) {
      log('BundleSupabase: Error fetching bundles - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<PandelModel> createBundle(PandelModel bundle) async {
    try {
      log('BundleSupabase: Creating bundle');
      
      // 1. Create the bundle record
      final bundleData = {
        'name': bundle.name,
        'start_date': bundle.startDate.toIso8601String(),
        'end_date': bundle.endDate.toIso8601String(),
        'status': bundle.status,
        'price': bundle.price,
        'all_warehouses': bundle.allWarehouses,
        'images': bundle.images,
      };
      
      final bundleResponse = await _client.from('bundles').insert(bundleData).select().single();
      final bundleId = bundleResponse['id'];

      // 2. Create bundle products
      if (bundle.products.isNotEmpty) {
        final productsData = bundle.products.map((p) => {
          'bundle_id': bundleId,
          'product_id': p.productId,
          'product_price_id': p.productPriceId,
          'quantity': p.quantity,
        }).toList();
        await _client.from('bundle_products').insert(productsData);
      }

      // 3. Create bundle warehouses if not all_warehouses
      if (!bundle.allWarehouses && bundle.warehouseIds != null) {
        final warehousesData = bundle.warehouseIds!.map((wId) => {
          'bundle_id': bundleId,
          'warehouse_id': wId,
        }).toList();
        await _client.from('bundle_warehouses').insert(warehousesData);
      }

      // 4. Fetch full bundle
      final fullResponse = await _client.from('bundles').select('''
        *,
        bundle_products(
          *,
          product:products(*),
          product_price:product_prices(*)
        ),
        bundle_warehouses(*)
      ''').eq('id', bundleId).single();
      
      return _mapSupabaseToPandelModel(fullResponse);
    } catch (e) {
      log('BundleSupabase: Error creating bundle - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<PandelModel> updateBundle(PandelModel bundle) async {
    try {
      log('BundleSupabase: Updating bundle');
      
      // 1. Update main bundle data
      await _client.from('bundles').update({
        'name': bundle.name,
        'start_date': bundle.startDate.toIso8601String(),
        'end_date': bundle.endDate.toIso8601String(),
        'status': bundle.status,
        'price': bundle.price,
        'all_warehouses': bundle.allWarehouses,
        'images': bundle.images,
      }).eq('id', bundle.id);

      // 2. Sync products (Delete and Recreate for simplicity in migration)
      await _client.from('bundle_products').delete().eq('bundle_id', bundle.id);
      if (bundle.products.isNotEmpty) {
        final productsData = bundle.products.map((p) => {
          'bundle_id': bundle.id,
          'product_id': p.productId,
          'product_price_id': p.productPriceId,
          'quantity': p.quantity,
        }).toList();
        await _client.from('bundle_products').insert(productsData);
      }

      // 3. Sync warehouses
      await _client.from('bundle_warehouses').delete().eq('bundle_id', bundle.id);
      if (!bundle.allWarehouses && bundle.warehouseIds != null) {
        final warehousesData = bundle.warehouseIds!.map((wId) => {
          'bundle_id': bundle.id,
          'warehouse_id': wId,
        }).toList();
        await _client.from('bundle_warehouses').insert(warehousesData);
      }

      final fullResponse = await _client.from('bundles').select('''
        *,
        bundle_products(
          *,
          product:products(*),
          product_price:product_prices(*)
        ),
        bundle_warehouses(*)
      ''').eq('id', bundle.id).single();
      
      return _mapSupabaseToPandelModel(fullResponse);
    } catch (e) {
      log('BundleSupabase: Error updating bundle - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> deleteBundle(String id) async {
    try {
      log('BundleSupabase: Deleting bundle');
      await _client.from('bundles').delete().eq('id', id);
      return true;
    } catch (e) {
      log('BundleSupabase: Error deleting bundle - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  PandelModel _mapSupabaseToPandelModel(Map<String, dynamic> json) {
    final products = (json['bundle_products'] as List? ?? []).map((bp) {
      final product = bp['product'] as Map<String, dynamic>?;
      return PandelProduct(
        productId: bp['product_id'],
        productPriceId: bp['product_price_id'],
        quantity: bp['quantity'],
        productName: product?['name'],
        productArName: product?['ar_name'],
        productImage: product?['image'],
        productPrice: (product?['price'] as num?)?.toDouble(),
      );
    }).toList();

    final warehouses = (json['bundle_warehouses'] as List? ?? [])
        .map((bw) => bw['warehouse_id'] as String)
        .toList();

    return PandelModel(
      id: json['id'],
      name: json['name'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      status: json['status'],
      images: List<String>.from(json['images'] ?? []),
      products: products,
      price: (json['price'] as num).toDouble(),
      allWarehouses: json['all_warehouses'] ?? true,
      warehouseIds: warehouses.isEmpty ? null : warehouses,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      version: 0,
    );
  }
}
