import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/dio_helper.dart';
import '../../../core/services/endpoints.dart';
import '../../../core/utils/error_handler.dart';
import '../model/country_model.dart';
import 'Country_state.dart';

class CountryCubit extends Cubit<CountryState> {
  CountryCubit() : super(CountryInitial());

  List<CountryModel> allCountries = [];

  Future<void> getCountries() async {
    emit(GetCountriesLoading());
    try {
      final response = await DioHelper.getData(url: EndPoint.getCountries);

      if (response.statusCode == 200) {
        final model = CountryResponse.fromJson(response.data);
        if (model.success == true && model.data.countries.isNotEmpty) {
          emit(GetCountriesSuccess(model.data.countries));
        } else {
          final errorMessage = ErrorHandler.handleError(response);
          emit(GetCountriesError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(GetCountriesError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(GetCountriesError(errorMessage));
    }
  }

  Future<void> selectCountry(String countryId, String name) async {
    emit(SelectCountryLoading());
    try {
      final response = await DioHelper.putData(
        url: EndPoint.selectCountry(countryId),
        data: {'isDefault': true},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(SelectCountrySuccess('$name is the default country now!'));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(SelectCountryError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(SelectCountryError(errorMessage));
    }
  }

  Future<void> createCountry({required String name}) async {
    emit(CreateCountryLoading());
    try {
      final data = {'name': name};

      final response = await DioHelper.postData(
        url: EndPoint.createCountry,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(CreateCountrySuccess('Country is created successfully'));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(CreateCountryError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(CreateCountryError(errorMessage));
    }
  }

  Future<void> updateCountry({
    required String countryId,
    required String name,
  }) async {
    emit(UpdateCountryLoading());
    try {
      final data = <String, dynamic>{'name': name};

      final response = await DioHelper.putData(
        url: EndPoint.updateCountry(countryId),
        data: data,
      );

      if (response.statusCode == 200) {
        emit(UpdateCountrySuccess('Country updated successfully'));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(UpdateCountryError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(UpdateCountryError(errorMessage));
    }
  }

  Future<void> deleteCountry(String countryId) async {
    emit(DeleteCountryLoading());
    try {
      final response = await DioHelper.deleteData(
        url: EndPoint.deleteCountry(countryId),
      );

      if (response.statusCode == 200) {
        allCountries.removeWhere((country) => country.id == countryId);
        emit(DeleteCountrySuccess('Country deleted successfully'));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(DeleteCountryError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(DeleteCountryError(errorMessage));
    }
  }
}
