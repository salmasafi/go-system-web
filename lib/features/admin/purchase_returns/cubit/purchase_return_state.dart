part of 'purchase_return_cubit.dart';

abstract class PurchaseReturnState {}

class PurchaseReturnInitial extends PurchaseReturnState {}

class GetReturnsLoading extends PurchaseReturnState {}

class GetReturnsSuccess extends PurchaseReturnState {
  final PurchaseReturnData data;
  GetReturnsSuccess(this.data);
}

class GetReturnsError extends PurchaseReturnState {
  final String error;
  GetReturnsError(this.error);
}

class CreateReturnLoading extends PurchaseReturnState {}

class CreateReturnSuccess extends PurchaseReturnState {
  final String message;
  CreateReturnSuccess(this.message);
}

class CreateReturnError extends PurchaseReturnState {
  final String error;
  CreateReturnError(this.error);
}

class UpdateReturnLoading extends PurchaseReturnState {}

class UpdateReturnSuccess extends PurchaseReturnState {
  final String message;
  UpdateReturnSuccess(this.message);
}

class UpdateReturnError extends PurchaseReturnState {
  final String error;
  UpdateReturnError(this.error);
}

class DeleteReturnLoading extends PurchaseReturnState {}

class DeleteReturnSuccess extends PurchaseReturnState {
  final String message;
  DeleteReturnSuccess(this.message);
}

class DeleteReturnError extends PurchaseReturnState {
  final String error;
  DeleteReturnError(this.error);
}

class SearchPurchaseLoading extends PurchaseReturnState {}

class SearchPurchaseSuccess extends PurchaseReturnState {
  final Map<String, dynamic> purchase;
  SearchPurchaseSuccess(this.purchase);
}

class SearchPurchaseError extends PurchaseReturnState {
  final String error;
  SearchPurchaseError(this.error);
}
