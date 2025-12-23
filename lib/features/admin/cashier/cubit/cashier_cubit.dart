import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:meta/meta.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/generated/locale_keys.g.dart';
import 'package:systego/features/admin/cashier/model/cashirer_model.dart';


part 'cashier_state.dart';

class CashierCubit extends Cubit<CashierState> {
  CashierCubit() : super(CashierInitial());

  List<CashierModel> allCashiers = [];

  Future<void> getCashiers() async {
    emit(GetCashiersLoading());
    try {
      final response = await DioHelper.getData(url: EndPoint.getAllCashiers);
      log(response.data.toString());

      if (response.statusCode == 200) {
        final model = CashierResponse.fromJson(response.data);

        if (model.success == true) {
          allCashiers = model.data.cashiers;
          emit(GetCashiersSuccess(model.data.cashiers));
        } else {
          final errorMessage = ErrorHandler.handleError(response);
          emit(GetCashiersError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(GetCashiersError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(GetCashiersError(errorMessage));
    }
  }

  Future<void> createCashier({
    required String name,
    required String arName,
    String? warehouseId,
    required bool status,
    required bool cashierActive,
  }) async {
    emit(CreateCashierLoading());

    try {
      final data = {
        "name": name,
        "ar_name": arName,
        "warehouse_id": warehouseId,
        "status": status,
        "cashier_active": cashierActive,
      };

      final response =
          await DioHelper.postData(url: EndPoint.createCashier, data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(CreateCashierSuccess(
        LocaleKeys.cashier_created_success.tr()
          ));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(CreateCashierError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(CreateCashierError(errorMessage));
    }
  }

  Future<void> updateCashier({
    required String cashierId,
    required String name,
    required String arName,
   String? warehouseId,
    required bool status,
    required bool cashierActive,
  }) async {
    emit(UpdateCashierLoading());

    try {
      final data = {
        "name": name,
        "ar_name": arName,
        "warehouse_id": warehouseId,
        "status": status,
        "cashier_active": cashierActive,
      };

      final response = await DioHelper.putData(
        url: EndPoint.updateCashier(cashierId),
        data: data,
      );

      log("data updating: ${data}");

      if (response.statusCode == 200) {
        emit(UpdateCashierSuccess(LocaleKeys.cashier_updated_success.tr()));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(UpdateCashierError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(UpdateCashierError(errorMessage));
    }
  }

  Future<void> deleteCashier(String cashierId) async {
    emit(DeleteCashierLoading());

    try {
      final response =
          await DioHelper.deleteData(url: EndPoint.deleteCashier(cashierId));

      if (response.statusCode == 200) {
        allCashiers.removeWhere((c) => c.id == cashierId);
        emit(DeleteCashierSuccess(LocaleKeys.cashier_deleted_success.tr()));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(DeleteCashierError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(DeleteCashierError(errorMessage));
    }
  }

  // // Additional method to toggle cashier active status
  // Future<void> toggleCashierStatus({
  //   required String cashierId,
  //   required bool isActive,
  // }) async {
  //   emit(ToggleCashierStatusLoading());

  //   try {
  //     final data = {
  //       "cashier_active": isActive,
  //     };

  //     final response = await DioHelper.patchData(
  //       url: EndPoint.toggleCashierStatus(cashierId),
  //       data: data,
  //     );

  //     if (response.statusCode == 200) {
  //       // Update the local cashier list
  //       final index = allCashiers.indexWhere((c) => c.id == cashierId);
  //       if (index != -1) {
  //         allCashiers[index] = allCashiers[index].copyWith(
  //           cashierActive: isActive,
  //           updatedAt: DateTime.now().toIso8601String(),
  //         );
  //       }
  //       emit(ToggleCashierStatusSuccess(isActive));
  //     } else {
  //       final errorMessage = ErrorHandler.handleError(response);
  //       emit(ToggleCashierStatusError(errorMessage));
  //     }
  //   } catch (e) {
  //     final errorMessage = ErrorHandler.handleError(e);
  //     emit(ToggleCashierStatusError(errorMessage));
  //   }
  // }

  // // Optional: Add methods to manage users and bank accounts for cashiers
  // Future<void> assignUserToCashier({
  //   required String cashierId,
  //   required String userId,
  // }) async {
  //   emit(AssignUserLoading());

  //   try {
  //     final data = {
  //       "user_id": userId,
  //     };

  //     final response = await DioHelper.postData(
  //       url: EndPoint.assignUserToCashier(cashierId),
  //       data: data,
  //     );

  //     if (response.statusCode == 200) {
  //       emit(AssignUserSuccess(LocaleKeys.user_assigned_success.tr()));
  //     } else {
  //       final errorMessage = ErrorHandler.handleError(response);
  //       emit(AssignUserError(errorMessage));
  //     }
  //   } catch (e) {
  //     final errorMessage = ErrorHandler.handleError(e);
  //     emit(AssignUserError(errorMessage));
  //   }
  // }

  // Future<void> removeUserFromCashier({
  //   required String cashierId,
  //   required String userId,
  // }) async {
  //   emit(RemoveUserLoading());

  //   try {
  //     final response = await DioHelper.deleteData(
  //       url: EndPoint.removeUserFromCashier(cashierId, userId),
  //     );

  //     if (response.statusCode == 200) {
  //       emit(RemoveUserSuccess(LocaleKeys.user_removed_success.tr()));
  //     } else {
  //       final errorMessage = ErrorHandler.handleError(response);
  //       emit(RemoveUserError(errorMessage));
  //     }
  //   } catch (e) {
  //     final errorMessage = ErrorHandler.handleError(e);
  //     emit(RemoveUserError(errorMessage));
  //   }
  // }
}