import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/cashier/cubit/cashier_cubit.dart';
import 'package:GoSystem/features/admin/cashier/data/repositories/cashier_repository.dart';
import 'package:GoSystem/features/admin/cashier/model/cashirer_model.dart';

class MockCashierRepository extends Mock implements CashierRepository {}

void main() {
  late MockCashierRepository mockRepo;

  setUp(() {
    mockRepo = MockCashierRepository();
  });

  CashierModel sampleCashier(String id) => CashierModel.fromJson({
        'id': id,
        'name': 'Cashier $id',
        'warehouse': {'id': 'w1', 'name': 'Main Warehouse'},
        'status': true,
        'cashier_active': true,
        'created_at': '2024-01-01',
        'updated_at': '2024-01-01',
      });

  group('CashierCubit', () {
    blocTest<CashierCubit, CashierState>(
      'getCashiers emits loading then success',
      build: () {
        when(() => mockRepo.getAllCashiers()).thenAnswer((_) async => [sampleCashier('c1')]);
        return CashierCubit(mockRepo);
      },
      act: (c) => c.getCashiers(),
      expect: () => [
        isA<GetCashiersLoading>(),
        isA<GetCashiersSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getAllCashiers()).called(1);
      },
    );

    blocTest<CashierCubit, CashierState>(
      'getCashiers emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getAllCashiers()).thenThrow(Exception('network'));
        return CashierCubit(mockRepo);
      },
      act: (c) => c.getCashiers(),
      expect: () => [
        isA<GetCashiersLoading>(),
        isA<GetCashiersError>(),
      ],
    );

    blocTest<CashierCubit, CashierState>(
      'createCashier emits loading then success',
      build: () {
        when(() => mockRepo.createCashier(
          name: any(named: 'name'),
          warehouseId: any(named: 'warehouseId'),
          status: any(named: 'status'),
        )).thenAnswer((_) async => {});
        when(() => mockRepo.getAllCashiers()).thenAnswer((_) async => [sampleCashier('c1')]);
        return CashierCubit(mockRepo);
      },
      act: (c) => c.createCashier(
        name: 'New Cashier',
        warehouseId: 'w1',
        status: true,
      ),
      expect: () => [
        isA<CreateCashierLoading>(),
        isA<CreateCashierSuccess>(),
        isA<GetCashiersLoading>(),
        isA<GetCashiersSuccess>(),
      ],
    );

    blocTest<CashierCubit, CashierState>(
      'updateCashier emits loading then success',
      build: () {
        when(() => mockRepo.updateCashier(
          id: any(named: 'id'),
          name: any(named: 'name'),
          warehouseId: any(named: 'warehouseId'),
          status: any(named: 'status'),
        )).thenAnswer((_) async => {});
        when(() => mockRepo.getAllCashiers()).thenAnswer((_) async => [sampleCashier('c1')]);
        return CashierCubit(mockRepo);
      },
      act: (c) => c.updateCashier(
        cashierId: 'c1',
        name: 'Updated Cashier',
        warehouseId: 'w1',
        status: true,
      ),
      expect: () => [
        isA<UpdateCashierLoading>(),
        isA<UpdateCashierSuccess>(),
        isA<GetCashiersLoading>(),
        isA<GetCashiersSuccess>(),
      ],
    );

    blocTest<CashierCubit, CashierState>(
      'deleteCashier emits loading then success',
      build: () {
        when(() => mockRepo.deleteCashier('c1')).thenAnswer((_) async => {});
        return CashierCubit(mockRepo);
      },
      act: (c) => c.deleteCashier('c1'),
      expect: () => [
        isA<DeleteCashierLoading>(),
        isA<DeleteCashierSuccess>(),
      ],
    );
  });
}
