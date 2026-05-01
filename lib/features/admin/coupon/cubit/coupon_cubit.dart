import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:meta/meta.dart';
import 'package:systego/features/admin/coupon/model/coupon_model.dart';
import 'package:systego/generated/locale_keys.g.dart';
import 'package:systego/features/admin/coupon/data/repositories/coupon_repository.dart';

part 'coupon_state.dart';

class CouponsCubit extends Cubit<CouponsState> {
  final CouponRepository _repository;
  CouponsCubit(this._repository) : super(CouponsInitial());

  List<CouponModel> allCoupons = [];

  Future<void> getCoupons() async {
    emit(GetCouponsLoading());
    try {
      final coupons = await _repository.getAllCoupons();
      allCoupons = coupons;
      emit(GetCouponsSuccess(coupons));
    } catch (e) {
      emit(GetCouponsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createCoupon({
    required String couponCode,
    required String type,
    required double amount,
    required double minimumAmount,
    required int quantity,
    required String expiredDate,
    required int available,
  }) async {
    emit(CreateCouponLoading());

    try {
      final coupon = CouponModel(
        id: '',
        couponCode: couponCode,
        type: type,
        amount: amount,
        minimumAmount: minimumAmount,
        quantity: quantity,
        available: available,
        expiredDate: expiredDate,
        status: true,
        createdAt: '',
        updatedAt: '',
        version: 0,
      );

      await _repository.createCoupon(coupon);
      emit(CreateCouponSuccess(LocaleKeys.coupon_created_success.tr()));
    } catch (e) {
      emit(CreateCouponError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateCoupon({
    required String couponId,
    required String couponCode,
    required String type,
    required double amount,
    required double minimumAmount,
    required int quantity,
    required String expiredDate,
    required int available,
  }) async {
    emit(UpdateCouponLoading());

    try {
      final coupon = CouponModel(
        id: couponId,
        couponCode: couponCode,
        type: type,
        amount: amount,
        minimumAmount: minimumAmount,
        quantity: quantity,
        available: available,
        expiredDate: expiredDate,
        status: true,
        createdAt: '',
        updatedAt: '',
        version: 0,
      );

      await _repository.updateCoupon(coupon);
      emit(UpdateCouponSuccess(LocaleKeys.coupon_updated_success.tr()));
    } catch (e) {
      emit(UpdateCouponError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteCoupon(String couponId) async {
    emit(DeleteCouponLoading());
    try {
      final success = await _repository.deleteCoupon(couponId);
      if (success) {
        allCoupons.removeWhere((c) => c.id == couponId);
        emit(DeleteCouponSuccess(LocaleKeys.coupon_deleted_success.tr()));
      } else {
        emit(DeleteCouponError('Failed to delete coupon'));
      }
    } catch (e) {
      emit(DeleteCouponError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> toggleCouponStatus(String couponId, bool newStatus) async {
    emit(ChangeCouponStatusLoading());
    try {
      final coupon = allCoupons.firstWhere((c) => c.id == couponId);
      final updatedCoupon = coupon.copyWith(status: newStatus);
      
      await _repository.updateCoupon(updatedCoupon);
      
      emit(ChangeCouponStatusSuccess(
        newStatus 
          ? LocaleKeys.coupon_activated_success.tr() 
          : LocaleKeys.coupon_deactivated_success.tr()
      ));
    } catch (e) {
      emit(ChangeCouponStatusError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
