import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/taxes/cubit/taxes_cubit.dart';
import 'package:GoSystem/features/admin/taxes/data/repositories/tax_repository.dart';
import 'package:GoSystem/features/admin/taxes/model/taxes_model.dart';

class MockTaxRepository extends Mock implements TaxRepository {}

void main() {
  late MockTaxRepository mockRepo;

  setUp(() {
    mockRepo = MockTaxRepository();
  });

  TaxModel sampleTax(String id) => TaxModel.fromJson({
        'id': id,
        'name': 'Tax $id',
        'ar_name': 'ضريبة $id',
        'amount': 15.0,
        'type': 'percentage',
        'status': true,
        'created_at': '2024-01-01',
        'updated_at': '2024-01-01',
        '__v': 1,
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
        arName: 'ضريبة جديدة',
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
