import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/dio_helper.dart';
import '../../../../core/services/endpoints.dart';
import '../../../../core/utils/error_handler.dart';
import '../model/country_model.dart';
import 'Country_state.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';

import 'package:GoSystem/features/admin/country/data/repositories/country_repository.dart';

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
      emit(SelectCountrySuccess(LocaleKeys.success_selecting_country.tr()));
    } catch (e) {
      emit(SelectCountryError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createCountry({
    required String name,
  }) async {
    emit(CreateCountryLoading());
    try {
      await _repository.createCountry(name: name);
      emit(CreateCountrySuccess(LocaleKeys.success_creating_country.tr()));
      await getCountries();
    } catch (e) {
      emit(CreateCountryError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateCountry({
    required String countryId,
    required String name,
  }) async {
    emit(UpdateCountryLoading());
    try {
      await _repository.updateCountry(countryId: countryId, name: name);
      emit(UpdateCountrySuccess(LocaleKeys.success_updating_country.tr()));
      await getCountries();
    } catch (e) {
      emit(UpdateCountryError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteCountry(String countryId) async {
    emit(DeleteCountryLoading());
    try {
      await _repository.deleteCountry(countryId);
      emit(DeleteCountrySuccess(LocaleKeys.success_deleting_country.tr()));
      await getCountries();
    } catch (e) {
      emit(DeleteCountryError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

