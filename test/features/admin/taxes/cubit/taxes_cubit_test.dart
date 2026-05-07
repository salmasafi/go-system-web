import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/taxes/cubit/taxes_cubit.dart';
import 'package:GoSystem/features/admin/taxes/data/repositories/tax_repository.dart';
import 'package:GoSystem/features/admin/taxes/model/taxes_model.dart';

class MockTaxRepository extends Mock implements TaxRepository {}

TaxModel sampleTax(String id) => TaxModel.fromJson({
      '_id': id,
      'name': 'Tax $id',
      'amount': 15.0,
      'type': 'percentage',
      'status': true,
      'createdAt': '2024-01-01',
      'updatedAt': '2024-01-01',
      '__v': 1,
    });

void main() {
  late MockTaxRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(sampleTax('fallback'));
  });

  setUp(() {
    mockRepo = MockTaxRepository();
  });

  group('TaxesCubit', () {
    blocTest<TaxesCubit, TaxesState>(
      'getTaxes emits loading then success',
      build: () {
        when(() => mockRepo.getAllTaxes()).thenAnswer((_) async => [sampleTax('t1')]);
        return TaxesCubit(mockRepo);
      },
      act: (c) => c.getTaxes(),
      expect: () => [
        isA<GetTaxesLoading>(),
        isA<GetTaxesSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getAllTaxes()).called(1);
      },
    );

    blocTest<TaxesCubit, TaxesState>(
      'getTaxes emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getAllTaxes()).thenThrow(Exception('network'));
        return TaxesCubit(mockRepo);
      },
      act: (c) => c.getTaxes(),
      expect: () => [
        isA<GetTaxesLoading>(),
        isA<GetTaxesError>(),
      ],
    );

    blocTest<TaxesCubit, TaxesState>(
      'createTax emits loading then success',
      build: () {
        when(() => mockRepo.createTax(any())).thenAnswer((_) async => sampleTax('new'));
        return TaxesCubit(mockRepo);
      },
      act: (c) => c.createTax(
        name: 'New Tax',
        amount: 10.0,
        taxType: 'percentage',
      ),
      expect: () => [
        isA<CreateTaxLoading>(),
        isA<CreateTaxSuccess>(),
      ],
    );
  });
}
