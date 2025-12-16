import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/features/admin/admins_screen/model/permission_model.dart';

part 'permissions_state.dart';

class PermissionsCubit extends Cubit<PermissionsState> {
  PermissionsCubit() : super(PermissionsInitial());

  // ================= GET PERMISSIONS =================
  Future<void> getUserPermissions(String userId) async {
    emit(PermissionsLoading());
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getUserPermissions(userId),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        final jsonData = data is String ? json.decode(data) : data;
        final permissions =
            AdminPermissionsModel.fromJson(jsonData['data']);

        emit(PermissionsLoaded(permissions));
      } else {
        emit(PermissionsError('Failed to load permissions'));
      }
    } catch (e) {
      log('Error getting permissions: $e');
      emit(PermissionsError(e.toString()));
    }
  }

  // ================= UPDATE PERMISSIONS =================
  Future<void> updatePermissions({
    required String userId,
    required List<ModulePermission> permissions,
  }) async {
    emit(PermissionsUpdating());
    try {
      final data = {
        'permissions': permissions
            .map((p) => {
                  'module': p.module,
                  'actions': p.actions,
                })
            .toList(),
      };

      final response = await DioHelper.putData(
        url: EndPoint.updatepermission(userId),
        data: data,
      );

      if (response.statusCode == 200) {
        emit(PermissionsUpdateSuccess(
            'Permissions updated successfully'));
      } else {
        emit(PermissionsUpdateError('Failed to update permissions'));
      }
    } catch (e) {
      emit(PermissionsUpdateError(e.toString()));
    }
  }
}
