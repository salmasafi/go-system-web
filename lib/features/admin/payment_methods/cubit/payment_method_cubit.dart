import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../model/payment_method_model.dart';
import 'payment_method_state.dart';
import 'package:systego/features/admin/payment_methods/data/repositories/payment_method_repository.dart';

class PaymentMethodCubit extends Cubit<PaymentMethodState> {
  final PaymentMethodRepository _repository;
  PaymentMethodCubit(this._repository) : super(PaymentMethodInitial());

  List<PaymentMethodModel> allPaymentMethods = [];

  Future<void> getPaymentMethods() async {
    emit(GetPaymentMethodsLoading());
    try {
      final paymentMethods = await _repository.getPaymentMethods();
      allPaymentMethods = paymentMethods;
      emit(GetPaymentMethodsSuccess(paymentMethods));
    } catch (e) {
      emit(GetPaymentMethodsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createPaymentMethod({
    required String name,
    required String arName,
    required File? icon,
    required String description,
    required String type,
    required bool isActive,
  }) async {
    emit(CreatePaymentMethodLoading());
    try {
      await _repository.createPaymentMethod(
        name: name,
        arName: arName,
        description: description,
        type: type,
        isActive: isActive,
        iconPath: icon?.path,
      );
      emit(CreatePaymentMethodSuccess(LocaleKeys.payment_method_created_success.tr()));
      getPaymentMethods();
    } catch (e) {
      emit(CreatePaymentMethodError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updatePaymentMethod({
    required String paymentMethodId,
    required String name,
    required String arName,
    required File? icon,
    required String description,
    required String type,
    required bool isActive,
  }) async {
    emit(UpdatePaymentMethodLoading());
    try {
      await _repository.updatePaymentMethod(
        paymentMethodId: paymentMethodId,
        name: name,
        arName: arName,
        description: description,
        type: type,
        isActive: isActive,
        iconPath: icon?.path,
      );
      emit(UpdatePaymentMethodSuccess(LocaleKeys.payment_method_updated_success.tr()));
      getPaymentMethods();
    } catch (e) {
      emit(UpdatePaymentMethodError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deletePaymentMethod(String paymentMethodId) async {
    emit(DeletePaymentMethodLoading());
    try {
      await _repository.deletePaymentMethod(paymentMethodId);
      allPaymentMethods.removeWhere(
        (paymentMethod) => paymentMethod.id == paymentMethodId,
      );
      emit(DeletePaymentMethodSuccess(LocaleKeys.payment_method_deleted_success.tr()));
    } catch (e) {
      emit(DeletePaymentMethodError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
