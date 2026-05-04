import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/adjustment/data/repositories/adjustment_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}
class MockPostgrestTransformBuilder extends Mock implements PostgrestTransformBuilder<Map<String, dynamic>?> {}
class MockPostgrestFilterBuilderAny extends Mock implements PostgrestFilterBuilder<dynamic> {}

void main() {
  late AdjustmentRepository repository;
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

      when(() => mockClient.from('adjustments')).thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending'))).thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.then(any())).thenAnswer((_) async => mockData);

      final result = await repository.getAllAdjustments();

      expect(result.length, 1);
      expect(result[0].id, 'adj-1');
      expect(result[0].reference, 'ADJ-001');
    });

    test('reverseAdjustment should return true on success', () async {
      when(() => mockClient.rpc(any(), params: any(named: 'params')))
          .thenReturn(mockRpcBuilder);

      final result = await repository.reverseAdjustment('adj-1');

      expect(result, true);
    });
  });
}
