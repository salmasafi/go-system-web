import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/warehouses/cubit/warehouse_cubit.dart';
import 'package:GoSystem/features/admin/warehouses/cubit/warehouse_state.dart';
import 'package:GoSystem/features/admin/warehouses/data/repositories/warehouse_repository.dart';
import 'package:GoSystem/features/admin/warehouses/model/ware_house_model.dart';

class MockWarehouseRepository extends Mock implements WarehouseRepository {}

void main() {
  late MockWarehouseRepository mockRepo;

  setUp(() {
    mockRepo = MockWarehouseRepository();
  });

  Warehouses sampleWarehouse(String id) => Warehouses.fromJson({
        'id': id,
        'name': 'Warehouse $id',
        'address': 'Address $id',
        'phone': '1234567890',
        'email': 'warehouse$id@test.com',
        'created_at': '2024-01-01',
      });

  group('WareHouseCubit', () {
    blocTest<WareHouseCubit, WarehousesState>(
      'getWarehouses emits loading then success',
      build: () {
        when(() => mockRepo.getAllWarehouses()).thenAnswer((_) async => [sampleWarehouse('w1')]);
        return WareHouseCubit(mockRepo);
      },
      act: (c) => c.getWarehouses(),
      expect: () => [
        isA<WarehousesLoading>(),
        isA<WarehousesLoaded>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getAllWarehouses()).called(1);
      },
    );

    blocTest<WareHouseCubit, WarehousesState>(
      'getWarehouses emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getAllWarehouses()).thenThrow(Exception('network'));
        return WareHouseCubit(mockRepo);
      },
      act: (c) => c.getWarehouses(),
      expect: () => [
        isA<WarehousesLoading>(),
        isA<WarehousesError>(),
      ],
    );

    blocTest<WareHouseCubit, WarehousesState>(
      'createWarehouse emits loading then success',
      build: () {
        when(() => mockRepo.createWarehouse(
          name: any(named: 'name'),
          address: any(named: 'address'),
          phone: any(named: 'phone'),
          email: any(named: 'email'),
        )).thenAnswer((_) async => sampleWarehouse('new'));
        when(() => mockRepo.getAllWarehouses()).thenAnswer((_) async => [sampleWarehouse('w1')]);
        return WareHouseCubit(mockRepo);
      },
      act: (c) => c.createWarehouse(
        name: 'New Warehouse',
        address: 'New Address',
        phone: '1234567890',
        email: 'new@test.com',
      ),
      expect: () => [
        isA<WarehouseCreating>(),
        isA<WarehouseCreated>(),
        isA<WarehousesLoading>(),
        isA<WarehousesLoaded>(),
      ],
    );
  });
}
