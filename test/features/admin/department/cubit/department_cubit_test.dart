import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/department/cubit/department_cubit.dart';
import 'package:GoSystem/features/admin/department/data/repositories/department_repository.dart';
import 'package:GoSystem/features/admin/department/model/department_model.dart';

class MockDepartmentRepository extends Mock implements DepartmentRepository {}

void main() {
  late MockDepartmentRepository mockRepo;

  setUp(() {
    mockRepo = MockDepartmentRepository();
  });

  DepartmentModel sampleDepartment(String id) => DepartmentModel.fromJson({
        'id': id,
        'name': 'Department $id',
        'description': 'Description',
        'created_at': '2024-01-01',
        'updated_at': '2024-01-01',
        '__v': 1,
      });

  group('DepartmentCubit', () {
    blocTest<DepartmentCubit, DepartmentState>(
      'getAllDepartments emits loading then success',
      build: () {
        when(() => mockRepo.getAllDepartments()).thenAnswer((_) async => [sampleDepartment('d1')]);
        return DepartmentCubit(mockRepo);
      },
      act: (c) => c.getAllDepartments(),
      expect: () => [
        isA<GetDepartmentsLoading>(),
        isA<GetDepartmentsSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getAllDepartments()).called(1);
      },
    );

    blocTest<DepartmentCubit, DepartmentState>(
      'getAllDepartments emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getAllDepartments()).thenThrow(Exception('network'));
        return DepartmentCubit(mockRepo);
      },
      act: (c) => c.getAllDepartments(),
      expect: () => [
        isA<GetDepartmentsLoading>(),
        isA<GetDepartmentsError>(),
      ],
    );

    blocTest<DepartmentCubit, DepartmentState>(
      'addDepartment emits loading then success',
      build: () {
        when(() => mockRepo.addDepartment(
          name: any(named: 'name'),
          description: any(named: 'description'),
        )).thenAnswer((_) async => {});
        when(() => mockRepo.getAllDepartments()).thenAnswer((_) async => [sampleDepartment('d1')]);
        return DepartmentCubit(mockRepo);
      },
      act: (c) => c.addDepartment(
        name: 'New Department',
        description: 'Description',
      ),
      expect: () => [
        isA<CreateDepartmentLoading>(),
        isA<CreateDepartmentSuccess>(),
        isA<GetDepartmentsLoading>(),
        isA<GetDepartmentsSuccess>(),
      ],
    );
  });
}
