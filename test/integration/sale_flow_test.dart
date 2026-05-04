import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/pos/sales/data/repositories/sale_repository.dart';
import 'package:GoSystem/features/admin/product/data/repositories/product_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}
class MockPostgrestTransformBuilder extends Mock implements PostgrestTransformBuilder<Map<String, dynamic>?> {}
class MockPostgrestFilterBuilderAny extends Mock implements PostgrestFilterBuilder<dynamic> {}

void main() {
  late SaleRepository saleRepository;
  late ProductRepository productRepository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;
  late MockPostgrestTransformBuilder mockTransformProduct;
  late MockPostgrestTransformBuilder mockTransformSale;
  late MockPostgrestFilterBuilderAny mockRPCBuilder;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    mockTransformProduct = MockPostgrestTransformBuilder();
    mockTransformSale = MockPostgrestTransformBuilder();
    mockRPCBuilder = MockPostgrestFilterBuilderAny();
    
    SupabaseClientWrapper.setMockInstance(mockClient);
    saleRepository = SaleRepository();
    productRepository = ProductRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('Sale Flow Integration Tests (Mocked)', () {
    test('Successful Sale Flow: Fetch Product -> Create Sale -> Fetch History', () async {
      // 1. Fetch Product
      final mockProductData = {
        'id': 'prod-1',
        'name': 'Test Product',
        'price': 100.0,
        'quantity': 5,
        'categories': [],
        'brand': null,
        'prices': []
      };

      when(() => mockClient.from('products')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('id', 'prod-1')).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.maybeSingle()).thenReturn(mockTransformProduct);
      when(() => mockTransformProduct.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(Map<String, dynamic>?);
        return callback(mockProductData);
      });

      final product = await productRepository.getProductById('prod-1');
      expect(product, isNotNull);
      expect(product!.price, 100.0);

      // 2. Create Sale
      when(() => mockClient.rpc('create_sale_with_items', params: any(named: 'params')))
          .thenAnswer((_) => mockRPCBuilder);
      when(() => mockRPCBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(dynamic);
        return callback({'sale_id': 'sale-1'});
      });

      // Stub getSaleById for the createSale method's return
      final mockSaleDetail = {
        'id': 'sale-1',
        'reference': 'REF-001',
        'grand_total': 100.0,
        'items': []
      };
      when(() => mockClient.from('sales')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('id', 'sale-1')).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.maybeSingle()).thenReturn(mockTransformSale);
      when(() => mockTransformSale.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(Map<String, dynamic>?);
        return callback(mockSaleDetail);
      });

      final sale = await saleRepository.createSale(
        customerId: 'cust-1',
        warehouseId: 'wh-1',
        items: [{'product_id': 'prod-1', 'quantity': 1, 'price': 100.0}],
        grandTotal: 100.0,
      );

      expect(sale.id, 'sale-1');

      // 3. Verify Sale in History
      final mockHistoryData = [
        {
          'id': 'sale-1',
          'reference': 'REF-001',
          'grand_total': 100.0,
          'sale_status': 'completed',
          'created_at': '2024-05-01T10:00:00Z',
          'customer': {'name': 'Test Customer'}
        }
      ];
      when(() => mockClient.from('sales')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('sale_status', 'completed')).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending'))).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockHistoryData);
      });

      final history = await saleRepository.getAllSales();
      expect(history.any((s) => s.id == 'sale-1'), isTrue);
    });
  });
}
