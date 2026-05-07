import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/utils/error_handler.dart';
import 'package:GoSystem/features/pos/expenses/model/expense_model.dart';
import 'package:GoSystem/features/admin/expences_category/model/expences_categories_model.dart';
import 'package:GoSystem/features/admin/reason/model/reason_model.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

part 'expense_state.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  ExpenseCubit() : super(ExpenseInitial());

  final SupabaseClient _client = SupabaseClientWrapper.instance;
  List<ExpenseCategoryModel> categories = [];
  List<ReasonModel> reasons = [];
  List<ExpenseModel> expenses = [];

  Future<void> getCategories() async {
    emit(ExpenseCategoriesLoading());
    try {
      final response = await _client
          .from('expense_categories')
          .select()
          .eq('status', true)
          .order('name');
          
      categories = (response as List).map((e) => ExpenseCategoryModel.fromJson(e)).toList();
      emit(ExpenseCategoriesLoaded(categories));
    } catch (e) {
      log('getCategories error: $e');
      emit(ExpenseError(ErrorHandler.handleError(e)));
    }
  }

  Future<void> getReasons() async {
    emit(ExpenseReasonsLoading());
    try {
      final response = await _client
          .from('reasons')
          .select()
          .eq('status', true)
          .order('reason');
          
      reasons = (response as List).map((e) => ReasonModel.fromJson(e)).toList();
      emit(ExpenseReasonsLoaded(reasons));
    } catch (e) {
      log('getReasons error: $e');
      emit(ExpenseError(ErrorHandler.handleError(e)));
    }
  }

  Future<void> getExpenses() async {
    emit(ExpensesLoading());
    try {
      final response = await _client
          .from('expenses')
          .select('''
            *,
            category:category_id(id, name),
            bank_account:bank_account_id(id, name),
            reason:reason_id(id, name, reason)
          ''')
          .eq('status', true)
          .order('created_at', ascending: false);
          
      expenses = (response as List).map((e) => ExpenseModel.fromJson(e)).toList();
      emit(ExpensesLoaded(expenses));
    } catch (e) {
      log('getExpenses error: $e');
      emit(ExpenseError(ErrorHandler.handleError(e)));
    }
  }

  Future<void> addExpense({
    required String name,
    required String categoryId,
    required String amount,
    required String note,
    required String financialAccountId,
    String? reasonId,
  }) async {
    emit(ExpenseSubmitting());
    try {
      final insertData = <String, dynamic>{
        'name': name,
        'category_id': categoryId,
        'amount': double.tryParse(amount) ?? 0.0,
        'note': note,
        'bank_account_id': financialAccountId,
        'status': true,
      };
      
      if (reasonId != null && reasonId.isNotEmpty) {
        insertData['reason_id'] = reasonId;
      }
      
      await _client.from('expenses').insert(insertData);
      
      emit(ExpenseSuccess());
      await getExpenses();
    } catch (e) {
      log('addExpense error: $e');
      emit(ExpenseError(ErrorHandler.handleError(e)));
    }
  }

  Future<void> updateExpense({
    required String id,
    required String name,
    required String categoryId,
    required String amount,
    required String note,
    required String financialAccountId,
    String? reasonId,
  }) async {
    emit(ExpenseSubmitting());
    try {
      final updateData = <String, dynamic>{
        'name': name,
        'category_id': categoryId,
        'amount': double.tryParse(amount) ?? 0.0,
        'note': note,
        'bank_account_id': financialAccountId,
        'reason_id': (reasonId != null && reasonId.isNotEmpty) ? reasonId : null,
      };
      
      await _client.from('expenses').update(updateData).eq('id', id);
      
      emit(ExpenseSuccess());
      await getExpenses();
    } catch (e) {
      log('updateExpense error: $e');
      emit(ExpenseError(ErrorHandler.handleError(e)));
    }
  }
}
