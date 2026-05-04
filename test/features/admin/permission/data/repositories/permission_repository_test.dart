import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/permission/data/repositories/permission_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder<Map<String, dynamic>?> {}

void main() {
  late PermissionRepository repository;
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
    repository = PermissionRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('PermissionRepository', () {
    test('getAllPermissions maps rows', () async {
      final mockData = [
        {
          'id': 'p1',
          'name': 'orders.view',
          'roles': <dynamic>[],
          'created_at': '2024-01-01',
          'updated_at': '2024-01-01',
          'version': 1,
        },
      ];

      when(() => mockClient.from('permissions')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final cb =
            invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return cb(mockData);
      });

      final result = await repository.getAllPermissions();
      expect(result.length, 1);
      expect(result.first.name, 'orders.view');
    });

    test('getPermissionById returns model when present', () async {
      final mockData = {
        'id': 'p1',
        'name': 'orders.edit',
        'roles': <dynamic>[],
        'created_at': '2024-01-01',
        'updated_at': '2024-01-01',
        'version': 1,
      };

      when(() => mockClient.from('permissions')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('id', 'p1')).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.maybeSingle()).thenReturn(mockTransformBuilder);
      when(() => mockTransformBuilder.then(any())).thenAnswer((invocation) async {
        final cb =
            invocation.positionalArguments[0] as dynamic Function(Map<String, dynamic>?);
        return cb(mockData);
      });

      final result = await repository.getPermissionById('p1');
      expect(result, isNotNull);
      expect(result!.name, 'orders.edit');
    });
  });
}