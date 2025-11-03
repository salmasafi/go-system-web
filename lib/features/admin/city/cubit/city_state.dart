import '../model/city_model.dart';

abstract class CityState {}

class CityInitial extends CityState {}

// Get All City
class GetCitiesLoading extends CityState {}

class GetCitiesSuccess extends CityState {
  final CityData cityData;
  GetCitiesSuccess(this.cityData);
}

class GetCitiesError extends CityState {
  final String error;
  GetCitiesError(this.error);
}

// Get City By ID
class SelectCityLoading extends CityState {}

class SelectCitySuccess extends CityState {
  String message;
  SelectCitySuccess(this.message);
}

class SelectCityError extends CityState {
  final String error;
  SelectCityError(this.error);
}

// Create City
class CreateCityLoading extends CityState {}

class CreateCitySuccess extends CityState {
  final String message;
  CreateCitySuccess(this.message);
}

class CreateCityError extends CityState {
  final String error;
  CreateCityError(this.error);
}

// Update City
class UpdateCityLoading extends CityState {}

class UpdateCitySuccess extends CityState {
  final String message;
  UpdateCitySuccess(this.message);
}

class UpdateCityError extends CityState {
  final String error;
  UpdateCityError(this.error);
}

// Delete City
class DeleteCityLoading extends CityState {}

class DeleteCitySuccess extends CityState {
  final String message;
  DeleteCitySuccess(this.message);
}

class DeleteCityError extends CityState {
  final String error;
  DeleteCityError(this.error);
}
