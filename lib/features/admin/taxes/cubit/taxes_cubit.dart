import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/features/admin/taxes/model/taxes_model.dart';

part 'taxes_state.dart';

class TaxesCubit extends Cubit<TaxesState> {
  TaxesCubit() : super(TaxesInitial());

  List<TaxModel> allTaxes = [];

  Future<void> getTaxes() async {
    emit(GetTaxesLoading());
    try {
      final response = await DioHelper.getData(url: EndPoint.getAllTaxes);
      log(response.data.toString());
      if (response.statusCode == 200) {
        final model = TaxResponse.fromJson(response.data);
        if (model.success == true) {
          emit(GetTaxesSuccess(model.data.taxes));
        } else {
          final errorMessage = ErrorHandler.handleError(response);
          emit(GetTaxesError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(GetTaxesError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(GetTaxesError(errorMessage));
    }
  }

  Future<void> changeTaxStatus(String taxId, String name, bool status) async {
    emit(ChangeTaxStatusLoading());
    try {
      final response = await DioHelper.putData(
        url: EndPoint.updateTax(taxId),
        data: {'status': status},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(
          ChangeTaxStatusSuccess(
            '$name ${status ? "tax now activated" : "tax now deactivated"}',
          ),
        );
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(ChangeTaxStatusError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(ChangeTaxStatusError(errorMessage));
    }
  }

  Future<void> createTax({
    required String name,
    required String taxType,
    required double amount,
    required String arName,
  }) async {
    emit(CreateTaxLoading());
    try {
      var _amount = (taxType == 'fixed') ? amount : amount / 100;
      final data = {
        'name': name,
        'ar_name': arName,
        'amount': _amount,
        'type': taxType,
      };

      final response = await DioHelper.postData(
        url: EndPoint.createTax,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(CreateTaxSuccess('Tax is created successfully'));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(CreateTaxError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(CreateTaxError(errorMessage));
    }
  }

  Future<void> updateTax({
    required String taxId,
    required String name,
    required String taxType,
    required double amount,
    required String arName,
  }) async {
    emit(UpdateTaxLoading());
    try {
      var _amount = (taxType == 'fixed') ? amount : amount / 100;
      final data = {
        'name': name,
        'ar_name': arName,
        'amount': _amount,
        'type': taxType,
      };

      final response = await DioHelper.putData(
        url: EndPoint.updateTax(taxId),
        data: data,
      );

      if (response.statusCode == 200) {
        emit(UpdateTaxSuccess('Tax updated successfully'));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(UpdateTaxError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(UpdateTaxError(errorMessage));
    }
  }

  Future<void> deleteTax(String taxId) async {
    emit(DeleteTaxLoading());
    try {
      final response = await DioHelper.deleteData(
        url: EndPoint.deleteTax(taxId),
      );

      if (response.statusCode == 200) {
        allTaxes.removeWhere((tax) => tax.id == taxId);
        emit(DeleteTaxSuccess('Tax deleted successfully'));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(DeleteTaxError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(DeleteTaxError(errorMessage));
    }
  }
}
