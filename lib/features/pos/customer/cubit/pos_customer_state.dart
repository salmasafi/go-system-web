part of 'pos_customer_cubit.dart';

abstract class PosCustomerState {}

class PosCustomerInitial extends PosCustomerState {}

class PosCustomerLoading extends PosCustomerState {}

class PosCustomerLoaded extends PosCustomerState {
  final List<PosCustomer> customers;
  final PosCustomer? selectedCustomer;

  PosCustomerLoaded({required this.customers, this.selectedCustomer});
}

class PosCustomerError extends PosCustomerState {
  final String message;
  PosCustomerError(this.message);
}

class PosCustomerCreating extends PosCustomerState {}

class PosCustomerCreateSuccess extends PosCustomerState {
  final PosCustomer newCustomer;
  PosCustomerCreateSuccess(this.newCustomer);
}

class PosCustomerCreateError extends PosCustomerState {
  final String message;
  PosCustomerCreateError(this.message);
}
