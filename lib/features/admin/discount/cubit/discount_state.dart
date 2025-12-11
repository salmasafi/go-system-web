part of 'discount_cubit.dart';

class DiscountsState {}

final class DiscountsInitial extends DiscountsState {}


// ---------------------- Get All Discounts ----------------------
final class GetDiscountsLoading extends DiscountsState {}

final class GetDiscountsSuccess extends DiscountsState {
  final List<DiscountModel> discounts;
  GetDiscountsSuccess(this.discounts);
}

final class GetDiscountsError extends DiscountsState {
  final String error;
  GetDiscountsError(this.error);
}


// ---------------------- Get Discount By ID ----------------------
final class GetDiscountByIdLoading extends DiscountsState {}

final class GetDiscountByIdSuccess extends DiscountsState {
  final DiscountModel discount;
  GetDiscountByIdSuccess(this.discount);
}

final class GetDiscountByIdError extends DiscountsState {
  final String error;
  GetDiscountByIdError(this.error);
}


// ---------------------- Create Discount ----------------------
final class CreateDiscountLoading extends DiscountsState {}

final class CreateDiscountSuccess extends DiscountsState {
  final String message;
  CreateDiscountSuccess(this.message);
}

final class CreateDiscountError extends DiscountsState {
  final String error;
  CreateDiscountError(this.error);
}


// ---------------------- Update Discount ----------------------
final class UpdateDiscountLoading extends DiscountsState {}

final class UpdateDiscountSuccess extends DiscountsState {
  final String message;
  UpdateDiscountSuccess(this.message);
}

final class UpdateDiscountError extends DiscountsState {
  final String error;
  UpdateDiscountError(this.error);
}


// ---------------------- Delete Discount ----------------------
final class DeleteDiscountLoading extends DiscountsState {}

final class DeleteDiscountSuccess extends DiscountsState {
  final String message;
  DeleteDiscountSuccess(this.message);
}

final class DeleteDiscountError extends DiscountsState {
  final String error;
  DeleteDiscountError(this.error);
}


// ---------------------- Change Discount Status (Optional) ----------------------
final class ChangeDiscountStatusLoading extends DiscountsState {}

final class ChangeDiscountStatusSuccess extends DiscountsState {
  final String message;
  ChangeDiscountStatusSuccess(this.message);
}

final class ChangeDiscountStatusError extends DiscountsState {
  final String error;
  ChangeDiscountStatusError(this.error);
}
