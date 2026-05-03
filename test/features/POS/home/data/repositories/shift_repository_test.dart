import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/pos/shift/data/repositories/shift_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder<PostgrestMap> {}

void main() {
  late ShiftRepository repository;
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
    repository = ShiftRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('ShiftRepository Supabase Implementation Tests', () {
    test('getActiveShift maps Supabase JSON correctly', () async {
      final mockData = {
        'id': 'shift-123',
        'admin_id': 'admin-1',
        'warehouse_id': 'wh-1',
        'start_time': '2024-05-01T08:00:00Z',
        'opening_balance': 500.0,
        'status': 'open',
      };

      when(() => mockClient.from('shifts')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(
        () => mockFilterBuilder.eq('status', 'open'),
      ).thenReturn(mockFilterBuilder);
      when(
        () => mockFilterBuilder.maybeSingle(),
      ).thenReturn(mockTransformBuilder);

      when(() => mockTransformBuilder.then(any())).thenAnswer((
        invocation,
      ) async {
        final callback =
            invocation.positionalArguments[0]
                as dynamic Function(Map<String, dynamic>?);
        return callback(mockData);
      });

      final result = await repository.getActiveShift();

      expect(result, isNotNull);
      expect(result!.id, 'shift-123');
      expect(result.status, 'open');
    });
  });
}
