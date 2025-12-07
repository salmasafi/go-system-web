part of 'checkout_cubit.dart';

abstract class CheckoutState {}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutSuccess extends CheckoutState {}

class CheckoutError extends CheckoutState {
  final String message;
  CheckoutError(this.message);
}

// NEW: Cart update state
class PosCartUpdated extends CheckoutState {
  final List<CartItem> cartItems;
  PosCartUpdated(this.cartItems);
}
