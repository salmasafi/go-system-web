// lib/features/pos/home/cubit/pos_home_state.dart

import '../model/pos_models.dart';

abstract class PosState {}

class PosInitial extends PosState {}
class PosLoading extends PosState {}
class PosLoaded extends PosState {}
class PosProductsLoading extends PosState {}

// NEW: unified loaded state with displayed products
class PosDataLoaded extends PosState {
  final List<Product> displayedProducts;
  PosDataLoaded(this.displayedProducts);
}

class PosError extends PosState {
  final String message;
  PosError(this.message);
}