import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/pos/return/data/repositories/return_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}
class MockPostgrestFilterBuilderAny extends Mock implements PostgrestFilterBuilder<dynamic> {}

void main() {
  late ReturnRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;
  late MockPostgrestFilterBuilderAny mockRpcBuilder;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    mockRpcBuilder = MockPostgrestFilterBuilderAny();

    SupabaseClientWrapper.setMockInstance(mockClient);
    repository = ReturnRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('ReturnRepository Unit Tests', () {
    test('getAllPurchaseReturns should return list of purchase returns', () async {
      final mockData = [
        {
          'id': 'ret-1',
          'purchase_id': 'purchase-1',
          'supplier_id': 'sup-1',
          'total_amount': 100.0,
          'status': 'completed',
          'created_at': '2024-01-01',
          'purchase': {'id': 'purchase-1', 'reference': 'PUR-001', 'grand_total': 200.0},
          'supplier': {'id': 'sup-1', 'company_name': 'Test Supplier', 'username': 'test', 'phone_number': '123456'},
          'items': [],
        },
      ];

      when(() => mockClient.from('purchase_returns')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending'))).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockData);
      });

      final result = await repository.getAllPurchaseReturns();

      expect(result.length, 1);
      expect(result[0].id, 'ret-1');
    });

    test('createSaleReturn should complete successfully', () async {
      when(() => mockClient.rpc(any(), params: any(named: 'params')))
          .thenReturn(mockRpcBuilder);
      when(() => mockRpcBuilder.then(any())).thenAnswer((invocation) async {
        final callback =
            invocation.positionalArguments[0] as dynamic Function(dynamic);
        return callback(<String, dynamic>{
          'return_id': 'ret-new',
          'success': true,
        });
      });

      final items = [
        {'product_id': 'prod-1', 'quantity': 2, 'unit_price': 50.0},
      ];

      final result = await repository.createSaleReturn(
        saleId: 'sale-1',
        items: items,
        totalAmount: 100.0,
      );

      expect(result.id, isNotNull);
    });
  });
}
