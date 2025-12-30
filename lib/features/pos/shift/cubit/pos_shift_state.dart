part of 'pos_shift_cubit.dart';

abstract class PosShiftState {}

class PosShiftInitial extends PosShiftState {}

class PosGetCashiersLoading extends PosShiftState {}

class PosGetCashiersSuccess extends PosShiftState {
  final List<CashierModel> cashiers;
  PosGetCashiersSuccess(this.cashiers);
}

class PosGetCashiersError extends PosShiftState {
  final String message;
  PosGetCashiersError(this.message);
}

class PosCashierSelected extends PosShiftState {
  final CashierModel cashier;
  PosCashierSelected(this.cashier);
}
