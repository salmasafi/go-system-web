part of 'checkout_cubit.dart';

abstract class CheckoutState {}

class CheckoutInitial extends CheckoutState {}
class CheckoutLoading extends CheckoutState {}
class CheckoutSuccess extends CheckoutState {
  final String reference;
  final int pointsEarned;
  final Map<String, dynamic> sale;

  CheckoutSuccess({required this.reference, required this.pointsEarned, required this.sale});
}
class CheckoutError extends CheckoutState {
  final String message;
  CheckoutError(this.message);
}