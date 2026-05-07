import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../../../admin/product/models/product_model.dart' as admin_product;

/// Interface for POS-specific data operations
abstract class POSRepositoryInterface {
  /// Quick product lookup by barcode for POS scanning
  Future<admin_product.Product?> getProductByBarcode(String barcode);

  /// Quick product lookup by code
  Future<admin_product.Product?> getProductByCode(String code);

  /// Search products for POS (fast, limited results)
  Future<List<admin_product.Product>> searchProductsForPOS(String query, {int limit = 20});

  /// Get products by category for POS
  Future<List<admin_product.Product>> getProductsByCategoryForPOS(String categoryId, {int limit = 50});

  /// Get popular products for POS homepage
  Future<List<admin_product.Product>> getPopularProducts({int limit = 20});

  /// Get products with low stock warning
  Future<List<admin_product.Product>> getLowStockProducts({int limit = 20});

  /// Sync offline sales to server
  Future<bool> syncOfflineSales(List<Map<String, dynamic>> offlineSales);

  /// Check if server is reachable
  Future<bool> isServerReachable();

  /// Generate receipt for a sale
  Future<Map<String, dynamic>> generateReceipt(String saleId);

  /// Save draft cart for later
  Future<void> saveDraftCart(String cartId, List<Map<String, dynamic>> items);

  /// Get saved draft carts
  Future<List<Map<String, dynamic>>> getDraftCarts();

  /// Delete draft cart
  Future<void> deleteDraftCart(String cartId);
}

/// POS Repository using Supabase
class POSRepository implements POSRepositoryInterface {
  final _POSSupabaseDataSource _dataSource = _POSSupabaseDataSource();

  @override
  Future<admin_product.Product?> getProductByBarcode(String barcode) =>
      _dataSource.getProductByBarcode(barcode);

  @override
  Future<admin_product.Product?> getProductByCode(String code) =>
      _dataSource.getProductByCode(code);

  @override
  Future<List<admin_product.Product>> searchProductsForPOS(String query, {int limit = 20}) =>
      _dataSource.searchProductsForPOS(query, limit: limit);

  @override
  Future<List<admin_product.Product>> getProductsByCategoryForPOS(String categoryId, {int limit = 50}) =>
      _dataSource.getProductsByCategoryForPOS(categoryId, limit: limit);

  @override
  Future<List<admin_product.Product>> getPopularProducts({int limit = 20}) =>
      _dataSource.getPopularProducts(limit: limit);

  @override
  Future<List<admin_product.Product>> getLowStockProducts({int limit = 20}) =>
      _dataSource.getLowStockProducts(limit: limit);

  @override
  Future<bool> syncOfflineSales(List<Map<String, dynamic>> offlineSales) =>
      _dataSource.syncOfflineSales(offlineSales);

  @override
  Future<bool> isServerReachable() => _dataSource.isServerReachable();

  @override
  Future<Map<String, dynamic>> generateReceipt(String saleId) =>
      _dataSource.generateReceipt(saleId);

  @override
  Future<void> saveDraftCart(String cartId, List<Map<String, dynamic>> items) =>
      _dataSource.saveDraftCart(cartId, items);

  @override
  Future<List<Map<String, dynamic>>> getDraftCarts() =>
      _dataSource.getDraftCarts();

  @override
  Future<void> deleteDraftCart(String cartId) =>
      _dataSource.deleteDraftCart(cartId);
}

/// Supabase implementation for POS data source
class _POSSupabaseDataSource implements POSRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;
  static const String _productsTable = 'products';
  static const String _salesTable = 'sales';
  static const String _draftCartsTable = 'pos_draft_carts';

  @override
  Future<admin_product.Product?> getProductByBarcode(String barcode) async {
    try {
      log('POSSupabase: Looking up product by barcode: $barcode');

      final response = await _client
          .from(_productsTable)
          .select('''
            *,
            brand:brands(id, name, logo),
            categories:product_categories(category:category_id(id, name))
          ''')
          .eq('barcode', barcode)
          .maybeSingle();

      if (response == null) {
        log('POSSupabase: No product found for barcode: $barcode');
        return null;
      }

      return admin_product.Product.fromJson(response);
    } catch (e) {
      log('POSSupabase: Error looking up product by barcode - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<admin_product.Product?> getProductByCode(String code) async {
    try {
      log('POSSupabase: Looking up product by code: $code');

      final response = await _client
          .from(_productsTable)
          .select('''
            *,
            brand:brands(id, name, logo),
            categories:product_categories(category:category_id(id, name))
          ''')
          .ilike('code', code)
          .maybeSingle();

      if (response == null) {
        log('POSSupabase: No product found for code: $code');
        return null;
      }

      return admin_product.Product.fromJson(response);
    } catch (e) {
      log('POSSupabase: Error looking up product by code - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<admin_product.Product>> searchProductsForPOS(String query, {int limit = 20}) async {
    try {
      log('POSSupabase: Searching products for POS: $query');

      final response = await _client
          .from(_productsTable)
          .select('''
            *,
            brand:brands(id, name, logo),
            categories:product_categories(category:category_id(id, name))
          ''')
          .or('name.ilike.%$query%,code.ilike.%$query%,barcode.ilike.%$query%')
          .eq('status', 'active')
          .limit(limit)
          .order('name');

      return (response as List)
          .map((json) => admin_product.Product.fromJson(json))
          .toList();
    } catch (e) {
      log('POSSupabase: Error searching products - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<admin_product.Product>> getProductsByCategoryForPOS(String categoryId, {int limit = 50}) async {
    try {
      log('POSSupabase: Getting products for category: $categoryId');

      final response = await _client
          .from(_productsTable)
          .select('''
            *,
            brand:brands(id, name, logo),
            categories:product_categories!inner(category:category_id(id, name))
          ''')
          .eq('product_categories.category_id', categoryId)
          .eq('status', 'active')
          .limit(limit)
          .order('name');

      return (response as List)
          .map((json) => admin_product.Product.fromJson(json))
          .toList();
    } catch (e) {
      log('POSSupabase: Error getting products by category - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<admin_product.Product>> getPopularProducts({int limit = 20}) async {
    try {
      log('POSSupabase: Getting popular products');

      // Get products with highest sales volume
      final response = await _client
          .from(_productsTable)
          .select('''
            *,
            brand:brands(id, name, logo),
            categories:product_categories(category:category_id(id, name))
          ''')
          .eq('status', 'active')
          .order('sales_count', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => admin_product.Product.fromJson(json))
          .toList();
    } catch (e) {
      log('POSSupabase: Error getting popular products - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<admin_product.Product>> getLowStockProducts({int limit = 20}) async {
    try {
      log('POSSupabase: Getting low stock products');

      final response = await _client
          .from(_productsTable)
          .select('''
            *,
            brand:brands(id, name, logo),
            categories:product_categories(category:category_id(id, name))
          ''')
          .lte('quantity', 10)
          .eq('status', 'active')
          .limit(limit)
          .order('quantity');

      return (response as List)
          .map((json) => admin_product.Product.fromJson(json))
          .toList();
    } catch (e) {
      log('POSSupabase: Error getting low stock products - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> syncOfflineSales(List<Map<String, dynamic>> offlineSales) async {
    try {
      log('POSSupabase: Syncing ${offlineSales.length} offline sales');

      for (final sale in offlineSales) {
        await _client.rpc('create_offline_sale', params: {
          'p_sale_data': sale,
        });
      }

      log('POSSupabase: Successfully synced all offline sales');
      return true;
    } catch (e) {
      log('POSSupabase: Error syncing offline sales - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<bool> isServerReachable() async {
    try {
      // Simple health check query
      await _client.from(_productsTable).select('id').limit(1);
      return true;
    } catch (e) {
      log('POSSupabase: Server unreachable - $e');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> generateReceipt(String saleId) async {
    try {
      log('POSSupabase: Generating receipt for sale: $saleId');

      final response = await _client
          .from(_salesTable)
          .select('''
            *,
            customer:customer_id(id, name, phone, email),
            warehouse:warehouse_id(id, name),
            items:sale_items(
              *,
              product:product_id(id, name, code)
            ),
            payments:sale_payments(*)
          ''')
          .eq('id', saleId)
          .single();

      // Format receipt data
      final receiptData = {
        'sale_id': saleId,
        'reference': response['reference'],
        'date': response['created_at'],
        'customer': response['customer'],
        'warehouse': response['warehouse'],
        'items': (response['items'] as List).map((item) => {
          'product_name': item['product']?['name'] ?? 'Unknown',
          'product_code': item['product']?['code'] ?? '',
          'quantity': item['quantity'],
          'price': item['price'],
          'total': (item['quantity'] as num) * (item['price'] as num),
        }).toList(),
        'subtotal': response['subtotal'],
        'tax_amount': response['tax_amount'],
        'discount': response['discount'],
        'grand_total': response['grand_total'],
        'payments': response['payments'],
        'payment_status': response['payment_status'],
      };

      return receiptData;
    } catch (e) {
      log('POSSupabase: Error generating receipt - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> saveDraftCart(String cartId, List<Map<String, dynamic>> items) async {
    try {
      log('POSSupabase: Saving draft cart: $cartId');

      await _client.from(_draftCartsTable).upsert({
        'id': cartId,
        'items': items,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      log('POSSupabase: Error saving draft cart - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDraftCarts() async {
    try {
      log('POSSupabase: Getting draft carts');

      final response = await _client
          .from(_draftCartsTable)
          .select()
          .order('updated_at', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      log('POSSupabase: Error getting draft carts - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteDraftCart(String cartId) async {
    try {
      log('POSSupabase: Deleting draft cart: $cartId');

      await _client.from(_draftCartsTable).delete().eq('id', cartId);
    } catch (e) {
      log('POSSupabase: Error deleting draft cart - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }
}
