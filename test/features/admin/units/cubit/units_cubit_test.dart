import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/units/cubit/units_cubit.dart';
import 'package:GoSystem/features/admin/units/data/repositories/unit_repository.dart';
import 'package:GoSystem/features/admin/units/model/unit_model.dart';

class MockUnitRepository extends Mock implements UnitRepository {}

void main() {
  late MockUnitRepository mockRepo;

  setUp(() {
    mockRepo = MockUnitRepository();
  });

  UnitModel sampleUnit(String id) => UnitModel.fromJson({
        'id': id,
        'name': 'Unit $id',
        'code': 'U$id',
        'operator': '*',
        'operator_value': 1.0,
        'status': true,
        'created_at': '2024-01-01',
      });

  group('UnitsCubit', () {
    blocTest<UnitsCubit, UnitsState>(
      'getUnits emits loading then success',
      build: () {
        when(() => mockRepo.getAllUnits()).thenAnswer((_) async => [sampleUnit('u1')]);
        return UnitsCubit(mockRepo);
      },
      act: (c) => c.getUnits(),
      expect: () => [
        isA<GetUnitsLoading>(),
        isA<GetUnitsSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getAllUnits()).called(1);
      },
    );

    blocTest<UnitsCubit, UnitsState>(
      'getUnits emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getAllUnits()).thenThrow(Exception('network'));
        return UnitsCubit(mockRepo);
      },
      act: (c) => c.getUnits(),
      expect: () => [
        isA<GetUnitsLoading>(),
        isA<GetUnitsError>(),
      ],
    );

    blocTest<UnitsCubit, UnitsState>(
      'changeUnitStatus emits loading then success',
      build: () {
        when(() => mockRepo.updateUnitStatus('u1', false)).thenAnswer((_) async => {});
        when(() => mockRepo.getAllUnits()).thenAnswer((_) async => [sampleUnit('u1')]);
        return UnitsCubit(mockRepo);
      },
      act: (c) => c.changeUnitStatus('u1', 'Unit 1', false),
      expect: () => [
        isA<ChangeUnitStatusLoading>(),
        isA<ChangeUnitStatusSuccess>(),
        isA<GetUnitsLoading>(),
        isA<GetUnitsSuccess>(),
      ],
    );
  });
}
