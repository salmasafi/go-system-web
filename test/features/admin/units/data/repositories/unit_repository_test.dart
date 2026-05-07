import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:GoSystem/features/admin/units/data/repositories/unit_repository.dart';
import 'package:GoSystem/features/admin/units/model/unit_model.dart';

class MockUnitRepository extends Mock implements UnitRepository {}

void main() {
  group('UnitRepository Interface Tests', () {
    late MockUnitRepository mockRepository;

    setUp(() {
      mockRepository = MockUnitRepository();
    });

    test('getAllUnits should return a list of UnitModel', () async {
      // Arrange
      final List<UnitModel> expectedUnits = [
        UnitModel(
          id: '1',
          code: 'pcs',
          name: 'Piece',
          operator: '*',
          operatorValue: 1.0,
          status: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          version: 1,
        ),
      ];
      
      when(() => mockRepository.getAllUnits()).thenAnswer((_) async => expectedUnits);

      // Act
      final result = await mockRepository.getAllUnits();

      // Assert
      expect(result, equals(expectedUnits));
      verify(() => mockRepository.getAllUnits()).called(1);
    });

    test('createUnit should be called with correct parameters', () async {
      // Arrange
      when(() => mockRepository.createUnit(
        name: any(named: 'name'),
        code: any(named: 'code'),
      )).thenAnswer((_) async => {});

      // Act
      await mockRepository.createUnit(
        name: 'Kilogram',
        code: 'kg',
      );

      // Assert
      verify(() => mockRepository.createUnit(
        name: 'Kilogram',
        code: 'kg',
      )).called(1);
    });
  });
}
