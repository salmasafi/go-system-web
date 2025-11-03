import '../model/payment_method_model.dart';

abstract class PaymentMethodState {}

class PaymentMethodInitial extends PaymentMethodState {}

// Get All PaymentMethod
class GetPaymentMethodsLoading extends PaymentMethodState {}

class GetPaymentMethodsSuccess extends PaymentMethodState {
  final List<PaymentMethodModel> paymentMethods;
  GetPaymentMethodsSuccess(this.paymentMethods);
}

class GetPaymentMethodsError extends PaymentMethodState {
  final String error;
  GetPaymentMethodsError(this.error);
}

// Get PaymentMethod By ID
class SelectPaymentMethodLoading extends PaymentMethodState {}

class SelectPaymentMethodSuccess extends PaymentMethodState {
  String message;
  SelectPaymentMethodSuccess(this.message);
}

class SelectPaymentMethodError extends PaymentMethodState {
  final String error;
  SelectPaymentMethodError(this.error);
}

// Create PaymentMethod
class CreatePaymentMethodLoading extends PaymentMethodState {}

class CreatePaymentMethodSuccess extends PaymentMethodState {
  final String message;
  CreatePaymentMethodSuccess(this.message);
}

class CreatePaymentMethodError extends PaymentMethodState {
  final String error;
  CreatePaymentMethodError(this.error);
}

// Update PaymentMethod
class UpdatePaymentMethodLoading extends PaymentMethodState {}

class UpdatePaymentMethodSuccess extends PaymentMethodState {
  final String message;
  UpdatePaymentMethodSuccess(this.message);
}

class UpdatePaymentMethodError extends PaymentMethodState {
  final String error;
  UpdatePaymentMethodError(this.error);
}

// Delete PaymentMethod
class DeletePaymentMethodLoading extends PaymentMethodState {}

class DeletePaymentMethodSuccess extends PaymentMethodState {
  final String message;
  DeletePaymentMethodSuccess(this.message);
}

class DeletePaymentMethodError extends PaymentMethodState {
  final String error;
  DeletePaymentMethodError(this.error);
}
