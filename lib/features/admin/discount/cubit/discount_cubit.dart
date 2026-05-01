import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/features/admin/discount/model/discount_model.dart';
import 'package:systego/generated/locale_keys.g.dart';

import 'package:systego/features/admin/discount/data/repositories/discount_repository.dart';

part 'discount_state.dart';

class DiscountsCubit extends Cubit<DiscountsState> {
  final DiscountRepository _repository;
  DiscountsCubit(this._repository) : super(DiscountsInitial());

  List<DiscountModel> allDiscounts = [];

  // ---------------------- Get All Discounts ----------------------
  Future<void> getDiscounts() async {
    emit(GetDiscountsLoading());
    try {
      final discounts = await _repository.getAllDiscounts();
      allDiscounts = discounts;
      emit(GetDiscountsSuccess(discounts));
    } catch (e) {
      emit(GetDiscountsError(e.toString().replaceAll('Exception: ', '')));
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
      final discount = DiscountModel(
        id: '',
        name: name,
        amount: _amount,
        type: type,
        status: status,
        createdAt: '',
        updatedAt: '',
        version: 0,
      );

      await _repository.createDiscount(discount);
      emit(CreateDiscountSuccess(LocaleKeys.discount_created_successfully.tr()));
    } catch (e) {
      emit(CreateDiscountError(e.toString().replaceAll('Exception: ', '')));
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
      final discount = DiscountModel(
        id: discountId,
        name: name,
        amount: _amount,
        type: type,
        status: status,
        createdAt: '',
        updatedAt: '',
        version: 0,
      );

      await _repository.updateDiscount(discount);
      emit(UpdateDiscountSuccess(LocaleKeys.discount_updated_successfully.tr()));
    } catch (e) {
      emit(UpdateDiscountError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // ---------------------- Delete Discount ----------------------
  Future<void> deleteDiscount(String discountId) async {
    emit(DeleteDiscountLoading());
    try {
      final success = await _repository.deleteDiscount(discountId);
      if (success) {
        emit(DeleteDiscountSuccess(LocaleKeys.discount_deleted_successfully.tr()));
      } else {
        emit(DeleteDiscountError('Failed to delete discount'));
      }
    } catch (e) {
      emit(DeleteDiscountError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
