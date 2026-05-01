import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:meta/meta.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/features/admin/purchase/model/purchase_model.dart';
import 'package:systego/generated/locale_keys.g.dart';
import 'package:systego/features/admin/purchase/data/repositories/purchase_repository.dart';
part 'purchase_state.dart';
class PurchaseCubit extends Cubit<PurchaseState> {
  final PurchaseRepository _repository;
  PurchaseCubit(this._repository) : super(PurchaseInitial());

  PurchaseData? purchaseData;

  // ---------------------- Get All Purchases ----------------------
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

  // Other methods if needed
}

