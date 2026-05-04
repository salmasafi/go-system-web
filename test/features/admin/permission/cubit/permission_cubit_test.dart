import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/permission/cubit/permission_cubit.dart';
import 'package:GoSystem/features/admin/permission/data/repositories/permission_repository.dart';
import 'package:GoSystem/features/admin/permission/model/permission_model.dart';

class MockPermissionRepository extends Mock implements PermissionRepository {}

void main() {
  late MockPermissionRepository mockRepo;

  setUp(() {
    mockRepo = MockPermissionRepository();
  });

  PermissionModel samplePermission(String id) => PermissionModel.fromJson({
        'id': id,
        'name': 'Permission $id',
        'roles': [],
        'created_at': '2024-01-01',
        'updated_at': '2024-01-01',
        '__v': 1,
      });

  group('PermissionCubit', () {
    blocTest<PermissionCubit, PermissionState>(
      'getAllPermissions emits loading then success',
      build: () {
        when(() => mockRepo.getAllPermissions()).thenAnswer((_) async => [samplePermission('p1')]);
        return PermissionCubit(mockRepo);
      },
      act: (c) => c.getAllPermissions(),
      expect: () => [
        isA<GetPermissionsLoading>(),
        isA<GetPermissionsSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getAllPermissions()).called(1);
      },
    );

    blocTest<PermissionCubit, PermissionState>(
      'getAllPermissions emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getAllPermissions()).thenThrow(Exception('network'));
        return PermissionCubit(mockRepo);
      },
      act: (c) => c.getAllPermissions(),
      expect: () => [
        isA<GetPermissionsLoading>(),
        isA<GetPermissionsError>(),
      ],
    );

    blocTest<PermissionCubit, PermissionState>(
      'createPermission emits loading then success',
      build: () {
        when(() => mockRepo.createPermission(
          name: any(named: 'name'),
          roles: any(named: 'roles'),
        )).thenAnswer((_) async => {});
        when(() => mockRepo.getAllPermissions()).thenAnswer((_) async => [samplePermission('p1')]);
        return PermissionCubit(mockRepo);
      },
      act: (c) => c.createPermission(
        name: 'New Permission',
        roles: [],
      ),
      expect: () => [
        isA<CreatePermissionLoading>(),
        isA<CreatePermissionSuccess>(),
        isA<GetPermissionsLoading>(),
        isA<GetPermissionsSuccess>(),
      ],
    );
  });
}
