part of 'pos_shift_cubit.dart';

abstract class PosShiftState {}

class PosShiftInitial extends PosShiftState {}

// ─── Cashier Fetching States ───
class PosGetCashiersLoading extends PosShiftState {}

class PosGetCashiersSuccess extends PosShiftState {
  final List<CashierModel> cashiers;
  PosGetCashiersSuccess(this.cashiers);
}

class PosGetCashiersError extends PosShiftState {
  final String message;
  PosGetCashiersError(this.message);
}

// ─── Cashier Selection States ───
class PosSelectCashierLoading extends PosShiftState {}

class PosCashierSelected extends PosShiftState {
  final CashierModel cashier;
  PosCashierSelected(this.cashier);
}

class PosSelectCashierError extends PosShiftState {
  final String message;
  PosSelectCashierError(this.message);
}

// ─── Shift Operations States (Start, End, Logout) ───
class PosShiftActionLoading extends PosShiftState {} // للتحميل العام (Start/End/Logout)

class PosShiftStarted extends PosShiftState {
  final ShiftModel shift;
  PosShiftStarted(this.shift);
}

class PosShiftEnded extends PosShiftState {}

class PosLoggedOut extends PosShiftState {}

class PosShiftActionError extends PosShiftState {
  final String message;
  PosShiftActionError(this.message);
}