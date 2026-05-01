import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/country/data/repositories/country_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

void main() {
  late CountryRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();

    SupabaseClientWrapper.setMockInstance(mockClient);
    repository = CountryRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('CountryRepository Unit Tests', () {
    test('getCountries should return list of CountryModel', () async {
      final mockData = [
        {
          'id': 'country-1',
          'name': 'Saudi Arabia',
          'ar_name': 'المملكة العربية السعودية',
          'is_default': true,
          'version': 1,
        },
        {
          'id': 'country-2',
          'name': 'United Arab Emirates',
          'ar_name': 'الإمارات العربية المتحدة',
          'is_default': false,
          'version': 1,
        },
      ];

      when(() => mockClient.from('countries')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any())).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockData);
      });

      final result = await repository.getCountries();

      expect(result.length, 2);
      expect(result[0].id, 'country-1');
      expect(result[0].name, 'Saudi Arabia');
      expect(result[0].arName, 'المملكة العربية السعودية');
      expect(result[0].isDefault, true);
      expect(result[1].name, 'United Arab Emirates');
    });

    test('createCountry should complete successfully', () async {
      when(() => mockClient.from('countries')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.insert(any())).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((_) async {});

      await expectLater(
        repository.createCountry(name: 'Kuwait', arName: 'الكويت'),
        completes,
      );
    });

    test('updateCountry should complete successfully', () async {
      when(() => mockClient.from('countries')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.update(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((_) async {});

      await expectLater(
        repository.updateCountry(countryId: 'country-1', name: 'KSA', arName: 'السعودية'),
        completes,
      );
    });

    test('deleteCountry should complete successfully', () async {
      when(() => mockClient.from('countries')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.delete()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((_) async {});

      await expectLater(
        repository.deleteCountry('country-1'),
        completes,
      );
    });
  });
}
