import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/features/admin/revenue/model/revenue_model.dart';
import 'package:systego/features/admin/revenue/model/selection_revenue_model.dart';
import 'package:systego/generated/locale_keys.g.dart';

part 'revenue_state.dart';

class RevenueCubit extends Cubit<RevenueState> {
  RevenueCubit() : super(RevenueInitial());

  List<RevenueModel> allRevenues = [];
// Add these lists to persist data across state changes
  List<CategorySelection> selectionCategories = []; 
  List<AccountSelection> selectionAccounts = [];



  Future<void> getSelectionData() async {
    emit(GetSelectionDataLoading());
    try {
      final response = await DioHelper.getData(url: EndPoint.getRevenueSelection);
      log('Selection Data Response: ${response.data}');

      if (response.statusCode == 200) {
       
        final model = RevenueSelectionDataResponse.fromJson(response.data);

        if (model.success == true) {
          selectionCategories = model.data.categories;
          selectionAccounts = model.data.accounts;
          emit(GetSelectionDataSuccess(selectionCategories, selectionAccounts));
        } else {
          final errorMessage = ErrorHandler.handleError(response);
          emit(GetSelectionDataError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(GetSelectionDataError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(GetSelectionDataError(errorMessage));
    }
  }

  // ---------------------- Get All Revenues ----------------------
  Future<void> getRevenues() async {
    emit(GetRevenuesLoading());
    try {
      final response = await DioHelper.getData(url: EndPoint.getAllRevenues);
      log(response.data.toString());

      if (response.statusCode == 200) {
        final model = RevenueResponse.fromJson(response.data);

        if (model.success == true) {
          allRevenues = model.data.revenues;
          emit(GetRevenuesSuccess(allRevenues));
        } else {
          final errorMessage = ErrorHandler.handleError(response);
          emit(GetRevenuesError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(GetRevenuesError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(GetRevenuesError(errorMessage));
    }
  }

  // ---------------------- Get Revenue By ID ----------------------
  Future<void> getRevenueById(String revenueId) async {
    emit(GetRevenueByIdLoading());
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getRevenueById(revenueId),
      );

      if (response.statusCode == 200) {
        final model = RevenueModel.fromJson(response.data['data']);
        emit(GetRevenueByIdSuccess(model));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(GetRevenueByIdError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(GetRevenueByIdError(errorMessage));
    }
  }

  Future<void> createRevenue({
    required String name,
    required double amount,
    required String categoryId,
    required String note,
    required String financialAccountId,
  }) async {
    emit(CreateRevenueLoading());
    try {
      final data = {
        "name": name,
        "amount": amount,
        "Category_id": categoryId,
        "note": note,
        "financial_accountId": financialAccountId,
      };

      final response = await DioHelper.postData(
        url: EndPoint.addRevenue,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Optionally refresh the list
        // await getRevenues();
        emit(
          CreateRevenueSuccess(LocaleKeys.revenue_created_successfully.tr()),
        );
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(CreateRevenueError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(CreateRevenueError(errorMessage));
    }
  }

  // ---------------------- Update Revenue ----------------------
  Future<void> updateRevenue({
    required String revenueId,
    required String name,
    required double amount,
    required String categoryId,
    required String note,
    required String financialAccountId,
  }) async {
    emit(UpdateRevenueLoading());
    try {
      final data = {
        "name": name,
        "amount": amount,
        "Category_id": categoryId,
        "note": note,
        "financial_accountId": financialAccountId,
      };


      log("update revenue data ${data}");

      final response = await DioHelper.putData(
        url: EndPoint.updateRevenue(revenueId),
        data: data,
      );

      if (response.statusCode == 200) {
        // Update the local list
        final index = allRevenues.indexWhere((r) => r.id == revenueId);
        if (index != -1) {
          final updatedRevenue = RevenueModel.fromJson(response.data['data']);
          allRevenues[index] = updatedRevenue;
        }
        emit(
          UpdateRevenueSuccess(LocaleKeys.revenue_updated_successfully.tr()),
        );
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(UpdateRevenueError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(UpdateRevenueError(errorMessage));
    }
  }


}