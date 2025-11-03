
import '../model/country_model.dart';

abstract class CountryState {}

class CountryInitial extends CountryState {}

// Get All Country
class GetCountriesLoading extends CountryState {}

class GetCountriesSuccess extends CountryState {
  final List<CountryModel> countries;
  GetCountriesSuccess(this.countries);
}

class GetCountriesError extends CountryState {
  final String error;
  GetCountriesError(this.error);
}

// Get Country By ID
class SelectCountryLoading extends CountryState {}

class SelectCountrySuccess extends CountryState {
  String message;
  SelectCountrySuccess(this.message);
}

class SelectCountryError extends CountryState {
  final String error;
  SelectCountryError(this.error);
}

// Create Country
class CreateCountryLoading extends CountryState {}

class CreateCountrySuccess extends CountryState {
  final String message;
  CreateCountrySuccess(this.message);
}

class CreateCountryError extends CountryState {
  final String error;
  CreateCountryError(this.error);
}

// Update Country
class UpdateCountryLoading extends CountryState {}

class UpdateCountrySuccess extends CountryState {
  final String message;
  UpdateCountrySuccess(this.message);
}

class UpdateCountryError extends CountryState {
  final String error;
  UpdateCountryError(this.error);
}

// Delete Country
class DeleteCountryLoading extends CountryState {}

class DeleteCountrySuccess extends CountryState {
  final String message;
  DeleteCountrySuccess(this.message);
}

class DeleteCountryError extends CountryState {
  final String error;
  DeleteCountryError(this.error);
}
