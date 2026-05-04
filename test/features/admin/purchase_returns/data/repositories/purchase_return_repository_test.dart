import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/purchase_returns/data/repositories/purchase_return_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}
class MockPostgrestTransformBuilder extends Mock implements PostgrestTransformBuilder<Map<String, dynamic>?> {}
class MockPostgrestTransformBuilderSingle extends Mock implements PostgrestTransformBuilder<Map<String, dynamic>> {}

void main() {
  late PurchaseReturnRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;
  late MockPostgrestTransformBuilder mockTransformBuilder;
  late MockPostgrestTransformBuilderSingle mockTransformBuilderSingle;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    mockTransformBuilder = MockPostgrestTransformBuilder();
    mockTransformBuilderSingle = MockPostgrestTransformBuilderSingle();
    SupabaseClientWrapper.setMockInstance(mockClient);
    repository = PurchaseReturnRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('PurchaseReturnRepository', () {
    test('getAllReturns should return list of returns', () async {
      final mockData = [
        {
          'id': 'ret-1',
          'reference': 'RET-001',
          'purchase': {
            'id': 'pur-1',
            'reference': 'PUR-001',
            'grand_total': 1000.0,
          },
          'total_amount': 500.0,
          'refund_method': 'cash',
          'note': 'Defective items',
          'created_at': '2024-01-15',
        },
      ];

      when(() => mockClient.from('purchase_returns')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending'))).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockData);
      });

      final result = await repository.getAllReturns();

      expect(result.length, 1);
      expect(result[0].id, 'ret-1');
      expect(result[0].reference, 'RET-001');
      expect(result[0].totalAmount, 500.0);
      expect(result[0].refundMethod, 'cash');
    });

    test('getPurchaseByReference should return purchase data', () async {
      final mockData = {
        'id': 'pur-1',
        'reference': 'PUR-001',
        'grand_total': 1000.0,
        'items': [
          {'product_id': 'prod-1', 'quantity': 5, 'price': 100.0},
        ],
      };

      when(() => mockClient.from('purchases')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.ilike('reference', any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.maybeSingle()).thenReturn(mockTransformBuilder);
      when(() => mockTransformBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(Map<String, dynamic>?);
        return callback(mockData);
      });

      final result = await repository.getPurchaseByReference('PUR-001');

      expect(result, isNotNull);
      expect(result!['reference'], 'PUR-001');
      expect(result['grand_total'], 1000.0);
    });

    test('getPurchaseByReference should return null when not found', () async {
      when(() => mockClient.from('purchases')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.ilike('reference', any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.maybeSingle()).thenReturn(mockTransformBuilder);
      when(() => mockTransformBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(Map<String, dynamic>?);
        return callback(null);
      });

      final result = await repository.getPurchaseByReference('NON-EXISTENT');

      expect(result, isNull);
    });

    test('createReturn should complete successfully', () async {
      final returnResponse = {
        'id': 'ret-new',
        'reference': 'RET-NEW',
      };

      when(() => mockClient.from('purchase_returns')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.insert(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.single()).thenReturn(mockTransformBuilderSingle);
      when(() => mockClient.from('purchase_return_items')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.insert(any())).thenReturn(mockFilterBuilder);
      when(() => mockTransformBuilderSingle.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(Map<String, dynamic>);
        return callback(returnResponse);
      });
      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return callback([]);
      });

      await repository.createReturn(
        purchaseId: 'pur-1',
        note: 'Test return',
        refundMethod: 'cash',
        refundAccountId: 'acc-1',
        items: [
          {
            'product_id': 'prod-1',
            'purchase_item_id': 'pi-1',
            'original_quantity': 5,
            'returned_quantity': 2,
            'price': 100.0,
            'subtotal': 200.0,
            'reason': 'Defective',
          },
        ],
      );

      verify(() => mockClient.from('purchase_returns')).called(1);
    });

    test('updateReturn should complete successfully', () async {
      when(() => mockClient.from('purchase_returns')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.update(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('id', 'ret-1')).thenReturn(mockFilterBuilder);

      await repository.updateReturn(
        id: 'ret-1',
        note: 'Updated note',
        refundMethod: 'bank_transfer',
      );

      verify(() => mockClient.from('purchase_returns')).called(1);
    });

    test('deleteReturn should complete successfully', () async {
      when(() => mockClient.from('purchase_returns')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.delete()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('id', 'ret-1')).thenReturn(mockFilterBuilder);

      await repository.deleteReturn('ret-1');

      verify(() => mockClient.from('purchase_returns')).called(1);
    });
  });
}
