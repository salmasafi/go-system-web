import 'dart:developer' as dev;
import 'dart:io';
import 'package:bloc/bloc.dart';
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
  int totalBalance = 0;

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
          emit(GetBankAccountsSuccess(allAccounts));
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
     required String wareHouseId,
    required String description,
    required double balance,
    required File? image,
    required bool status,
    required bool inPos,
  }) async {
    emit(CreateBankAccountLoading());
    try {
      String? base64Image;
      if (image != null) {
        base64Image = await _convertFileToBase64(image);
      }

      final data = {
        'name': name,
        'balance': balance,
        'status': status,
        'in_POS': inPos,
        'description': description,
        'warehouseId': wareHouseId,
        if (base64Image != null) 'image': base64Image,
        
      };

      // log("${data}");

      // dev.log('base64Image when add: $base64Image');

      final response = await DioHelper.postData(
        url: EndPoint.addBankAccount,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(CreateBankAccountSuccess('Financial account created successfully'));
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
     required String wareHouseId,
    required String description,
    required double balance,
    required File? image,
    required bool status,
    required bool inPos,
  }) async {
    emit(UpdateBankAccountLoading());
    try {

     String? base64Image;
      if (image != null) {
        base64Image = await _convertFileToBase64(image);
      }
      

       final data = {
        'name': name,
        'balance': balance,
        'status': status,
        'in_POS': inPos,
        'description': description,
        'warehouseId': wareHouseId,
        if (base64Image != null) 'image': base64Image,
        
      };

      dev.log('Sending data: $data');



      final response = await DioHelper.putData(
        url: EndPoint.updateBankAccount(accountId),
        data: data,
      );

      if (response.statusCode == 200) {
        emit(UpdateBankAccountSuccess('Financial account updated successfully'));
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
        emit(DeleteBankAccountSuccess('Financial account deleted successfully'));
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
