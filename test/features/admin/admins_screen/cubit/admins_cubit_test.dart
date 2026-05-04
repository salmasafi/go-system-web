import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/admins_screen/cubit/admins_cubit.dart';
import 'package:GoSystem/features/admin/admins_screen/data/repositories/admin_repository.dart';
import 'package:GoSystem/features/admin/admins_screen/model/admins_model.dart';

class MockAdminRepository extends Mock implements AdminRepository {}

void main() {
  late MockAdminRepository mockRepo;

  setUp(() {
    mockRepo = MockAdminRepository();
  });

  AdminModel sampleAdmin(String id) => AdminModel.fromJson({
        'id': id,
        'username': 'Admin $id',
        'email': 'admin$id@test.com',
        'phone': '1234567890',
        'role': {'id': 'r1', 'name': 'Admin'},
        'company_name': 'Company',
        'warehouse_id': {'id': 'w1', 'name': 'Warehouse'},
        'status': 'active',
        'created_at': '2024-01-01',
      });

  group('AdminsCubit', () {
    blocTest<AdminsCubit, AdminsState>(
      'getAdmins emits loading then success',
      build: () {
        when(() => mockRepo.getAllAdmins()).thenAnswer((_) async => [sampleAdmin('a1')]);
        return AdminsCubit(mockRepo);
      },
      act: (c) => c.getAdmins(),
      expect: () => [
        isA<GetAdminsLoading>(),
        isA<GetAdminsSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getAllAdmins()).called(1);
      },
    );

    blocTest<AdminsCubit, AdminsState>(
      'getAdmins emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getAllAdmins()).thenThrow(Exception('network'));
        return AdminsCubit(mockRepo);
      },
      act: (c) => c.getAdmins(),
      expect: () => [
        isA<GetAdminsLoading>(),
        isA<GetAdminsError>(),
      ],
    );

    blocTest<AdminsCubit, AdminsState>(
      'getAdminById emits success when found',
      build: () {
        final admin = sampleAdmin('a1');
        when(() => mockRepo.getAdminById('a1')).thenAnswer((_) async => admin);
        return AdminsCubit(mockRepo);
      },
      act: (c) => c.getAdminById('a1'),
      expect: () => [
        isA<GetAdminByIdLoading>(),
        isA<GetAdminByIdSuccess>(),
      ],
    );

    blocTest<AdminsCubit, AdminsState>(
      'getAdminById emits error when not found',
      build: () {
        when(() => mockRepo.getAdminById('x')).thenAnswer((_) async => null);
        return AdminsCubit(mockRepo);
      },
      act: (c) => c.getAdminById('x'),
      expect: () => [
        isA<GetAdminByIdLoading>(),
        isA<GetAdminByIdError>(),
      ],
    );

    blocTest<AdminsCubit, AdminsState>(
      'createAdmin emits loading then success',
      build: () {
        when(() => mockRepo.createAdmin(
          username: any(named: 'username'),
          email: any(named: 'email'),
          phone: any(named: 'phone'),
          password: any(named: 'password'),
          roleId: any(named: 'roleId'),
          warehouseId: any(named: 'warehouseId'),
        )).thenAnswer((_) async => sampleAdmin('new'));
        return AdminsCubit(mockRepo);
      },
      act: (c) => c.createAdmin(
        username: 'newadmin',
        email: 'new@test.com',
        phone: '1234567890',
        password: 'password',
        roleId: 'r1',
      ),
      expect: () => [
        isA<CreateAdminLoading>(),
        isA<CreateAdminSuccess>(),
      ],
    );
  });
}
