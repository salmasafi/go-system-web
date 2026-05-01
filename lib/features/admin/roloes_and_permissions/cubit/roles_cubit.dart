import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:meta/meta.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/features/admin/roloes_and_permissions/model/role_model.dart';
import 'package:systego/generated/locale_keys.g.dart';

import 'package:systego/features/admin/roloes_and_permissions/data/repositories/role_repository.dart';

part 'roles_state.dart';

class RolesCubit extends Cubit<RolesState> {
  final RoleRepository _repository;
  RolesCubit(this._repository) : super(RolesInitial());

  // ================= GET ALL ROLES =================
  Future<void> getAllRoles() async {
    emit(RolesLoading());
    try {
      final roles = await _repository.getAllRoles();
      emit(RolesLoaded(roles));
    } catch (e) {
      emit(RolesError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // ================= GET USER'S ROLES/Permissions =================
  Future<void> getUserRoles(String userId) async {
    emit(RolesLoading());
    try {
      final roles = await _repository.getUserRoles(userId);
      emit(RolesLoaded(roles));
    } catch (e) {
      emit(RolesError(e.toString().replaceAll('Exception: ', '')));
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
      await _repository.updateRole(
        id: roleId,
        name: name,
        status: status,
        permissions: permissions,
      );
      emit(RolesUpdateSuccess(LocaleKeys.role_updated.tr()));
      getAllRoles();
    } catch (e) {
      emit(RolesUpdateError(e.toString().replaceAll('Exception: ', '')));
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
      await _repository.createRole(
        name: name,
        status: status,
        permissions: permissions,
      );
      emit(RolesCreateSuccess(LocaleKeys.role_created.tr()));
      getAllRoles();
    } catch (e) {
      emit(RolesCreateError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // ================= DELETE ROLE =================
  Future<void> deleteRole({
    required String roleId,
  }) async {
    emit(RolesDeleting());
    try {
      await _repository.deleteRole(roleId);
      emit(RolesDeleteSuccess(LocaleKeys.role_deleted.tr()));
      getAllRoles();
    } catch (e) {
      emit(RolesDeleteError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

