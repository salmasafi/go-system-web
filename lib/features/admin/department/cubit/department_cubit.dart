import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/features/admin/department/model/department_model.dart';
import 'package:systego/features/admin/department/data/repositories/department_repository.dart';
part 'department_state.dart';

class DepartmentCubit extends Cubit<DepartmentState> {
  final DepartmentRepository _repository;
  DepartmentCubit(this._repository) : super(DepartmentInitial());

  List<DepartmentModel> allDepartments = [];

  Future<void> getAllDepartments() async {
    emit(GetDepartmentsLoading());
    try {
      final departments = await _repository.getAllDepartments();
      allDepartments = departments;
      emit(GetDepartmentsSuccess(departments));
    } catch (e) {
      emit(GetDepartmentsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> addDepartment({
    required String name,
    required String description,
    required String arName,
    required String arDescription,
  }) async {
    emit(CreateDepartmentLoading());
    try {
      await _repository.addDepartment(
        name: name,
        description: description,
        arName: arName,
        arDescription: arDescription,
      );
      emit(CreateDepartmentSuccess("Department created successfully"));
      getAllDepartments();
    } catch (e) {
      emit(CreateDepartmentError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateDepartment({
    required String departmentId,
    required String name,
    required String description,
    required String arName,
    required String arDescription,
  }) async {
    emit(UpdateDepartmentLoading());
    try {
      await _repository.updateDepartment(
        id: departmentId,
        name: name,
        description: description,
        arName: arName,
        arDescription: arDescription,
      );
      emit(UpdateDepartmentSuccess("Department updated successfully"));
      getAllDepartments();
    } catch (e) {
      emit(UpdateDepartmentError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteDepartment(String departmentId) async {
    emit(DeleteDepartmentLoading());
    try {
      await _repository.deleteDepartment(departmentId);
      allDepartments.removeWhere((dep) => dep.id == departmentId);
      emit(DeleteDepartmentSuccess("Department deleted successfully"));
    } catch (e) {
      emit(DeleteDepartmentError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
