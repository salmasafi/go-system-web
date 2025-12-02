import 'dart:developer' as dev;
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
    required XFile? icon,
    required bool status,
  }) async {
    emit(CreateBankAccountLoading());
    try {
      String? base64Image;
      if (icon != null) {
        base64Image = await convertImageToBase64(icon);
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
  }) async {
    emit(UpdateBankAccountLoading());
    try {
      

      final data = <String, dynamic>{
        'name': name,
        'ar_name': arName,
        'account_no': accountNumber,
        'initial_balance': initialBalance,
        'is_default': status,
        'note': note,
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

  // Future<String?> convertImageToBase64(XFile imageFile) async {
  //   try {
  //     final bytes = await imageFile.readAsBytes();
  //     final base64Image = 'data:image/png;base64,${base64Encode(bytes)}';
  //     return base64Image;
  //   } catch (e) {
  //     log('Error converting image: $e');
  //     return null;
  //   }
  // }

  Future<String?> convertImageToBase64(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();

      final mimeType = imageFile.path.endsWith(".png")
          ? "image/png"
          : "image/jpeg";

      return "data:$mimeType;base64,${base64Encode(bytes)}";
    } catch (e) {
      dev.log("Error converting image: $e");
      return null;
    }
  }

  // Future<String?> convertImageToBase64(XFile imageFile) async {
  //   try {
  //     dev.log("Converting image: ${imageFile.path}");
  //     dev.log("File size: ${await imageFile.length()}");

  //     final bytes = await imageFile.readAsBytes();
  //     dev.log("Bytes length: ${bytes.length}");

  //     // Determine mime type properly
  //     String mimeType;
  //     if (imageFile.path.toLowerCase().endsWith('.png')) {
  //       mimeType = 'image/png';
  //     } else if (imageFile.path.toLowerCase().endsWith('.jpg') ||
  //         imageFile.path.toLowerCase().endsWith('.jpeg')) {
  //       mimeType = 'image/jpeg';
  //     } else if (imageFile.path.toLowerCase().endsWith('.gif')) {
  //       mimeType = 'image/gif';
  //     } else if (imageFile.path.toLowerCase().endsWith('.webp')) {
  //       mimeType = 'image/webp';
  //     } else {
  //       mimeType = 'image/jpeg'; // default
  //     }

  //     final base64String = base64Encode(bytes);
  //     final fullBase64 = 'data:$mimeType;base64,$base64String';

  //     dev.log(
  //       "Base64 string created (first 100 chars): ${fullBase64.substring(0, math.min(100, fullBase64.length))}...",
  //     );

  //     return fullBase64;
  //   } catch (e, stackTrace) {
  //     dev.log("Error converting image: $e");
  //     dev.log("Stack trace: $stackTrace");
  //     return null;
  //   }
  // }
}
