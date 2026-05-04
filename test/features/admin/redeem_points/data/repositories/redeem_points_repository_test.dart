import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/redeem_points/data/repositories/redeem_points_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

void main() {
  late RedeemPointsRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    SupabaseClientWrapper.setMockInstance(mockClient);
    repository = RedeemPointsRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('RedeemPointsRepository', () {
    test('getRedeemRules maps rows', () async {
      final mockData = [
        {'id': 'rp1', 'amount': 100.0, 'points': 10},
      ];

      when(() => mockClient.from('redeem_rules')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final cb =
            invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return cb(mockData);
      });

      final result = await repository.getRedeemRules();
      expect(result.length, 1);
      expect(result.first.points, 10);
      expect(result.first.amount, 100.0);
    });
  });
}