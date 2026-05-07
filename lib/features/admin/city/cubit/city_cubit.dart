import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/features/admin/country/model/country_model.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import '../model/city_model.dart';
import 'city_state.dart';

import 'package:GoSystem/features/admin/city/data/repositories/city_repository.dart';

class CityCubit extends Cubit<CityState> {
  final CityRepository _repository;
  CityCubit(this._repository) : super(CityInitial());

  static List<CityModel> cities = [];
  static List<CountryModel> countries = [];

  Future<void> getCities() async {
    emit(GetCitiesLoading());
    try {
      final cityData = await _repository.getCities();
      cities = cityData.cities;
      countries = cityData.countries;
      emit(GetCitiesSuccess(cityData));
    } catch (e) {
      emit(GetCitiesError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createCity({
    required String name,
    required String countryId,
    required String shipingCost,
  }) async {
    emit(CreateCityLoading());
    try {
      await _repository.createCity(
        name: name,
        countryId: countryId,
        shipingCost: shipingCost,
      );
      emit(CreateCitySuccess(LocaleKeys.create_city.tr()));
      await getCities();
    } catch (e) {
      emit(CreateCityError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateCity({
    required String cityId,
    required String name,
    required String countryId,
    required String shipingCost,
  }) async {
    emit(UpdateCityLoading());
    try {
      await _repository.updateCity(
        cityId: cityId,
        name: name,
        countryId: countryId,
        shipingCost: shipingCost,
      );
      emit(UpdateCitySuccess(LocaleKeys.update_city.tr()));
      await getCities();
    } catch (e) {
      emit(UpdateCityError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteCity(String cityId) async {
    emit(DeleteCityLoading());
    try {
      await _repository.deleteCity(cityId);
      emit(DeleteCitySuccess(LocaleKeys.delete_city.tr()));
      await getCities();
    } catch (e) {
      emit(DeleteCityError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
