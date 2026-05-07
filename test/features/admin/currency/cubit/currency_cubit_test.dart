import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/currency/cubit/currency_cubit.dart';
import 'package:GoSystem/features/admin/currency/data/repositories/currency_repository.dart';
import 'package:GoSystem/features/admin/currency/model/currency_model.dart';

class MockCurrencyRepository extends Mock implements CurrencyRepository {}

void main() {
  late MockCurrencyRepository mockRepo;

  setUp(() {
    mockRepo = MockCurrencyRepository();
  });

  CurrencyModel sampleCurrency(String id) => CurrencyModel.fromJson({
        'id': id,
        'name': 'Currency $id',
        'code': 'CUR$id',
        'exchange_rate': 1.0,
        'is_default': false,
        'created_at': '2024-01-01',
      });

  group('CurrencyCubit', () {
    blocTest<CurrencyCubit, CurrencyState>(
      'getCurrencies emits loading then success',
      build: () {
        when(() => mockRepo.getCurrencies()).thenAnswer((_) async => [sampleCurrency('c1')]);
        return CurrencyCubit(mockRepo);
      },
      act: (c) => c.getCurrencies(),
      expect: () => [
        isA<GetCurrenciesLoading>(),
        isA<GetCurrenciesSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getCurrencies()).called(1);
      },
    );

    blocTest<CurrencyCubit, CurrencyState>(
      'getCurrencies emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getCurrencies()).thenThrow(Exception('network'));
        return CurrencyCubit(mockRepo);
      },
      act: (c) => c.getCurrencies(),
      expect: () => [
        isA<GetCurrenciesLoading>(),
        isA<GetCurrenciesError>(),
      ],
    );

    blocTest<CurrencyCubit, CurrencyState>(
      'createCurrency emits loading then success',
      build: () {
        when(() => mockRepo.createCurrency(
          name: any(named: 'name'),
          amount: any(named: 'amount'),
          isDefault: any(named: 'isDefault'),
        )).thenAnswer((_) async => {});
        when(() => mockRepo.getCurrencies()).thenAnswer((_) async => [sampleCurrency('c1')]);
        return CurrencyCubit(mockRepo);
      },
      act: (c) => c.createCurrency(
        name: 'New Currency',
        amount: 1.5,
        isDefault: false,
      ),
      expect: () => [
        isA<CreateCurrencyLoading>(),
        isA<CreateCurrencySuccess>(),
        isA<GetCurrenciesLoading>(),
        isA<GetCurrenciesSuccess>(),
      ],
    );
  });
}
