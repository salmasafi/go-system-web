import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/dio_helper.dart';
import '../../../../core/services/endpoints.dart';
import '../../../../core/utils/error_handler.dart';
import '../model/country_model.dart';
import 'Country_state.dart';

import 'package:systego/features/admin/country/data/repositories/country_repository.dart';

class CountryCubit extends Cubit<CountryState> {
  final CountryRepository _repository;
  CountryCubit(this._repository) : super(CountryInitial());

  List<CountryModel> allCountries = [];

  Future<void> getCountries() async {
    emit(GetCountriesLoading());
    try {
      final countries = await _repository.getCountries();
      allCountries = countries;
      emit(GetCountriesSuccess(countries));
    } catch (e) {
      emit(GetCountriesError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> selectCountry(String countryId, String name) async {
    emit(SelectCountryLoading());
    try {
      await _repository.selectCountry(countryId);
      emit(SelectCountrySuccess('$name is the default country now!'));
    } catch (e) {
      emit(SelectCountryError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createCountry({
    required String name,
    required String arName,
  }) async {
    emit(CreateCountryLoading());
    try {
      await _repository.createCountry(name: name, arName: arName);
      emit(CreateCountrySuccess('Country is created successfully'));
      getCountries();
    } catch (e) {
      emit(CreateCountryError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateCountry({
    required String countryId,
    required String name,
    required String arName,
  }) async {
    emit(UpdateCountryLoading());
    try {
      await _repository.updateCountry(countryId: countryId, name: name, arName: arName);
      emit(UpdateCountrySuccess('Country updated successfully'));
      getCountries();
    } catch (e) {
      emit(UpdateCountryError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteCountry(String countryId) async {
    emit(DeleteCountryLoading());
    try {
      await _repository.deleteCountry(countryId);
      allCountries.removeWhere((country) => country.id == countryId);
      emit(DeleteCountrySuccess('Country deleted successfully'));
    } catch (e) {
      emit(DeleteCountryError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

