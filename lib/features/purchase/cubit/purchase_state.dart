abstract class PurchaseState {}

class PurchaseInitial extends PurchaseState {}

class PurchaseLoading extends PurchaseState {}

class PurchaseError extends PurchaseState {
  final String message;
  PurchaseError(this.message);
}

class PurchaseSuccess extends PurchaseState {}