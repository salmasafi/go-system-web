import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/features/admin/permission/model/permission_model.dart';

import 'package:systego/features/admin/permission/data/repositories/permission_repository.dart';

part 'permission_state.dart';

class PermissionCubit extends Cubit<PermissionState> {
  final PermissionRepository _repository;
  PermissionCubit(this._repository) : super(PermissionInitial());

  List<PermissionModel> allPermissions = [];

  Future<void> getAllPermissions() async {
    emit(GetPermissionsLoading());
    try {
      final permissions = await _repository.getAllPermissions();
      allPermissions = permissions;
      emit(GetPermissionsSuccess(permissions));
    } catch (e) {
      emit(GetPermissionsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createPermission({
    required String name,
    required List<RoleModel> roles,
  }) async {
    emit(CreatePermissionLoading());
    try {
      await _repository.createPermission(name: name, roles: roles);
      emit(CreatePermissionSuccess("Permission created successfully"));
      getAllPermissions();
    } catch (e) {
      emit(CreatePermissionError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updatePermission({
    required String id,
    required String name,
    required List<RoleModel> roles,
  }) async {
    emit(UpdatePermissionLoading());
    try {
      await _repository.updatePermission(id: id, name: name, roles: roles);
      emit(UpdatePermissionSuccess("Permission updated successfully"));
      getAllPermissions();
    } catch (e) {
      emit(UpdatePermissionError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deletePermission(String id) async {
    emit(DeletePermissionLoading());
    try {
      await _repository.deletePermission(id);
      allPermissions.removeWhere((p) => p.id == id);
      emit(DeletePermissionSuccess("Permission deleted successfully"));
    } catch (e) {
      emit(DeletePermissionError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> getPermissionById(String id) async {
    emit(GetPermissionByIdLoading());
    try {
      final permission = await _repository.getPermissionById(id);
      if (permission != null) {
        emit(GetPermissionByIdSuccess(permission));
      } else {
        emit(GetPermissionByIdError("Permission not found"));
      }
    } catch (e) {
      emit(GetPermissionByIdError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

