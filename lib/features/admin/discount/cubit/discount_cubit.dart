import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/features/admin/discount/model/discount_model.dart';
import 'package:systego/generated/locale_keys.g.dart';

part 'discount_state.dart';

class DiscountsCubit extends Cubit<DiscountsState> {
  DiscountsCubit() : super(DiscountsInitial());

  List<DiscountModel> allDiscounts = [];

  // ---------------------- Get All Discounts ----------------------
  Future<void> getDiscounts() async {
    emit(GetDiscountsLoading());
    try {
      final response = await DioHelper.getData(url: EndPoint.getAllDiscounts);
      log(response.data.toString());

      if (response.statusCode == 200) {
        final model = DiscountResponse.fromJson(response.data);

        if (model.success == true) {
          emit(GetDiscountsSuccess(model.data.discounts));
        } else {
          final errorMessage = ErrorHandler.handleError(response);
          emit(GetDiscountsError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(GetDiscountsError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(GetDiscountsError(errorMessage));
    }
  }

  // ---------------------- Create Discount ----------------------
  Future<void> createDiscount({
    required String name,
    required String type,
    required double amount,
    required bool status,
  }) async {
    emit(CreateDiscountLoading());
    var _amount = (type == 'fixed') ? amount : amount / 100;
    try {
      final data = {
        "name": name,
        "amount": _amount,
        "type": type,
        "status": status,
      };

      final response = await DioHelper.postData(
        url: EndPoint.addDiscount,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(
          CreateDiscountSuccess(LocaleKeys.discount_created_successfully.tr()),
        );
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(CreateDiscountError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(CreateDiscountError(errorMessage));
    }
  }

  // ---------------------- Update Discount ----------------------
  Future<void> updateDiscount({
    required String discountId,
    required String name,
    required String type,
    required double amount,
    required bool status,
  }) async {
    emit(UpdateDiscountLoading());
    var _amount = (type == 'fixed') ? amount : amount / 100;
    try {
      final data = {
        "name": name,
        "amount": _amount,
        "type": type,
        "status": status,
      };

      final response = await DioHelper.putData(
        url: EndPoint.updateDiscount(discountId),
        data: data,
      );

      if (response.statusCode == 200) {
        emit(
          UpdateDiscountSuccess(LocaleKeys.discount_updated_successfully.tr()),
        );
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(UpdateDiscountError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(UpdateDiscountError(errorMessage));
    }
  }

  // ---------------------- Delete Discount ----------------------
  Future<void> deleteDiscount(String discountId) async {
    emit(DeleteDiscountLoading());

    try {
      final response = await DioHelper.deleteData(
        url: EndPoint.deleteDiscount(discountId),
      );

      if (response.statusCode == 200) {
        allDiscounts.removeWhere((d) => d.id == discountId);
        emit(
          DeleteDiscountSuccess(LocaleKeys.discount_deleted_successfully.tr()),
        );
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(DeleteDiscountError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(DeleteDiscountError(errorMessage));
    }
  }
}
