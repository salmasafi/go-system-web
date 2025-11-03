import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/dio_helper.dart';
import '../../../../core/services/endpoints.dart';
import '../../../../core/utils/error_handler.dart';
import '../model/zone_model.dart';
import 'zone_state.dart';

class ZoneCubit extends Cubit<ZoneState> {
  ZoneCubit() : super(ZoneInitial());

  List<ZoneModel> allZones = [];

  String _extractErrorMessage(dynamic errorOrResponse) {
    // Helper to safely extract message, bypassing ErrorHandler issues
    if (errorOrResponse is Map<String, dynamic>) {
      return errorOrResponse['message']?.toString() ?? 'Unknown error occurred';
    } else if (errorOrResponse is Response) {
      final data = errorOrResponse.data;
      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ??
            'Server error: ${errorOrResponse.statusCode}';
      }
      return 'Server error: ${errorOrResponse.statusCode}';
    }
    // Fallback to ErrorHandler for non-Dio errors (e.g., network issues)
    return ErrorHandler.handleError(errorOrResponse);
  }

  Future<void> getZones() async {
    emit(GetZonesLoading());
    try {
      final response = await DioHelper.getData(url: EndPoint.getZones);
      log(response.data.toString()); 
      if (response.statusCode == 200) {
        final model = ZoneResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
        if (model.success == true) {
          allZones = model.data.zones;
          emit(GetZonesSuccess(allZones));
        } else {
          final errorMessage = model.data.message;
          emit(GetZonesError(errorMessage));
        }
      } else {
        final errorMessage = _extractErrorMessage(response);
        emit(GetZonesError(errorMessage));
      }
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(GetZonesError(errorMessage));
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
      final data = {
        "name": name,
        "ar_name": arName,
        "countryId": countryId,
        "cityId": cityId,
        "cost": cost,
      };

      final response = await DioHelper.postData(
        url: EndPoint.createZone,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(CreateZoneSuccess('Zone is created successfully'));
      } else {
        final errorMessage = _extractErrorMessage(response);
        emit(CreateZoneError(errorMessage));
      }
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(CreateZoneError(errorMessage));
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
      final data = <String, dynamic>{
        'name': name,
        "ar_name": arName,
        "countryId": countryId,
        "cityId": cityId,
        "cost": cost,
      };

      final response = await DioHelper.putData(
        url: EndPoint.updateZone(zoneId),
        data: data,
      );

      if (response.statusCode == 200) {
        emit(UpdateZoneSuccess('Zone updated successfully'));
      } else {
        final errorMessage = _extractErrorMessage(response);
        emit(UpdateZoneError(errorMessage));
      }
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(UpdateZoneError(errorMessage));
    }
  }

  Future<void> deleteZone(String zoneId) async {
    emit(DeleteZoneLoading());
    try {
      final response = await DioHelper.deleteData(
        url: EndPoint.deleteZone(zoneId),
      );

      if (response.statusCode == 200) {
        allZones.removeWhere((zone) => zone.id == zoneId);
        emit(DeleteZoneSuccess('Zone deleted successfully'));
      } else {
        final errorMessage = _extractErrorMessage(response);
        emit(DeleteZoneError(errorMessage));
      }
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(DeleteZoneError(errorMessage));
    }
  }
}