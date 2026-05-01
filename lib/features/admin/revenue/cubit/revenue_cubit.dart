import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/features/admin/revenue/model/revenue_model.dart';
import 'package:systego/features/admin/revenue/model/selection_revenue_model.dart';
import 'package:systego/generated/locale_keys.g.dart';

import 'package:systego/features/admin/revenue/data/repositories/revenue_repository.dart';
part 'revenue_state.dart';

class RevenueCubit extends Cubit<RevenueState> {
  final RevenueRepository _repository;
  RevenueCubit(this._repository) : super(RevenueInitial());

  List<RevenueModel> allRevenues = [];
// Add these lists to persist data across state changes
  List<CategorySelection> selectionCategories = []; 
  List<AccountSelection> selectionAccounts = [];



  Future<void> getSelectionData() async {
    emit(GetSelectionDataLoading());
    try {
      final response = await _repository.getSelectionData();
      log('Selection Data Response: $response');

      final model = RevenueSelectionDataResponse.fromJson(response);

      if (model.success == true) {
        selectionCategories = model.data.categories;
        selectionAccounts = model.data.accounts;
        emit(GetSelectionDataSuccess(selectionCategories, selectionAccounts));
      } else {
        emit(GetSelectionDataError('Failed to fetch selection data'));
      }
    } catch (e) {
      emit(GetSelectionDataError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // ---------------------- Get All Revenues ----------------------
  Future<void> getRevenues() async {
    emit(GetRevenuesLoading());
    try {
      final revenues = await _repository.getAllRevenues();
      allRevenues = revenues.map((e) => e.toLegacyModel()).toList();
      emit(GetRevenuesSuccess(allRevenues));
    } catch (e) {
      emit(GetRevenuesError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // ---------------------- Get Revenue By ID ----------------------
  Future<void> getRevenueById(String revenueId) async {
    emit(GetRevenueByIdLoading());
    try {
      final revenue = await _repository.getRevenueById(revenueId);
      if (revenue != null) {
        emit(GetRevenueByIdSuccess(revenue.toLegacyModel()));
      } else {
        emit(GetRevenueByIdError(LocaleKeys.error_occurred.tr()));
      }
    } catch (e) {
      emit(GetRevenueByIdError(e.toString().replaceAll('Exception: ', '')));
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
      await _repository.createRevenue(
        categoryId: categoryId,
        bankAccountId: financialAccountId,
        amount: amount,
        description: name,
        receiptNumber: note,
      );
      emit(
        CreateRevenueSuccess(LocaleKeys.revenue_created_successfully.tr()),
      );
      await getRevenues();
    } catch (e) {
      emit(CreateRevenueError(e.toString().replaceAll('Exception: ', '')));
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
      final updated = await _repository.updateRevenue(
        id: revenueId,
        categoryId: categoryId,
        bankAccountId: financialAccountId,
        amount: amount,
        description: name,
        receiptNumber: note,
      );

      // Update the local list
      final index = allRevenues.indexWhere((r) => r.id == revenueId);
      if (index != -1) {
        allRevenues[index] = updated.toLegacyModel();
      }
      
      emit(
        UpdateRevenueSuccess(LocaleKeys.revenue_updated_successfully.tr()),
      );
      await getRevenues();
    } catch (e) {
      emit(UpdateRevenueError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

