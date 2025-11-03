part of 'currency_cubit.dart';

abstract class CurrencyState {}

class CurrencyInitial extends CurrencyState {}

// Get All Currency
class GetCurrenciesLoading extends CurrencyState {}

class GetCurrenciesSuccess extends CurrencyState {
  final List<CurrencyModel> currencies;
  GetCurrenciesSuccess(this.currencies);
}

class GetCurrenciesError extends CurrencyState {
  final String error;
  GetCurrenciesError(this.error);
}

// Get Currency By ID
class GetCurrencyByIdLoading extends CurrencyState {}

class GetCurrencyByIdSuccess extends CurrencyState {
  final CurrencyModel currency;
  GetCurrencyByIdSuccess(this.currency);
}

class GetCurrencyByIdError extends CurrencyState {
  final String error;
  GetCurrencyByIdError(this.error);
}

// Create Currency
class CreateCurrencyLoading extends CurrencyState {}

class CreateCurrencySuccess extends CurrencyState {
  final String message;
  CreateCurrencySuccess(this.message);
}

class CreateCurrencyError extends CurrencyState {
  final String error;
  CreateCurrencyError(this.error);
}

// Update Currency
class UpdateCurrencyLoading extends CurrencyState {}

class UpdateCurrencySuccess extends CurrencyState {
  final String message;
  UpdateCurrencySuccess(this.message);
}

class UpdateCurrencyError extends CurrencyState {
  final String error;
  UpdateCurrencyError(this.error);
}

// Delete Currency
class DeleteCurrencyLoading extends CurrencyState {}

class DeleteCurrencySuccess extends CurrencyState {
  final String message;
  DeleteCurrencySuccess(this.message);
}

class DeleteCurrencyError extends CurrencyState {
  final String error;
  DeleteCurrencyError(this.error);
}