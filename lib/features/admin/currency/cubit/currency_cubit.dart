import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/dio_helper.dart';
import '../../../../core/services/endpoints.dart';
import '../../../../core/utils/error_handler.dart';
import '../model/currency_model.dart';
part 'currency_state.dart';

class CurrencyCubit extends Cubit<CurrencyState> {
  CurrencyCubit() : super(CurrencyInitial());

  //CreateCurrencyModel? currencyModel;
  List<CurrencyModel> allCurrencies = [];
  // CurrencyModel? selectedCurrency;

  Future<void> getCurrencies() async {
    emit(GetCurrenciesLoading());
    try {
      final response = await DioHelper.getData(url: EndPoint.getCurrencies);
      log(response.data.toString());
      if (response.statusCode == 200) {
        final model = CurrenciesResponse.fromJson(response.data);
        if (model.success == true && model.data.currencies.isNotEmpty) {
          emit(GetCurrenciesSuccess(model.data.currencies));
        } else {
          final errorMessage = ErrorHandler.handleError(response);
          emit(GetCurrenciesError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(GetCurrenciesError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(GetCurrenciesError(errorMessage));
    }
  }

  // Future<void> getCurrencyById(String currencyId) async {
  //   emit(GetCurrencyByIdLoading());
  //   try {
  //     final response = await DioHelper.getData(
  //       url: EndPoint.getCurrencyById(currencyId),
  //     );

  //     if (response.statusCode == 200) {
  //       final json = response.data;
  //       if (json['success'] == true && json['data']?['Currency'] != null) {
  //         selectedCurrency = CurrencyModel.fromJson(json['data']['Currency']);
  //         emit(GetCurrencyByIdSuccess(selectedCurrency!));
  //       } else {
  //         final errorMessage = ErrorHandler.handleError(response);
  //         emit(GetCurrencyByIdError(errorMessage));
  //       }
  //     } else {
  //       final errorMessage = ErrorHandler.handleError(response);
  //       emit(GetCurrencyByIdError(errorMessage));
  //     }
  //   } catch (e) {
  //     final errorMessage = ErrorHandler.handleError(e);
  //     emit(GetCurrencyByIdError(errorMessage));
  //   }
  // }

  Future<void> createCurrency({
    required String name,
    required String arName,
    required double amount,
    required bool isDefault,
  }) async {
    emit(CreateCurrencyLoading());
    try {
      final data = {
        'name': name,
        'ar_name': arName,
        'amount': amount,
        'isdefault': isDefault,
      };

      final response = await DioHelper.postData(
        url: EndPoint.createCurrency,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(CreateCurrencySuccess('Currency is created successfully'));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(CreateCurrencyError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(CreateCurrencyError(errorMessage));
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
      final data = {
        'name': name,
        'ar_name': arName,
        'amount': amount,
        'isdefault': isDefault,
      };

      final response = await DioHelper.putData(
        url: EndPoint.updateCurrency(currencyId),
        data: data,
      );

      if (response.statusCode == 200) {
        emit(UpdateCurrencySuccess('Currency updated successfully'));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(UpdateCurrencyError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(UpdateCurrencyError(errorMessage));
    }
  }

  Future<void> deleteCurrency(String currencyId) async {
    emit(DeleteCurrencyLoading());
    try {
      final response = await DioHelper.deleteData(
        url: EndPoint.deleteCurrency(currencyId),
      );

      if (response.statusCode == 200) {
        allCurrencies.removeWhere((currency) => currency.id == currencyId);
        emit(DeleteCurrencySuccess('Currency deleted successfully'));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(DeleteCurrencyError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(DeleteCurrencyError(errorMessage));
    }
  }
}
