import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/roloes_and_permissions/cubit/roles_cubit.dart';
import 'package:GoSystem/features/admin/roloes_and_permissions/data/repositories/role_repository.dart';
import 'package:GoSystem/features/admin/roloes_and_permissions/model/role_model.dart';

class MockRoleRepository extends Mock implements RoleRepository {}

void main() {
  late MockRoleRepository mockRepo;

  setUp(() {
    mockRepo = MockRoleRepository();
  });

  RoleModel sampleRole(String id) => RoleModel.fromJson({
        'id': id,
        'name': 'Role $id',
        'status': 'active',
        'permissions': [],
        'created_at': '2024-01-01',
      });

  group('RolesCubit', () {
    blocTest<RolesCubit, RolesState>(
      'getAllRoles emits loading then success',
      build: () {
        when(() => mockRepo.getAllRoles()).thenAnswer((_) async => [sampleRole('r1')]);
        return RolesCubit(mockRepo);
      },
      act: (c) => c.getAllRoles(),
      expect: () => [
        isA<RolesLoading>(),
        isA<RolesLoaded>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getAllRoles()).called(1);
      },
    );

    blocTest<RolesCubit, RolesState>(
      'getAllRoles emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getAllRoles()).thenThrow(Exception('network'));
        return RolesCubit(mockRepo);
      },
      act: (c) => c.getAllRoles(),
      expect: () => [
        isA<RolesLoading>(),
        isA<RolesError>(),
      ],
    );

    blocTest<RolesCubit, RolesState>(
      'getUserRoles emits loading then success',
      build: () {
        when(() => mockRepo.getUserRoles('user1')).thenAnswer((_) async => [sampleRole('r1')]);
        return RolesCubit(mockRepo);
      },
      act: (c) => c.getUserRoles('user1'),
      expect: () => [
        isA<RolesLoading>(),
        isA<RolesLoaded>(),
      ],
    );

    blocTest<RolesCubit, RolesState>(
      'createRole emits loading then success',
      build: () {
        when(() => mockRepo.createRole(
          name: any(named: 'name'),
          status: any(named: 'status'),
          permissions: any(named: 'permissions'),
        )).thenAnswer((_) async => {});
        when(() => mockRepo.getAllRoles()).thenAnswer((_) async => [sampleRole('r1')]);
        return RolesCubit(mockRepo);
      },
      act: (c) => c.createRole(name: 'New Role', status: 'active', permissions: []),
      expect: () => [
        isA<RolesCreating>(),
        isA<RolesCreateSuccess>(),
        isA<RolesLoading>(),
        isA<RolesLoaded>(),
      ],
    );
  });
}
