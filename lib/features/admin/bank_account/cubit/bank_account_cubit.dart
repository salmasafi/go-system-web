import 'dart:developer' as dev;
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/features/admin/bank_account/model/bank_account_model.dart';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'bank_accounts_state.dart';

class BankAccountCubit extends Cubit<BankAccountState> {
  BankAccountCubit() : super(BankAccountInitial());

  List<BankAccountModel> allAccounts = [];

  Future<void> getBankAccounts() async {
    emit(GetBankAccountsLoading());
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getAllBankAccounts,
      );
      dev.log(response.data.toString());
      if (response.statusCode == 200) {
        final model = BankAccountResponse.fromJson(response.data);
        if (model.success) {
          allAccounts = model.data.accounts;
          emit(GetBankAccountsSuccess(model.data.accounts));
        } else {
          final errorMessage = ErrorHandler.handleError(response);
          emit(GetBankAccountsError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(GetBankAccountsError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(GetBankAccountsError(errorMessage));
    }
  }

  Future<void> selectBankAccount(String accountId, String name) async {
    emit(SelectBankAccountLoading());
    try {
      final response = await DioHelper.putData(
        url: EndPoint.updateBankAccount(accountId),
        data: {'is_default': true},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(
          SelectBankAccountSuccess(
            '$name ${"is now the default bank account"}',
          ),
        );
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(SelectBankAccountError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(SelectBankAccountError(errorMessage));
    }
  }

  Future<void> addBankAccount({
    required String name,
    required String arName,
    required String accountNumber,
    required double initialBalance,
    required String note,
    required File? icon,
    required bool status,
  }) async {
    emit(CreateBankAccountLoading());
    try {
      String? base64Image;
      if (icon != null) {
        base64Image = await _convertFileToBase64(icon);
      }

      final data = {
        'name': name,
        'ar_name': arName,
        'account_no': accountNumber,
        'initial_balance': initialBalance,
        'is_default': status,
        'note': note,
        if (base64Image != null) 'icon': base64Image,
        
      };

      dev.log('base64Image when add: $base64Image');

      final response = await DioHelper.postData(
        url: EndPoint.addBankAccount,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(CreateBankAccountSuccess('Bank account created successfully'));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(CreateBankAccountError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(CreateBankAccountError(errorMessage));
    }
  }

  Future<void> updateBankAccount({
    required String accountId,
    required String name,
    required String arName,
    required String accountNumber,
    required double initialBalance,
    required String note,
    required bool status,
    required File? icon,
  }) async {
    emit(UpdateBankAccountLoading());
    try {

      String? base64Icon;

      if (icon != null) {
        base64Icon = await _convertFileToBase64(icon);
      }
      

      final data = <String, dynamic>{
        'name': name,
        'ar_name': arName,
        'account_no': accountNumber,
        'initial_balance': initialBalance,
        'is_default': status,
        'note': note,
        if (base64Icon != null) "icon": base64Icon,
      };

      dev.log('Sending data: $data');



      final response = await DioHelper.putData(
        url: EndPoint.updateBankAccount(accountId),
        data: data,
      );

      if (response.statusCode == 200) {
        emit(UpdateBankAccountSuccess('Bank account updated successfully'));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(UpdateBankAccountError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(UpdateBankAccountError(errorMessage));
    }
  }

  Future<void> deleteBankAccount(String accountId) async {
    emit(DeleteBankAccountLoading());
    try {
      final response = await DioHelper.deleteData(
        url: EndPoint.deleteBankAccount(accountId),
      );

      if (response.statusCode == 200) {
        allAccounts.removeWhere((account) => account.id == accountId);
        emit(DeleteBankAccountSuccess('Bank account deleted successfully'));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(DeleteBankAccountError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(DeleteBankAccountError(errorMessage));
    }
  }



   Future<String?> _convertFileToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      
      String? mimeType;
      final ext = imageFile.path.toLowerCase().split('.').last;
      if (ext == 'png') {
        mimeType = "image/png";
      } else if (ext == 'jpg' || ext == 'jpeg') {
        mimeType = "image/jpeg";
      } else {
        mimeType = "application/octet-stream";
      }

      return "data:$mimeType;base64,${base64Encode(bytes)}";
    } catch (e) {
      dev.log("Error converting image: $e");
      return null;
    }
  }

}
