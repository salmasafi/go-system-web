import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../core/services/dio_helper.dart';
import '../../../../core/services/endpoints.dart';
import '../../../../core/utils/error_handler.dart';
import '../model/currency_model.dart';
import 'package:systego/features/admin/currency/data/repositories/currency_repository.dart';

part 'currency_state.dart';

class CurrencyCubit extends Cubit<CurrencyState> {
  final CurrencyRepository _repository;
  CurrencyCubit(this._repository) : super(CurrencyInitial());

  List<CurrencyModel> allCurrencies = [];

  Future<void> getCurrencies() async {
    emit(GetCurrenciesLoading());
    try {
      final currencies = await _repository.getCurrencies();
      allCurrencies = currencies;
      emit(GetCurrenciesSuccess(currencies));
    } catch (e) {
      emit(GetCurrenciesError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createCurrency({
    required String name,
    required String arName,
    required double amount,
    required bool isDefault,
  }) async {
    emit(CreateCurrencyLoading());
    try {
      await _repository.createCurrency(
        name: name,
        arName: arName,
        amount: amount,
        isDefault: isDefault,
      );
      emit(CreateCurrencySuccess(LocaleKeys.currency_created_success.tr()));
      getCurrencies();
    } catch (e) {
      emit(CreateCurrencyError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateCurrency({
    required String currencyId,
    required String name,
    required String arName,
    required double amount,
    required bool isDefault,
  }) async {
    emit(UpdateCurrencyLoading());
    try {
      await _repository.updateCurrency(
        currencyId: currencyId,
        name: name,
        arName: arName,
        amount: amount,
        isDefault: isDefault,
      );
      emit(UpdateCurrencySuccess(LocaleKeys.currency_updated_success.tr()));
      getCurrencies();
    } catch (e) {
      emit(UpdateCurrencyError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteCurrency(String currencyId) async {
    emit(DeleteCurrencyLoading());
    try {
      await _repository.deleteCurrency(currencyId);
      allCurrencies.removeWhere((currency) => currency.id == currencyId);
      emit(DeleteCurrencySuccess(LocaleKeys.currency_deleted_success.tr()));
    } catch (e) {
      emit(DeleteCurrencyError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
