import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/migration/migration_service.dart';
import '../../../../../core/services/dio_helper.dart';
import '../../../../../core/services/endpoints.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../../../../core/utils/error_handler.dart';
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

/// Hybrid repository that supports both Dio and Supabase for departments
class DepartmentRepository implements DepartmentRepositoryInterface {
  late final DepartmentRepositoryInterface _dataSource;

  DepartmentRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('departments')) {
      log('DepartmentRepository: Using Supabase');
      _dataSource = _DepartmentSupabaseDataSource();
    } else {
      log('DepartmentRepository: Using Dio (legacy)');
      _dataSource = _DepartmentDioDataSource();
    }
  }

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
      arName: json['ar_name'] ?? '',
      arDescription: json['ar_description'] ?? '',
      v: json['version'] ?? 1,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
    );
  }
}

/// Dio implementation for Department data source (legacy)
class _DepartmentDioDataSource implements DepartmentRepositoryInterface {
  @override
  Future<List<DepartmentModel>> getAllDepartments() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.getAllDepartments);
      if (response.statusCode == 200) {
        final model = DepartmentResponse.fromJson(response.data);
        return model.data.departments;
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
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
      final response = await DioHelper.postData(
        url: EndPoint.addDepartment,
        data: {
          'name': name,
          'description': description,
          'ar_name': arName,
          'ar_description': arDescription,
        },
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
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
      final response = await DioHelper.putData(
        url: EndPoint.updateDepartment(id),
        data: {
          'name': name,
          'description': description,
          'ar_name': arName,
          'ar_description': arDescription,
        },
      );
      if (response.statusCode != 200) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteDepartment(String id) async {
    try {
      final response = await DioHelper.deleteData(url: EndPoint.deleteDepartment(id));
      if (response.statusCode != 200) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }
}
