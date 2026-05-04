import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/suppliers/cubit/supplier_cubit.dart';
import 'package:GoSystem/features/admin/suppliers/cubit/supplier_state.dart';
import 'package:GoSystem/features/admin/suppliers/data/repositories/supplier_repository.dart';
import 'package:GoSystem/features/admin/suppliers/model/supplier_model.dart';

class MockSupplierRepository extends Mock implements SupplierRepository {}

void main() {
  late MockSupplierRepository mockRepo;

  setUp(() {
    mockRepo = MockSupplierRepository();
  });

  Suppliers sampleSupplier(String id) => Suppliers.fromJson({
        'id': id,
        'username': 'Supplier $id',
        'email': 'supplier$id@test.com',
        'phone_number': '1234567890',
        'address': 'Address',
        'company_name': 'Company $id',
        'image': 'image.jpg',
        'city_id': {'id': 'c1', 'name': 'City'},
        'country_id': {'id': 'co1', 'name': 'Country'},
        '__v': 1,
      });

  group('SupplierCubit', () {
    blocTest<SupplierCubit, SupplierStates>(
      'getSuppliers emits loading then success',
      build: () {
        when(() => mockRepo.getAllSuppliers()).thenAnswer((_) async => [sampleSupplier('s1')]);
        return SupplierCubit(mockRepo);
      },
      act: (c) => c.getSuppliers(),
      expect: () => [
        isA<SupplierLoading>(),
        isA<SupplierSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getAllSuppliers()).called(1);
      },
    );

    blocTest<SupplierCubit, SupplierStates>(
      'getSuppliers emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getAllSuppliers()).thenThrow(Exception('network'));
        return SupplierCubit(mockRepo);
      },
      act: (c) => c.getSuppliers(),
      expect: () => [
        isA<SupplierLoading>(),
        isA<SupplierError>(),
      ],
    );

    blocTest<SupplierCubit, SupplierStates>(
      'getSupplierById emits success when found',
      build: () {
        final supplier = sampleSupplier('s1');
        when(() => mockRepo.getSupplierById('s1')).thenAnswer((_) async => supplier);
        return SupplierCubit(mockRepo);
      },
      act: (c) => c.getSupplierById('s1'),
      expect: () => [
        isA<SupplierLoading>(),
        isA<SupplierSuccess>(),
      ],
    );

    blocTest<SupplierCubit, SupplierStates>(
      'getSupplierById emits error when not found',
      build: () {
        when(() => mockRepo.getSupplierById('x')).thenAnswer((_) async => null);
        return SupplierCubit(mockRepo);
      },
      act: (c) => c.getSupplierById('x'),
      expect: () => [
        isA<SupplierLoading>(),
        isA<SupplierError>(),
      ],
    );
  });
}
