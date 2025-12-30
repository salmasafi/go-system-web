// lib/features/pos/home/cubit/pos_home_state.dart

import '../../shift/model/cashier_model.dart';
import '../model/pos_models.dart';

// lib/features/pos/home/cubit/pos_home_state.dart
abstract class PosState {}

class PosInitial extends PosState {}

class PosLoading extends PosState {}

class PosProductsLoading extends PosState {}

class PosLoaded extends PosState {}

class PosDataLoaded extends PosState {
  final List<Product> displayedProducts;
  PosDataLoaded(this.displayedProducts);
}

class PosError extends PosState {
  final String message;
  PosError(this.message);
}

class PosCashiersLoaded extends PosState {
  final List<CashierModel> cashiers;
  PosCashiersLoaded(this.cashiers);
}

class PosCashierSelected extends PosState {}

class PosShiftLoaded extends PosState {}

class PosShiftStarted extends PosState {}

class PosShiftEnded extends PosState {}

class PosLoggedOut extends PosState {}
