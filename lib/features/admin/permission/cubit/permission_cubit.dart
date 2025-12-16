import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/features/admin/permission/model/permission_model.dart';

part 'permission_state.dart';

class PermissionCubit extends Cubit<PermissionState> {
  PermissionCubit() : super(PermissionInitial());

  List<PermissionModel> allPermissions = [];


  Future<void> getAllPermissions() async {
    emit(GetPermissionsLoading());
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getAllpermissions,
      );

      log(response.data.toString());

      if (response.statusCode == 200) {
        final model = PermissionResponse.fromJson(response.data);

        if (model.success) {
          allPermissions = model.data.permisions;
          emit(GetPermissionsSuccess(model.data.permisions));
        } else {
          final error = ErrorHandler.handleError(response);
          emit(GetPermissionsError(error));
        }
      } else {
        final error = ErrorHandler.handleError(response);
        emit(GetPermissionsError(error));
      }
    } catch (e) {
      final error = ErrorHandler.handleError(e);
      emit(GetPermissionsError(error));
    }
  }

  Future<void> createPermission({
    required String name,
    required List<RoleModel> roles,
  }) async {
    emit(CreatePermissionLoading());
    try {
      final data = {
        "name": name,
        "roles": roles.map((e) => e.toJson()).toList(),
      };

      final response = await DioHelper.postData(
        url: EndPoint.addpermission,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(CreatePermissionSuccess("Permission created successfully"));
      } else {
        final error = ErrorHandler.handleError(response);
        emit(CreatePermissionError(error));
      }
    } catch (e) {
      final error = ErrorHandler.handleError(e);
      emit(CreatePermissionError(error));
    }
  }

  Future<void> updatePermission({
    required String id,
    required String name,
    required List<RoleModel> roles,
  }) async {
    emit(UpdatePermissionLoading());
    try {
      final data = {
        "name": name,
        "roles": roles.map((e) => e.toJson()).toList(),
      };

      final response = await DioHelper.putData(
        url: EndPoint.updatepermission(id),
        data: data,
      );

      if (response.statusCode == 200) {
        emit(UpdatePermissionSuccess("Permission updated successfully"));
      } else {
        final error = ErrorHandler.handleError(response);
        emit(UpdatePermissionError(error));
      }
    } catch (e) {
      final error = ErrorHandler.handleError(e);
      emit(UpdatePermissionError(error));
    }
  }


  Future<void> deletePermission(String id) async {
    emit(DeletePermissionLoading());
    try {
      final response = await DioHelper.deleteData(
        url: EndPoint.deletepermission(id),
      );

      if (response.statusCode == 200) {
        allPermissions.removeWhere((p) => p.id == id);
        emit(DeletePermissionSuccess("Permission deleted successfully"));
      } else {
        final error = ErrorHandler.handleError(response);
        emit(DeletePermissionError(error));
      }
    } catch (e) {
      final error = ErrorHandler.handleError(e);
      emit(DeletePermissionError(error));
    }
  }

  Future<void> getPermissionById(String id) async {
    emit(GetPermissionByIdLoading());
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getUserPermissions(id),
      );

      if (response.statusCode == 200) {
        // final model = SinglePositionResponse.fromJson(response.data);
        // emit(GetPermissionByIdSuccess(model.data));
      } else {
        final error = ErrorHandler.handleError(response);
        emit(GetPermissionByIdError(error));
      }
    } catch (e) {
      final error = ErrorHandler.handleError(e);
      emit(GetPermissionByIdError(error));
    }
  }
}
