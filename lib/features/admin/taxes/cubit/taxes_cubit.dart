import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:meta/meta.dart';
import 'package:GoSystem/features/admin/taxes/data/repositories/tax_repository.dart';
import 'package:GoSystem/features/admin/taxes/model/taxes_model.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';

part 'taxes_state.dart';

class TaxesCubit extends Cubit<TaxesState> {
  final TaxRepository _repository;
  TaxesCubit(this._repository) : super(TaxesInitial());

  List<TaxModel> allTaxes = [];

  Future<void> getTaxes() async {
    emit(GetTaxesLoading());
    try {
      final taxes = await _repository.getAllTaxes();
      allTaxes = taxes;
      emit(GetTaxesSuccess(taxes));
    } catch (e) {
      emit(GetTaxesError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> changeTaxStatus(String taxId, String name, bool status) async {
    emit(ChangeTaxStatusLoading());
    try {
      final tax = allTaxes.firstWhere((t) => t.id == taxId);
      final updatedTax = tax.copyWith(status: status);
      await _repository.updateTax(updatedTax);
      allTaxes = allTaxes.map((t) => t.id == taxId ? updatedTax : t).toList();
      emit(ChangeTaxStatusSuccess(
        '$name ${status ? LocaleKeys.activated_successfully.tr() : LocaleKeys.deactivated_successfully.tr()}',
      ));
    } catch (e) {
      log('TaxesCubit: changeTaxStatus error - $e');
      emit(ChangeTaxStatusError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createTax({
    required String name,
    required String arName,
    required double amount,
    required String taxType,
    bool status = true,
  }) async {
    emit(CreateTaxLoading());
    try {
      final tax = TaxModel(
        id: '',
        name: name,
        arName: arName,
        amount: amount,
        type: taxType,
        status: status,
      );

      await _repository.createTax(tax);
      emit(CreateTaxSuccess(LocaleKeys.tax_created_success.tr()));
      await getTaxes();
    } catch (e) {
      emit(CreateTaxError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateTax({
    required String taxId,
    required String name,
    required String arName,
    required double amount,
    required String taxType,
    bool? status,
  }) async {
    emit(UpdateTaxLoading());
    try {
      final existing = allTaxes.firstWhere(
        (t) => t.id == taxId,
        orElse: () => TaxModel(
          id: taxId,
          name: name,
          arName: arName,
          amount: amount,
          type: taxType,
          status: true,
        ),
      );
      final updatedTax = existing.copyWith(
        name: name,
        arName: arName,
        amount: amount,
        type: taxType,
        status: status,
      );

      await _repository.updateTax(updatedTax);
      emit(UpdateTaxSuccess(LocaleKeys.tax_updated_success.tr()));
      await getTaxes();
    } catch (e) {
      emit(UpdateTaxError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteTax(String taxId) async {
    emit(DeleteTaxLoading());
    try {
      final success = await _repository.deleteTax(taxId);
      if (success) {
        allTaxes.removeWhere((t) => t.id == taxId);
        emit(DeleteTaxSuccess(LocaleKeys.tax_deleted_success.tr()));
      } else {
        emit(DeleteTaxError('Failed to delete tax'));
      }
    } catch (e) {
      emit(DeleteTaxError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
