part of 'pos_cashier_cubit.dart';

@immutable
abstract class PosCashierState {}

class PosCashierInitial extends PosCashierState {}

class PosGetCashiersLoading extends PosCashierState {}

class PosGetCashiersSuccess extends PosCashierState {
  final List<CashierModel> cashiers;
  PosGetCashiersSuccess(this.cashiers);
}

class PosGetCashiersError extends PosCashierState {
  final String message;
  PosGetCashiersError(this.message);
}

class PosCashierSelected extends PosCashierState {
  final CashierModel cashier;
  PosCashierSelected(this.cashier);
}