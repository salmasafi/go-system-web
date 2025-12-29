import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:meta/meta.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/features/admin/roloes_and_permissions/model/role_model.dart';
import 'package:systego/generated/locale_keys.g.dart';

part 'roles_state.dart';

class RolesCubit extends Cubit<RolesState> {
  RolesCubit() : super(RolesInitial());

  // ================= GET ALL ROLES =================
  Future<void> getAllRoles() async {
    emit(RolesLoading());
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getAllRoles, // Make sure this endpoint exists
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final jsonData = data is String ? json.decode(data) : data;

         log('API Response: ${jsonEncode(jsonData)}');
      log('Success field type: ${jsonData['success'].runtimeType}');
      log('Success field value: ${jsonData['success']}');
        
        // Parse the response based on your RoleResponse model
        final roleResponse = RoleResponse.fromJson(jsonData);
        emit(RolesLoaded(roleResponse.data.roles));
      } else {
        emit(RolesError(LocaleKeys.roles_load_failed.tr()));
      }
    } catch (e) {
      log('Error getting roles: $e');
      emit(RolesError(e.toString()));
    }
  }


  // ================= GET USER'S ROLES/Permissions =================
  Future<void> getUserRoles(String userId) async {
    emit(RolesLoading());
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getUserPermissions(userId),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final jsonData = data is String ? json.decode(data) : data;
        
        // Assuming the endpoint returns a list of roles for the user
        final roles = (jsonData['data'] as List)
            .map((roleJson) => RoleModel.fromJson(roleJson))
            .toList();
        
        emit(RolesLoaded(roles));
      } else {
        emit(RolesError(LocaleKeys.roles_load_failed.tr()));
      }
    } catch (e) {
      log('Error getting user roles: $e');
      emit(RolesError(e.toString()));
    }
  }

  // ================= UPDATE ROLE =================
  Future<void> updateRole({
    required String roleId,
    required String? name,
    required String? status,
    required List<Permission> permissions,
  }) async {
    emit(RolesUpdating());
    try {
      final data = {
        if (name != null) 'name': name,
        if (status != null) 'status': status,
        'permissions': permissions
            .map((p) => {
                  'module': p.module,
                  'actions': p.actions.map((a) => a.toJson()).toList(),
                })
            .toList(),
      };

      log("edited data ${data}");

      final response = await DioHelper.putData(
        url: EndPoint.updateRole(roleId), // Changed from updatepermission
        data: data,
      );

      if (response.statusCode == 200) {
        emit(RolesUpdateSuccess(LocaleKeys.role_updated.tr()));
        // Refresh the roles list after update
        getAllRoles();
      } else {
        emit(RolesUpdateError(LocaleKeys.role_update_failed.tr()));
      }
    } catch (e) {
      emit(RolesUpdateError(e.toString()));
    }
  }

  // ================= CREATE ROLE =================
  Future<void> createRole({
    required String name,
    required String status,
    required List<Permission> permissions,
  }) async {
    emit(RolesCreating());
    try {
      final response = await DioHelper.postData(
        url: EndPoint.createRolePermission,
        data: {
          'name': name,
          'status': status,
          'permissions': permissions
              .map((p) => {
                    'module': p.module,
                    'actions': p.actions.map((a) => a.toJson()).toList(),
                  })
              .toList(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(RolesCreateSuccess(LocaleKeys.role_created.tr()));
        // Refresh the roles list after creation
        getAllRoles();
      } else {
        emit(RolesCreateError(LocaleKeys.role_create_failed.tr()));
      }
    } catch (e) {
      emit(RolesCreateError(e.toString()));
    }
  }

  // ================= DELETE ROLE =================
  Future<void> deleteRole({
    required String roleId,
  }) async {
    emit(RolesDeleting());
    try {
      final response = await DioHelper.deleteData(
        url: EndPoint.deleteRole(roleId),
      );

      if (response.statusCode == 200) {
        emit(RolesDeleteSuccess(LocaleKeys.role_deleted.tr()));
        // Refresh the roles list after deletion
        getAllRoles();
      } else {
        emit(RolesDeleteError(LocaleKeys.role_delete_failed.tr()));
      }
    } catch (e) {
      emit(RolesDeleteError(e.toString()));
    }
  }
}