import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/dio_helper.dart';
import '../../../../core/services/endpoints.dart';
import '../../../../core/utils/error_handler.dart';
import '../model/zone_model.dart';
import 'zone_state.dart';

import 'package:GoSystem/features/admin/zone/data/repositories/zone_repository.dart';

class ZoneCubit extends Cubit<ZoneState> {
  final ZoneRepository _repository;
  ZoneCubit(this._repository) : super(ZoneInitial());

  List<ZoneModel> allZones = [];

  Future<void> getZones() async {
    emit(GetZonesLoading());
    try {
      final zones = await _repository.getZones();
      allZones = zones;
      emit(GetZonesSuccess(zones));
    } catch (e) {
      emit(GetZonesError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createZone({
    required String name,
    required String arName,
    required String countryId,
    required String cityId,
    required num cost,
  }) async {
    emit(CreateZoneLoading());
    try {
      await _repository.createZone(
        name: name,
        arName: arName,
        countryId: countryId,
        cityId: cityId,
        cost: cost,
      );
      emit(CreateZoneSuccess('Zone is created successfully'));
      getZones();
    } catch (e) {
      emit(CreateZoneError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateZone({
    required String zoneId,
    required String name,
    required String arName,
    required String countryId,
    required String cityId,
    required String cost,
  }) async {
    emit(UpdateZoneLoading());
    try {
      await _repository.updateZone(
        zoneId: zoneId,
        name: name,
        arName: arName,
        countryId: countryId,
        cityId: cityId,
        cost: cost,
      );
      emit(UpdateZoneSuccess('Zone updated successfully'));
      getZones();
    } catch (e) {
      emit(UpdateZoneError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteZone(String zoneId) async {
    emit(DeleteZoneLoading());
    try {
      await _repository.deleteZone(zoneId);
      allZones.removeWhere((zone) => zone.id == zoneId);
      emit(DeleteZoneSuccess('Zone deleted successfully'));
    } catch (e) {
      emit(DeleteZoneError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

