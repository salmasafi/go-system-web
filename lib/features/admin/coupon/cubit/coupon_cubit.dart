import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/features/admin/coupon/model/coupon_model.dart';

part 'coupon_state.dart';

class CouponsCubit extends Cubit<CouponsState> {
  CouponsCubit() : super(CouponsInitial());

  List<CouponModel> allCoupons = [];

  Future<void> getCoupons() async {
    emit(GetCouponsLoading());
    try {
      final response = await DioHelper.getData(url: EndPoint.getAllCoupons);
      log(response.data.toString());

      if (response.statusCode == 200) {
        final model = CouponResponse.fromJson(response.data);

        if (model.success == true) {
          emit(GetCouponsSuccess(model.data.coupons));
        } else {
          final errorMessage = ErrorHandler.handleError(response);
          emit(GetCouponsError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(GetCouponsError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(GetCouponsError(errorMessage));
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
      final data = {
        "coupon_code": couponCode,
        "type": type,
        "amount": amount,
        "minimum_amount": minimumAmount,
        "quantity": quantity,
        "expired_date": expiredDate,
        "available": available
      };

      final response =
          await DioHelper.postData(url: EndPoint.addCoupon, data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(CreateCouponSuccess("Coupon created successfully"));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(CreateCouponError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(CreateCouponError(errorMessage));
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
      final data = {
        "coupon_code": couponCode,
        "type": type,
        "amount": amount,
        "minimum_amount": minimumAmount,
        "quantity": quantity,
        "expired_date": expiredDate,
        "available": available
      };

      final response = await DioHelper.putData(
        url: EndPoint.updateCoupon(couponId),
        data: data,
      );

      if (response.statusCode == 200) {
        emit(UpdateCouponSuccess("Coupon updated successfully"));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(UpdateCouponError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(UpdateCouponError(errorMessage));
    }
  }

  // ---------------------- Delete Coupon ----------------------
  Future<void> deleteCoupon(String couponId) async {
    emit(DeleteCouponLoading());

    try {
      final response =
          await DioHelper.deleteData(url: EndPoint.deleteCoupon(couponId));

      if (response.statusCode == 200) {
        allCoupons.removeWhere((c) => c.id == couponId);
        emit(DeleteCouponSuccess("Coupon deleted successfully"));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(DeleteCouponError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(DeleteCouponError(errorMessage));
    }
  }
}
