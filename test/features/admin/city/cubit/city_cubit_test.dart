import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/city/cubit/city_cubit.dart';
import 'package:GoSystem/features/admin/city/cubit/city_state.dart';
import 'package:GoSystem/features/admin/city/data/repositories/city_repository.dart';
import 'package:GoSystem/features/admin/city/model/city_model.dart';

class MockCityRepository extends Mock implements CityRepository {}

void main() {
  late MockCityRepository mockRepo;

  setUp(() {
    mockRepo = MockCityRepository();
  });

  CityData sampleCityData() => CityData(
        message: 'Success',
        cities: [CityModel.fromJson({
          'id': 'c1',
          'name': 'City 1',
          'country_id': {'id': 'co1', 'name': 'Country'},
          'shipping_cost': 10.0,
          'created_at': '2024-01-01',
        })],
        countries: [],
      );

  group('CityCubit', () {
    blocTest<CityCubit, CityState>(
      'getCities emits loading then success',
      build: () {
        when(() => mockRepo.getCities()).thenAnswer((_) async => sampleCityData());
        return CityCubit(mockRepo);
      },
      act: (c) => c.getCities(),
      expect: () => [
        isA<GetCitiesLoading>(),
        isA<GetCitiesSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getCities()).called(1);
      },
    );

    blocTest<CityCubit, CityState>(
      'getCities emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getCities()).thenThrow(Exception('network'));
        return CityCubit(mockRepo);
      },
      act: (c) => c.getCities(),
      expect: () => [
        isA<GetCitiesLoading>(),
        isA<GetCitiesError>(),
      ],
    );

    blocTest<CityCubit, CityState>(
      'createCity emits loading then success',
      build: () {
        when(() => mockRepo.createCity(
          name: any(named: 'name'),
          countryId: any(named: 'countryId'),
          shipingCost: any(named: 'shipingCost'),
        )).thenAnswer((_) async => {});
        when(() => mockRepo.getCities()).thenAnswer((_) async => sampleCityData());
        return CityCubit(mockRepo);
      },
      act: (c) => c.createCity(
        name: 'New City',
        countryId: 'co1',
        shipingCost: '15',
      ),
      expect: () => [
        isA<CreateCityLoading>(),
        isA<CreateCitySuccess>(),
        isA<GetCitiesLoading>(),
        isA<GetCitiesSuccess>(),
      ],
    );
  });
}
