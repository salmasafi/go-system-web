import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/reason/data/repositories/reason_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

void main() {
  late ReasonRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    SupabaseClientWrapper.setMockInstance(mockClient);
    repository = ReasonRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('ReasonRepository', () {
    test('getAllReasons maps rows', () async {
      final mockData = [
        {
          'id': 'r1',
          'reason': 'Damaged',
          'created_at': '2024-01-01T00:00:00.000Z',
          'version': 1,
        },
      ];

      when(() => mockClient.from('reasons')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order('reason')).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final cb =
            invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return cb(mockData);
      });

      final result = await repository.getAllReasons();
      expect(result.length, 1);
      expect(result.first.reason, 'Damaged');
    });
  });
}