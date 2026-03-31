part of 'units_cubit.dart';

@immutable
sealed class UnitsState {}

final class UnitsInitial extends UnitsState {}

final class GetUnitsLoading extends UnitsState {}

final class GetUnitsSuccess extends UnitsState {
  final List<UnitModel> units;
  GetUnitsSuccess(this.units);
}

final class GetUnitsError extends UnitsState {
  final String error;
  GetUnitsError(this.error);
}

final class CreateUnitLoading extends UnitsState {}

final class CreateUnitSuccess extends UnitsState {
  final String message;
  CreateUnitSuccess(this.message);
}

final class CreateUnitError extends UnitsState {
  final String error;
  CreateUnitError(this.error);
}

final class UpdateUnitLoading extends UnitsState {}

final class UpdateUnitSuccess extends UnitsState {
  final String message;
  UpdateUnitSuccess(this.message);
}

final class UpdateUnitError extends UnitsState {
  final String error;
  UpdateUnitError(this.error);
}

final class DeleteUnitLoading extends UnitsState {}

final class DeleteUnitSuccess extends UnitsState {
  final String message;
  DeleteUnitSuccess(this.message);
}

final class DeleteUnitError extends UnitsState {
  final String error;
  DeleteUnitError(this.error);
}

final class ChangeUnitStatusLoading extends UnitsState {}

final class ChangeUnitStatusSuccess extends UnitsState {
  final String message;
  ChangeUnitStatusSuccess(this.message);
}

final class ChangeUnitStatusError extends UnitsState {
  final String error;
  ChangeUnitStatusError(this.error);
}
