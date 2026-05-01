import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/city/data/repositories/city_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

void main() {
  late CityRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();

    SupabaseClientWrapper.setMockInstance(mockClient);
    repository = CityRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('CityRepository Unit Tests', () {
    test('getCities should return CityData with cities and countries', () async {
      final mockCities = [
        {
          'id': 'city-1',
          'name': 'Riyadh',
          'ar_name': 'الرياض',
          'country_id': 'country-1',
          'shipping_cost': 25.0,
          'version': 1,
        },
        {
          'id': 'city-2',
          'name': 'Jeddah',
          'ar_name': 'جدة',
          'country_id': 'country-1',
          'shipping_cost': 30.0,
          'version': 1,
        },
      ];

      final mockCountries = [
        {
          'id': 'country-1',
          'name': 'Saudi Arabia',
          'ar_name': 'المملكة العربية السعودية',
          'is_default': true,
          'version': 1,
        },
      ];

      when(() => mockClient.from('cities')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any())).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockCities);
      });

      when(() => mockClient.from('countries')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any())).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockCountries);
      });

      final result = await repository.getCities();

      expect(result.cities.length, 2);
      expect(result.cities[0].name, 'Riyadh');
      expect(result.cities[0].arName, 'الرياض');
      expect(result.cities[0].shipingCost, 25.0);
      expect(result.countries.length, 1);
      expect(result.countries[0].name, 'Saudi Arabia');
    });

    test('createCity should complete successfully', () async {
      when(() => mockClient.from('cities')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.insert(any())).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((_) async {});

      await expectLater(
        repository.createCity(
          name: 'Dammam',
          arName: 'الدمام',
          countryId: 'country-1',
          shipingCost: '20',
        ),
        completes,
      );
    });

    test('updateCity should complete successfully', () async {
      when(() => mockClient.from('cities')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.update(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((_) async {});

      await expectLater(
        repository.updateCity(
          cityId: 'city-1',
          name: 'Riyadh Updated',
          arName: 'الرياض',
          countryId: 'country-1',
          shipingCost: '35',
        ),
        completes,
      );
    });

    test('deleteCity should complete successfully', () async {
      when(() => mockClient.from('cities')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.delete()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((_) async {});

      await expectLater(
        repository.deleteCity('city-1'),
        completes,
      );
    });
  });
}
