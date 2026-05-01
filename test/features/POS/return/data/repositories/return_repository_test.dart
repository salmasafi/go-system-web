import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/pos/return/data/repositories/return_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

void main() {
  late ReturnRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();

    SupabaseClientWrapper.setMockInstance(mockClient);
    repository = ReturnRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('ReturnRepository Unit Tests', () {
    test('getAllSaleReturns should return list of sale returns', () async {
      final mockData = [
        {
          'id': 'ret-1',
          'sale_id': 'sale-1',
          'customer_id': 'cust-1',
          'total_amount': 100.0,
          'status': 'completed',
          'created_at': '2024-01-01',
        },
      ];

      when(() => mockClient.from('sale_returns')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending'))).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockData);
      });

      final result = await repository.getAllSaleReturns();

      expect(result.length, 1);
      expect(result[0].id, 'ret-1');
    });

    test('createSaleReturn should complete successfully', () async {
      when(() => mockClient.rpc(any(), params: any(named: 'params'))).thenAnswer((_) async => {
        'return_id': 'ret-new',
        'success': true,
      });

      final items = [
        {'product_id': 'prod-1', 'quantity': 2, 'unit_price': 50.0},
      ];

      final result = await repository.createSaleReturn(
        saleId: 'sale-1',
        customerId: 'cust-1',
        items: items,
        totalAmount: 100.0,
      );

      expect(result.id, isNotNull);
    });
  });
}
