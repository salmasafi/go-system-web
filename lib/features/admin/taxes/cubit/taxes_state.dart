part of 'taxes_cubit.dart';

@immutable
sealed class TaxesState {}

final class TaxesInitial extends TaxesState {}

final class GetTaxesLoading extends TaxesState{}

final class CreateTaxesLoading extends TaxesState {}

final class CreateTaxesSuccess extends TaxesState {
  final String message;
  CreateTaxesSuccess(this.message);
}


final class GetTaxesSuccess extends TaxesState {
  final List<TaxModel> taxes;
  GetTaxesSuccess(this.taxes);
}

final class GetTaxesError extends TaxesState {
  final String error;
  GetTaxesError(this.error);
}

final class GetTaxByIdLoading extends TaxesState {}

final class GetTaxByIdSuccess extends TaxesState {
  final TaxModel tax;
  GetTaxByIdSuccess(this.tax);
}

final class GetTaxByIdError extends TaxesState {
  final String error;
  GetTaxByIdError(this.error);
}

final class CreateTaxLoading extends TaxesState {}

final class CreateTaxSuccess extends TaxesState {
  final String message;
  CreateTaxSuccess(this.message);
}

final class CreateTaxError extends TaxesState {
  final String error;
  CreateTaxError(this.error);
}

final class UpdateTaxLoading extends TaxesState {}

final class UpdateTaxSuccess extends TaxesState {
  final String message;
  UpdateTaxSuccess(this.message);
}

final class UpdateTaxError extends TaxesState {
  final String error;
  UpdateTaxError(this.error);
}

final class DeleteTaxLoading extends TaxesState {}

final class DeleteTaxSuccess extends TaxesState {
  final String message;
  DeleteTaxSuccess(this.message);
}

final class DeleteTaxError extends TaxesState {
  final String error;
  DeleteTaxError(this.error);
}

final class ChangeTaxStatusLoading extends TaxesState {}

final class ChangeTaxStatusSuccess extends TaxesState {
  final String message;
  ChangeTaxStatusSuccess(this.message);
}

final class ChangeTaxStatusError extends TaxesState {
  final String error;
  ChangeTaxStatusError(this.error);
}