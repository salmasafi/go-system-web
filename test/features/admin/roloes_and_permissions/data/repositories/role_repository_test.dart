import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/roloes_and_permissions/data/repositories/role_repository.dart';
import 'package:GoSystem/features/admin/roloes_and_permissions/model/role_model.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}
class MockPostgrestTransformBuilder extends Mock implements PostgrestTransformBuilder<List<Map<String, dynamic>>> {}

void main() {
  late RoleRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    SupabaseClientWrapper.setMockInstance(mockClient);
    repository = RoleRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('RoleRepository', () {
    test('getAllRoles should return list of roles', () async {
      final mockData = [
        {
          'id': 'role-1',
          'name': 'Admin',
          'status': 'active',
          'permissions': [
            {'module': 'users', 'actions': [{'action': 'view', 'allowed': true}]},
          ],
          'created_at': '2024-01-01',
        },
        {
          'id': 'role-2',
          'name': 'Manager',
          'status': 'active',
          'permissions': [],
          'created_at': '2024-01-02',
        },
      ];

      when(() => mockClient.from('roles')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockData);
      });

      final result = await repository.getAllRoles();

      expect(result.length, 2);
      expect(result[0].id, 'role-1');
      expect(result[0].name, 'Admin');
      expect(result[0].status, 'active');
      expect(result[0].permissions.length, 1);
      expect(result[1].name, 'Manager');
    });

    test('getUserRoles should return roles for specific user', () async {
      final mockData = [
        {
          'roles': {
            'id': 'role-1',
            'name': 'Admin',
            'status': 'active',
            'permissions': [],
            'created_at': '2024-01-01',
          },
        },
      ];

      when(() => mockClient.from('user_roles')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('user_id', 'user-1')).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockData);
      });

      final result = await repository.getUserRoles('user-1');

      expect(result.length, 1);
      expect(result[0].id, 'role-1');
      expect(result[0].name, 'Admin');
    });

    test('createRole should complete successfully', () async {
      when(() => mockClient.from('roles')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.insert(any())).thenReturn(mockFilterBuilder);

      await repository.createRole(
        name: 'New Role',
        status: 'active',
        permissions: [
          Permission(module: 'orders', actions: [ActionModel(id: '1', action: 'view')]),
        ],
      );

      verify(() => mockClient.from('roles')).called(1);
    });

    test('updateRole should complete successfully', () async {
      when(() => mockClient.from('roles')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.update(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('id', 'role-1')).thenReturn(mockFilterBuilder);

      await repository.updateRole(
        id: 'role-1',
        name: 'Updated Role',
        status: 'inactive',
        permissions: [],
      );

      verify(() => mockClient.from('roles')).called(1);
    });

    test('deleteRole should complete successfully', () async {
      when(() => mockClient.from('roles')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.delete()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('id', 'role-1')).thenReturn(mockFilterBuilder);

      await repository.deleteRole('role-1');

      verify(() => mockClient.from('roles')).called(1);
    });
  });
}
