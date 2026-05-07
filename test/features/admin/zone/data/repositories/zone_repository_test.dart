import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/zone/data/repositories/zone_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

void main() {
  late ZoneRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();

    SupabaseClientWrapper.setMockInstance(mockClient);
    repository = ZoneRepository();
  });

  tearDown(() {
    SupabaseClientWrapper.dispose();
  });

  group('ZoneRepository Unit Tests', () {
    test('getZones should return list of ZoneModel', () async {
      final mockData = [
        {
          'id': 'zone-1',
          'name': 'North Zone',
          'country_id': 'country-1',
          'city_id': 'city-1',
          'cost': 15.0,
          'version': 1,
        },
        {
          'id': 'zone-2',
          'name': 'South Zone',
          'country_id': 'country-1',
          'city_id': 'city-2',
          'cost': 20.0,
          'version': 1,
        },
      ];

      when(() => mockClient.from('zones')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.order(any())).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as dynamic Function(List<Map<String, dynamic>>);
        return callback(mockData);
      });

      final result = await repository.getZones();

      expect(result.length, 2);
      expect(result[0].id, 'zone-1');
      expect(result[0].name, 'North Zone');
      expect(result[0].cost, 15.0);
      expect(result[1].name, 'South Zone');
    });

    test('createZone should complete successfully', () async {
      when(() => mockClient.from('zones')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.insert(any())).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((_) async {});

      await expectLater(
        repository.createZone(
          name: 'East Zone',
          countryId: 'country-1',
          cityId: 'city-1',
          cost: 25,
        ),
        completes,
      );
    });

    test('updateZone should complete successfully', () async {
      when(() => mockClient.from('zones')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.update(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((_) async {});

      await expectLater(
        repository.updateZone(
          zoneId: 'zone-1',
          name: 'North Zone Updated',
          countryId: 'country-1',
          cityId: 'city-1',
          cost: '30',
        ),
        completes,
      );
    });

    test('deleteZone should complete successfully', () async {
      when(() => mockClient.from('zones')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.delete()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder);

      when(() => mockFilterBuilder.then(any())).thenAnswer((_) async {});

      await expectLater(
        repository.deleteZone('zone-1'),
        completes,
      );
    });
  });
}
