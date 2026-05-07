import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/country/cubit/country_cubit.dart';
import 'package:GoSystem/features/admin/country/cubit/Country_state.dart';
import 'package:GoSystem/features/admin/country/data/repositories/country_repository.dart';
import 'package:GoSystem/features/admin/country/model/country_model.dart';

class MockCountryRepository extends Mock implements CountryRepository {}

void main() {
  late MockCountryRepository mockRepo;

  setUp(() {
    mockRepo = MockCountryRepository();
  });

  CountryModel sampleCountry(String id) => CountryModel.fromJson({
        'id': id,
        'name': 'Country $id',
        'code': 'C$id',
        'is_default': false,
        'created_at': '2024-01-01',
      });

  group('CountryCubit', () {
    blocTest<CountryCubit, CountryState>(
      'getCountries emits loading then success',
      build: () {
        when(() => mockRepo.getCountries()).thenAnswer((_) async => [sampleCountry('c1')]);
        return CountryCubit(mockRepo);
      },
      act: (c) => c.getCountries(),
      expect: () => [
        isA<GetCountriesLoading>(),
        isA<GetCountriesSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getCountries()).called(1);
      },
    );

    blocTest<CountryCubit, CountryState>(
      'getCountries emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getCountries()).thenThrow(Exception('network'));
        return CountryCubit(mockRepo);
      },
      act: (c) => c.getCountries(),
      expect: () => [
        isA<GetCountriesLoading>(),
        isA<GetCountriesError>(),
      ],
    );

    blocTest<CountryCubit, CountryState>(
      'selectCountry emits loading then success',
      build: () {
        when(() => mockRepo.selectCountry('c1')).thenAnswer((_) async => {});
        return CountryCubit(mockRepo);
      },
      act: (c) => c.selectCountry('c1', 'Test Country'),
      expect: () => [
        isA<SelectCountryLoading>(),
        isA<SelectCountrySuccess>(),
      ],
    );

    blocTest<CountryCubit, CountryState>(
      'createCountry emits loading then success',
      build: () {
        when(() => mockRepo.createCountry(name: any(named: 'name')))
            .thenAnswer((_) async => {});
        when(() => mockRepo.getCountries()).thenAnswer((_) async => [sampleCountry('c1')]);
        return CountryCubit(mockRepo);
      },
      act: (c) => c.createCountry(name: 'New Country'),
      expect: () => [
        isA<CreateCountryLoading>(),
        isA<CreateCountrySuccess>(),
        isA<GetCountriesLoading>(),
        isA<GetCountriesSuccess>(),
      ],
    );
  });
}
