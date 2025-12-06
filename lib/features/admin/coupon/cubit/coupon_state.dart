part of 'coupon_cubit.dart';

@immutable
sealed class CouponsState {}

final class CouponsInitial extends CouponsState {}

final class GetCouponsLoading extends CouponsState {}

final class CreateCouponsLoading extends CouponsState {}

final class CreateCouponsSuccess extends CouponsState {
  final String message;
  CreateCouponsSuccess(this.message);
}

final class GetCouponsSuccess extends CouponsState {
  final List<CouponModel> coupons;
  GetCouponsSuccess(this.coupons);
}

final class GetCouponsError extends CouponsState {
  final String error;
  GetCouponsError(this.error);
}

final class GetCouponByIdLoading extends CouponsState {}

final class GetCouponByIdSuccess extends CouponsState {
  final CouponModel coupon;
  GetCouponByIdSuccess(this.coupon);
}

final class GetCouponByIdError extends CouponsState {
  final String error;
  GetCouponByIdError(this.error);
}

final class CreateCouponLoading extends CouponsState {}

final class CreateCouponSuccess extends CouponsState {
  final String message;
  CreateCouponSuccess(this.message);
}

final class CreateCouponError extends CouponsState {
  final String error;
  CreateCouponError(this.error);
}

final class UpdateCouponLoading extends CouponsState {}

final class UpdateCouponSuccess extends CouponsState {
  final String message;
  UpdateCouponSuccess(this.message);
}

final class UpdateCouponError extends CouponsState {
  final String error;
  UpdateCouponError(this.error);
}

final class DeleteCouponLoading extends CouponsState {}

final class DeleteCouponSuccess extends CouponsState {
  final String message;
  DeleteCouponSuccess(this.message);
}

final class DeleteCouponError extends CouponsState {
  final String error;
  DeleteCouponError(this.error);
}

final class ChangeCouponStatusLoading extends CouponsState {}

final class ChangeCouponStatusSuccess extends CouponsState {
  final String message;
  ChangeCouponStatusSuccess(this.message);
}

final class ChangeCouponStatusError extends CouponsState {
  final String error;
  ChangeCouponStatusError(this.error);
}
