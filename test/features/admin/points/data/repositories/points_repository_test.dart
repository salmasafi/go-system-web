import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/points/data/repositories/points_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

void main() {
  late PointsRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    SupabaseClientWrapper.setMockInstance(mockClient);
    repository = PointsRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('PointsRepository', () {
    test('getPointsRules maps rows', () async {
      final mockData = [
        {'id': 'pt1', 'amount': 100.0, 'points': 10},
      ];

      when(() => mockClient.from('points')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final cb =
            invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return cb(mockData);
      });

      final result = await repository.getPointsRules();
      expect(result.length, 1);
      expect(result.first.points, 10);
    });
  });
}