import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/adjustment/data/repositories/adjustment_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}
class MockPostgrestTransformBuilder extends Mock implements PostgrestTransformBuilder<Map<String, dynamic>?> {}

void main() {
  late AdjustmentRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();

    SupabaseClientWrapper.setMockInstance(mockClient);
    repository = AdjustmentRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('AdjustmentRepository Unit Tests', () {
    test('getAllAdjustments should return list of SupabaseAdjustmentModel', () async {
      final mockData = [
        {
          'id': 'adj-1',
          'reference': 'ADJ-001',
          'warehouse_id': 'wh-1',
          'type': 'increase',
          'reason': 'Initial stock',
          'total_amount': 1000.0,
          'status': 'completed',
          'created_at': '2024-01-01',
          'warehouse': {'id': 'wh-1', 'name': 'Main Warehouse'},
          'items': [],
        },
      ];

      when(() => mockClient.from('adjustments')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending'))).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockData);
      });

      final result = await repository.getAllAdjustments();

      expect(result.length, 1);
      expect(result[0].id, 'adj-1');
      expect(result[0].reference, 'ADJ-001');
    });

    test('reverseAdjustment should return true on success', () async {
      when(() => mockClient.rpc(any(), params: any(named: 'params'))).thenAnswer((_) async => {});

      final result = await repository.reverseAdjustment('adj-1');

      expect(result, true);
    });
  });
}
