import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:meta/meta.dart';
import 'package:GoSystem/core/services/dio_helper.dart';
import 'package:GoSystem/core/services/endpoints.dart';
import 'package:GoSystem/core/utils/error_handler.dart';
import 'package:GoSystem/features/admin/purchase/model/purchase_model.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import 'package:GoSystem/features/admin/purchase/data/repositories/purchase_repository.dart';
part 'purchase_state.dart';
class PurchaseCubit extends Cubit<PurchaseState> {
  final PurchaseRepository _repository;
  PurchaseCubit(this._repository) : super(PurchaseInitial());

  PurchaseData? purchaseData;

  Future<void> getAllPurchases() async {
    emit(GetPurchasesLoading());
    try {
      final data = await _repository.getAllPurchases();
      purchaseData = data;
      emit(GetPurchasesSuccess(data));
    } catch (e) {
      emit(GetPurchasesError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createPurchase({
    required String warehouseId,
    required String supplierId,
    required List<Map<String, dynamic>> items,
    required double grandTotal,
    double? taxAmount,
    double? discount,
    double? shippingCost,
    String? note,
    File? receiptImageFile,
    List<Map<String, dynamic>>? payments,
  }) async {
    emit(CreatePurchaseLoading());
    try {
      await _repository.createPurchase(
        warehouseId: warehouseId,
        supplierId: supplierId,
        items: items,
        grandTotal: grandTotal,
        taxAmount: taxAmount,
        discount: discount,
        shippingCost: shippingCost,
        note: note,
        receiptImageFile: receiptImageFile,
        payments: payments,
      );
      emit(CreatePurchaseSuccess(LocaleKeys.success.tr()));
      await getAllPurchases();
    } catch (e) {
      emit(CreatePurchaseError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deletePurchase(String id) async {
    emit(DeletePurchaseLoading());
    try {
      await _repository.deletePurchase(id);
      emit(DeletePurchaseSuccess(LocaleKeys.success.tr()));
      await getAllPurchases();
    } catch (e) {
      emit(DeletePurchaseError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updatePurchase({
    required String id,
    String? note,
    double? discount,
    double? shippingCost,
  }) async {
    emit(UpdatePurchaseLoading());
    try {
      await _repository.updatePurchase(
        id: id,
        note: note,
        discount: discount,
        shippingCost: shippingCost,
      );
      emit(UpdatePurchaseSuccess(LocaleKeys.success.tr()));
      await getAllPurchases();
    } catch (e) {
      emit(UpdatePurchaseError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

