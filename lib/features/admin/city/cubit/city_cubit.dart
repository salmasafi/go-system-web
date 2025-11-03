import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/features/admin/country/model/country_model.dart';
import '../../../../core/services/dio_helper.dart';
import '../../../../core/services/endpoints.dart';
import '../../../../core/utils/error_handler.dart';
import '../model/city_model.dart';
import 'city_state.dart';

class CityCubit extends Cubit<CityState> {
  CityCubit() : super(CityInitial());

 static  List<CityModel> cities = [];
  static List<CountryModel> countries = [];

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

  Future<void> getCities() async {
    emit(GetCitiesLoading());
    try {
      final response = await DioHelper.getData(url: EndPoint.getCities);
      log(response.data.toString()); // Safer log with toString()
      if (response.statusCode == 200) {
        final model = CityResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
        if (model.success == true) {
          cities = model.data.cities;
          countries = model.data.countries;
          emit(GetCitiesSuccess(model.data));
        } else {
          final errorMessage = model.data.message;
          emit(GetCitiesError(errorMessage));
        }
      } else {
        final errorMessage = _extractErrorMessage(response);
        emit(GetCitiesError(errorMessage));
      }
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(GetCitiesError(errorMessage));
    }
  }

  // Future<void> selectCity(String cityId, String name) async {
  //   emit(SelectCityLoading());
  //   try {
  //     final response = await DioHelper.putData(
  //       url: EndPoint.selectCity(cityId),
  //       data: {'isDefault': true},
  //     );

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       emit(SelectCitySuccess('$name is the default City now!'));
  //     } else {
  //       final errorMessage = _extractErrorMessage(response);
  //       emit(SelectCityError(errorMessage));
  //     }
  //   } catch (e) {
  //     final errorMessage = _extractErrorMessage(e);
  //     emit(SelectCityError(errorMessage));
  //   }
  // }

  Future<void> createCity({
    required String name,
    required String arName,
    required String countryId,
    required String shipingCost,
  }) async {
    emit(CreateCityLoading());
    try {
      final data = {
        "name": name,
        "ar_name": arName,
        "country": countryId,
        "shipingCost": shipingCost,
      };

      final response = await DioHelper.postData(
        url: EndPoint.createCity,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(CreateCitySuccess('City is created successfully'));
      } else {
        final errorMessage = _extractErrorMessage(response);
        emit(CreateCityError(errorMessage));
      }
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(CreateCityError(errorMessage));
    }
  }

  Future<void> updateCity({
    required String cityId,
    required String name,
    required String arName,
    required String countryId,
    required String shipingCost,
  }) async {
    emit(UpdateCityLoading());
    try {
      final data = <String, dynamic>{
        'name': name,
        "ar_name": arName,
        "country": countryId,
        "shipingCost": shipingCost,
      };

      final response = await DioHelper.putData(
        url: EndPoint.updateCity(cityId),
        data: data,
      );

      if (response.statusCode == 200) {
        emit(UpdateCitySuccess('City updated successfully'));
      } else {
        final errorMessage = _extractErrorMessage(response);
        emit(UpdateCityError(errorMessage));
      }
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(UpdateCityError(errorMessage));
    }
  }

  Future<void> deleteCity(String cityId) async {
    emit(DeleteCityLoading());
    try {
      final response = await DioHelper.deleteData(
        url: EndPoint.deleteCity(cityId),
      );

      if (response.statusCode == 200) {
        cities.removeWhere((city) => city.id == cityId);
        emit(DeleteCitySuccess('City deleted successfully'));
      } else {
        final errorMessage = _extractErrorMessage(response);
        emit(DeleteCityError(errorMessage));
      }
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(DeleteCityError(errorMessage));
    }
  }
}
