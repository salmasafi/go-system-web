import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/pos/home/data/repositories/pos_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}
class MockPostgrestTransformBuilder extends Mock implements PostgrestTransformBuilder<Map<String, dynamic>?> {}

void main() {
  late POSRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;
  late MockPostgrestTransformBuilder mockTransformBuilder;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    mockTransformBuilder = MockPostgrestTransformBuilder();

    SupabaseClientWrapper.setMockInstance(mockClient);
    repository = POSRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('POSRepository Unit Tests', () {
    test('searchProductsForPOS should return list of products', () async {
      final mockData = [
        {
          'id': 'prod-1',
          'name': 'Test Product',
          'code': 'TP001',
          'price': 100.0,
          'quantity': 50,
          'status': 'active',
        },
      ];

      when(() => mockClient.from('products')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.or(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.limit(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any())).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockData);
      });

      final result = await repository.searchProductsForPOS('test');

      expect(result.length, 1);
      expect(result[0].id, 'prod-1');
    });

    test('getProductByBarcode should return product for valid barcode', () async {
      final mockData = {
        'id': 'prod-1',
        'name': 'Test Product',
        'barcode': '123456789',
        'price': 100.0,
        'quantity': 50,
      };

      when(() => mockClient.from('products')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.maybeSingle()).thenReturn(mockTransformBuilder);

      when(() => mockTransformBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(Map<String, dynamic>?);
        return callback(mockData);
      });

      final result = await repository.getProductByBarcode('123456789');

      expect(result, isNotNull);
      expect(result!.id, 'prod-1');
    });

    test('isServerReachable should return true when server is reachable', () async {
      when(() => mockClient.from('products')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.limit(any())).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return callback([]);
      });

      final result = await repository.isServerReachable();

      expect(result, true);
    });

    test('syncOfflineSales should return true on success', () async {
      when(() => mockClient.rpc(any(), params: any(named: 'params'))).thenAnswer((_) async => {});

      final offlineSales = [
        {
          'customer_id': 'cust-1',
          'warehouse_id': 'wh-1',
          'items': [],
          'grand_total': 100.0,
        },
      ];

      final result = await repository.syncOfflineSales(offlineSales);

      expect(result, true);
    });
  });
}
