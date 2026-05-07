import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../model/expences_categories_model.dart';

/// Interface for expense category data operations
abstract class ExpenseCategoryRepositoryInterface {
  Future<List<ExpenseCategoryModel>> getExpenseCategories();
  Future<void> createExpenseCategory({
    required String name,
    required bool status,
  });
  Future<void> updateExpenseCategory({
    required String categoryId,
    required String name,
    required bool status,
  });
  Future<void> deleteExpenseCategory(String categoryId);
}

/// Repository implementation using Supabase for expense categories
class ExpenseCategoryRepository implements ExpenseCategoryRepositoryInterface {
  final _ExpenseCategorySupabaseDataSource _dataSource = _ExpenseCategorySupabaseDataSource();

  @override
  Future<List<ExpenseCategoryModel>> getExpenseCategories() => _dataSource.getExpenseCategories();

  @override
  Future<void> createExpenseCategory({
    required String name,
    required bool status,
  }) => _dataSource.createExpenseCategory(name: name, status: status);

  @override
  Future<void> updateExpenseCategory({
    required String categoryId,
    required String name,
    required bool status,
  }) => _dataSource.updateExpenseCategory(
        categoryId: categoryId,
        name: name,
        status: status,
      );

  @override
  Future<void> deleteExpenseCategory(String categoryId) => _dataSource.deleteExpenseCategory(categoryId);
}

/// Supabase implementation for ExpenseCategory data source
class _ExpenseCategorySupabaseDataSource implements ExpenseCategoryRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<List<ExpenseCategoryModel>> getExpenseCategories() async {
    try {
      log('ExpenseCategorySupabase: Fetching all expense categories');
      final response = await _client.from('expense_categories').select().order('name');
      return (response as List).map((json) => _mapSupabaseToExpenseCategoryModel(json)).toList();
    } catch (e) {
      log('ExpenseCategorySupabase: Error fetching expense categories - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> createExpenseCategory({
    required String name,
    required bool status,
  }) async {
    try {
      log('ExpenseCategorySupabase: Creating expense category: $name');
      await _client.from('expense_categories').insert({
        'name': name,
        'status': status,
      });
    } catch (e) {
      log('ExpenseCategorySupabase: Error creating expense category - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> updateExpenseCategory({
    required String categoryId,
    required String name,
    required bool status,
  }) async {
    try {
      log('ExpenseCategorySupabase: Updating expense category: $categoryId');
      await _client.from('expense_categories').update({
        'name': name,
        'status': status,
      }).eq('id', categoryId);
    } catch (e) {
      log('ExpenseCategorySupabase: Error updating expense category - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteExpenseCategory(String categoryId) async {
    try {
      log('ExpenseCategorySupabase: Deleting expense category: $categoryId');
      await _client.from('expense_categories').delete().eq('id', categoryId);
    } catch (e) {
      log('ExpenseCategorySupabase: Error deleting expense category - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  ExpenseCategoryModel _mapSupabaseToExpenseCategoryModel(Map<String, dynamic> json) {
    return ExpenseCategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? true,
      version: json['version'] ?? 1,
      createdAt: json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}
