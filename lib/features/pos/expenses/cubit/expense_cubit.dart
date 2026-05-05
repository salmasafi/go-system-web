import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/utils/error_handler.dart';
import 'package:GoSystem/features/pos/expenses/model/expense_model.dart';
import 'package:GoSystem/features/admin/expences_category/model/expences_categories_model.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

part 'expense_state.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  ExpenseCubit() : super(ExpenseInitial());

  final SupabaseClient _client = SupabaseClientWrapper.instance;
  List<ExpenseCategoryModel> categories = [];
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

  Future<void> getExpenses() async {
    emit(ExpensesLoading());
    try {
      final response = await _client
          .from('expenses')
          .select('''
            *,
            category:category_id(id, name),
            bank_account:financial_account_id(id, name)
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
  }) async {
    emit(ExpenseSubmitting());
    try {
      await _client.from('expenses').insert({
        'name': name,
        'category_id': categoryId,
        'amount': double.tryParse(amount) ?? 0.0,
        'note': note,
        'financial_account_id': financialAccountId,
        'status': true,
      });
      
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
  }) async {
    emit(ExpenseSubmitting());
    try {
      await _client.from('expenses').update({
        'name': name,
        'category_id': categoryId,
        'amount': double.tryParse(amount) ?? 0.0,
        'note': note,
        'financial_account_id': financialAccountId,
      }).eq('id', id);
      
      emit(ExpenseSuccess());
      await getExpenses();
    } catch (e) {
      log('updateExpense error: $e');
      emit(ExpenseError(ErrorHandler.handleError(e)));
    }
  }
}
