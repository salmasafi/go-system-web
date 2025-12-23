part of 'cashier_cubit.dart';

@immutable
abstract class CashierState {}

class CashierInitial extends CashierState {}

// Get Cashiers States
class GetCashiersLoading extends CashierState {}
class GetCashiersSuccess extends CashierState {
  final List<CashierModel> cashiers;
  GetCashiersSuccess(this.cashiers);
}
class GetCashiersError extends CashierState {
  final String error;
  GetCashiersError(this.error);
}

// Create Cashier States
class CreateCashierLoading extends CashierState {}
class CreateCashierSuccess extends CashierState {
  final String message;
  CreateCashierSuccess(this.message);
}
class CreateCashierError extends CashierState {
  final String error;
  CreateCashierError(this.error);
}

// Update Cashier States
class UpdateCashierLoading extends CashierState {}
class UpdateCashierSuccess extends CashierState {
  final String message;
  UpdateCashierSuccess(this.message);
}
class UpdateCashierError extends CashierState {
  final String error;
  UpdateCashierError(this.error);
}

// Delete Cashier States
class DeleteCashierLoading extends CashierState {}
class DeleteCashierSuccess extends CashierState {
  final String message;
  DeleteCashierSuccess(this.message);
}
class DeleteCashierError extends CashierState {
  final String error;
  DeleteCashierError(this.error);
}

// Toggle Cashier Status States
class ToggleCashierStatusLoading extends CashierState {}
class ToggleCashierStatusSuccess extends CashierState {
  final bool isActive;
  ToggleCashierStatusSuccess(this.isActive);
}
class ToggleCashierStatusError extends CashierState {
  final String error;
  ToggleCashierStatusError(this.error);
}

// Assign User States
class AssignUserLoading extends CashierState {}
class AssignUserSuccess extends CashierState {
  final String message;
  AssignUserSuccess(this.message);
}
class AssignUserError extends CashierState {
  final String error;
  AssignUserError(this.error);
}

// Remove User States
class RemoveUserLoading extends CashierState {}
class RemoveUserSuccess extends CashierState {
  final String message;
  RemoveUserSuccess(this.message);
}
class RemoveUserError extends CashierState {
  final String error;
  RemoveUserError(this.error);
}