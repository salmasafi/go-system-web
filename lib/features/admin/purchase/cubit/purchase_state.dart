// abstract class PurchaseState {}

// class PurchaseInitial extends PurchaseState {}

// class PurchaseLoading extends PurchaseState {}

// class PurchaseError extends PurchaseState {
//   final String message;
//   PurchaseError(this.message);
// }

// class PurchaseSuccess extends PurchaseState {}

part of 'purchase_cubit.dart';

@immutable
sealed class PurchaseState {}

final class PurchaseInitial extends PurchaseState {}

// --- Get All ---
final class GetPurchasesLoading extends PurchaseState {}

final class GetPurchasesSuccess extends PurchaseState {
  final PurchaseData data;
  // We can pass the full data object, or a flattened list depending on UI needs
  GetPurchasesSuccess(this.data);
}

final class GetPurchasesError extends PurchaseState {
  final String error;
  GetPurchasesError(this.error);
}

// --- Get By ID ---
final class GetPurchaseByIdLoading extends PurchaseState {}

final class GetPurchaseByIdSuccess extends PurchaseState {
  final Purchase purchase;
  GetPurchaseByIdSuccess(this.purchase);
}

final class GetPurchaseByIdError extends PurchaseState {
  final String error;
  GetPurchaseByIdError(this.error);
}

// --- Create ---
final class CreatePurchaseLoading extends PurchaseState {}

final class CreatePurchaseSuccess extends PurchaseState {
  final String message;
  CreatePurchaseSuccess(this.message);
}

final class CreatePurchaseError extends PurchaseState {
  final String error;
  CreatePurchaseError(this.error);
}

// --- Update ---
final class UpdatePurchaseLoading extends PurchaseState {}

final class UpdatePurchaseSuccess extends PurchaseState {
  final String message;
  UpdatePurchaseSuccess(this.message);
}

final class UpdatePurchaseError extends PurchaseState {
  final String error;
  UpdatePurchaseError(this.error);
}

// --- Delete ---
final class DeletePurchaseLoading extends PurchaseState {}

final class DeletePurchaseSuccess extends PurchaseState {
  final String message;
  DeletePurchaseSuccess(this.message);
}

final class DeletePurchaseError extends PurchaseState {
  final String error;
  DeletePurchaseError(this.error);
}
