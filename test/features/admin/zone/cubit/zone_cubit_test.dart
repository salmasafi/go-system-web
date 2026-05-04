import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:GoSystem/features/admin/zone/cubit/zone_cubit.dart';
import 'package:GoSystem/features/admin/zone/cubit/zone_state.dart';
import 'package:GoSystem/features/admin/zone/data/repositories/zone_repository.dart';
import 'package:GoSystem/features/admin/zone/model/zone_model.dart';

class MockZoneRepository extends Mock implements ZoneRepository {}

void main() {
  late MockZoneRepository mockRepo;

  setUp(() {
    mockRepo = MockZoneRepository();
  });

  ZoneModel sampleZone(String id) => ZoneModel.fromJson({
        'id': id,
        'name': 'Zone $id',
        'ar_name': 'منطقة $id',
        'country_id': {'id': 'c1', 'name': 'Country'},
        'city_id': {'id': 'c2', 'name': 'City'},
        'cost': 50.0,
        'created_at': '2024-01-01',
      });

  group('ZoneCubit', () {
    blocTest<ZoneCubit, ZoneState>(
      'getZones emits loading then success',
      build: () {
        when(() => mockRepo.getZones()).thenAnswer((_) async => [sampleZone('z1')]);
        return ZoneCubit(mockRepo);
      },
      act: (c) => c.getZones(),
      expect: () => [
        isA<GetZonesLoading>(),
        isA<GetZonesSuccess>(),
      ],
      verify: (_) {
        verify(() => mockRepo.getZones()).called(1);
      },
    );

    blocTest<ZoneCubit, ZoneState>(
      'getZones emits loading then error when repository throws',
      build: () {
        when(() => mockRepo.getZones()).thenThrow(Exception('network'));
        return ZoneCubit(mockRepo);
      },
      act: (c) => c.getZones(),
      expect: () => [
        isA<GetZonesLoading>(),
        isA<GetZonesError>(),
      ],
    );

    blocTest<ZoneCubit, ZoneState>(
      'createZone emits loading then success',
      build: () {
        when(() => mockRepo.createZone(
          name: any(named: 'name'),
          arName: any(named: 'arName'),
          countryId: any(named: 'countryId'),
          cityId: any(named: 'cityId'),
          cost: any(named: 'cost'),
        )).thenAnswer((_) async => {});
        when(() => mockRepo.getZones()).thenAnswer((_) async => [sampleZone('z1')]);
        return ZoneCubit(mockRepo);
      },
      act: (c) => c.createZone(
        name: 'New Zone',
        arName: 'منطقة جديدة',
        countryId: 'c1',
        cityId: 'c2',
        cost: 50.0,
      ),
      expect: () => [
        isA<CreateZoneLoading>(),
        isA<CreateZoneSuccess>(),
        isA<GetZonesLoading>(),
        isA<GetZonesSuccess>(),
      ],
    );
  });
}
