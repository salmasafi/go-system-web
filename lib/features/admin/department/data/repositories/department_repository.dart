import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../model/department_model.dart';

/// Interface for department data operations
abstract class DepartmentRepositoryInterface {
  Future<List<DepartmentModel>> getAllDepartments();
  Future<void> addDepartment({
    required String name,
    required String description,
    required String arName,
    required String arDescription,
  });
  Future<void> updateDepartment({
    required String id,
    required String name,
    required String description,
    required String arName,
    required String arDescription,
  });
  Future<void> deleteDepartment(String id);
}

/// Repository implementation using Supabase for departments
class DepartmentRepository implements DepartmentRepositoryInterface {
  final _DepartmentSupabaseDataSource _dataSource = _DepartmentSupabaseDataSource();

  @override
  Future<List<DepartmentModel>> getAllDepartments() => _dataSource.getAllDepartments();

  @override
  Future<void> addDepartment({
    required String name,
    required String description,
    required String arName,
    required String arDescription,
  }) => _dataSource.addDepartment(
        name: name,
        description: description,
        arName: arName,
        arDescription: arDescription,
      );

  @override
  Future<void> updateDepartment({
    required String id,
    required String name,
    required String description,
    required String arName,
    required String arDescription,
  }) => _dataSource.updateDepartment(
        id: id,
        name: name,
        description: description,
        arName: arName,
        arDescription: arDescription,
      );

  @override
  Future<void> deleteDepartment(String id) => _dataSource.deleteDepartment(id);
}

/// Supabase implementation for Department data source
class _DepartmentSupabaseDataSource implements DepartmentRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<List<DepartmentModel>> getAllDepartments() async {
    try {
      log('DepartmentSupabase: Fetching all departments');
      final response = await _client.from('departments').select().order('name');
      return (response as List).map((json) => _mapSupabaseToDepartmentModel(json)).toList();
    } catch (e) {
      log('DepartmentSupabase: Error fetching departments - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> addDepartment({
    required String name,
    required String description,
    required String arName,
    required String arDescription,
  }) async {
    try {
      log('DepartmentSupabase: Adding department: $name');
      await _client.from('departments').insert({
        'name': name,
        'description': description,
        'ar_name': arName,
        'ar_description': arDescription,
      });
    } catch (e) {
      log('DepartmentSupabase: Error adding department - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> updateDepartment({
    required String id,
    required String name,
    required String description,
    required String arName,
    required String arDescription,
  }) async {
    try {
      log('DepartmentSupabase: Updating department: $id');
      await _client.from('departments').update({
        'name': name,
        'description': description,
        'ar_name': arName,
        'ar_description': arDescription,
      }).eq('id', id);
    } catch (e) {
      log('DepartmentSupabase: Error updating department - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteDepartment(String id) async {
    try {
      log('DepartmentSupabase: Deleting department: $id');
      await _client.from('departments').delete().eq('id', id);
    } catch (e) {
      log('DepartmentSupabase: Error deleting department - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  DepartmentModel _mapSupabaseToDepartmentModel(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      arName: json['ar_name'],
      arDescription: json['ar_description'],
      version: (json['version'] as num?)?.toInt() ?? 1,
      createdAt: json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}
