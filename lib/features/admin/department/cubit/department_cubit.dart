import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/features/admin/department/model/department_model.dart';

part 'department_state.dart';

class DepartmentCubit extends Cubit<DepartmentState> {
  DepartmentCubit() : super(DepartmentInitial());

  List<DepartmentModel> allDepartments = [];


  Future<void> getAllDepartments() async {
    emit(GetDepartmentsLoading());
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getAllDepartments,
      );

      log(response.data.toString());

      if (response.statusCode == 200) {
        final model = DepartmentResponse.fromJson(response.data);

        if (model.success) {
          allDepartments = model.data.departments;
          emit(GetDepartmentsSuccess(model.data.departments));
        } else {
          final errorMessage = ErrorHandler.handleError(response);
          emit(GetDepartmentsError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(GetDepartmentsError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(GetDepartmentsError(errorMessage));
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
      final data = {
        "name": name,
        "description": description,
        "ar_name": arName,
        "ar_description": arDescription,
      };

      final response = await DioHelper.postData(
        url: EndPoint.addDepartment,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(CreateDepartmentSuccess("Department created successfully"));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(CreateDepartmentError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(CreateDepartmentError(errorMessage));
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

      final data = {
        "name": name,
        "description": description,
        "ar_name": arName,
        "ar_description": arDescription,
      };

      final response = await DioHelper.putData(
        url: EndPoint.updateDepartment(departmentId),
        data: data,
      );

      if (response.statusCode == 200) {
        emit(UpdateDepartmentSuccess("Department updated successfully"));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(UpdateDepartmentError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(UpdateDepartmentError(errorMessage));
    }
  }

  Future<void> deleteDepartment(String departmentId) async {
    emit(DeleteDepartmentLoading());
    try {
      final response = await DioHelper.deleteData(
        url: EndPoint.deleteDepartment(departmentId),
      );

      if (response.statusCode == 200) {
        allDepartments.removeWhere((dep) => dep.id == departmentId);
        emit(DeleteDepartmentSuccess("Department deleted successfully"));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(DeleteDepartmentError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(DeleteDepartmentError(errorMessage));
    }
  }

}
