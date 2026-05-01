
import 'dart:developer' as dev;
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:meta/meta.dart';
import 'package:GoSystem/features/admin/admins_screen/model/admins_model.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import 'package:GoSystem/features/admin/admins_screen/data/repositories/admin_repository.dart';
part 'admins_state.dart';

class AdminsCubit extends Cubit<AdminsState> {
  final AdminRepository _repository;
  AdminsCubit(this._repository) : super(AdminsInitial());

  List<AdminModel> allAdmins = [];

  // ================= GET ADMINS =================
  Future<void> getAdmins() async {
    emit(GetAdminsLoading());
    try {
      final admins = await _repository.getAllAdmins();
      allAdmins = admins;
      emit(GetAdminsSuccess(allAdmins));
    } catch (e) {
      emit(GetAdminsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // ================= GET ADMIN BY ID =================
  Future<void> getAdminById(String adminId) async {
    emit(GetAdminByIdLoading());
    try {
      final admin = await _repository.getAdminById(adminId);
      if (admin != null) {
        emit(GetAdminByIdSuccess(admin));
      } else {
        emit(GetAdminByIdError('Admin not found'));
      }
    } catch (e) {
      emit(GetAdminByIdError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // ================= CREATE ADMIN =================
  Future<void> createAdmin({
    required String username,
    required String email,
    required String phone,
    required String password,
    required String roleId,
    String? companyName,
    String? warehouseId,
    String? status,
  }) async {
    emit(CreateAdminLoading());
    try {
      await _repository.createAdmin(
        username: username,
        email: email,
        password: password,
        phone: phone,
        roleId: roleId,
        warehouseId: warehouseId,
      );
      emit(CreateAdminSuccess(LocaleKeys.admin_created.tr()));
      await getAdmins();
    } catch (e) {
      dev.log('AdminsCubit.createAdmin error: $e');
      emit(CreateAdminError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // ================= UPDATE ADMIN =================
  Future<void> updateAdmin({
    required String adminId,
    required String username,
    required String phone,
    required String roleId,
    required String warehouseId,
    String? email,
    String? companyName,
    String? status,
    String? password,
    bool? isActive,
  }) async {
    emit(UpdateAdminLoading());
    try {
      await _repository.updateAdmin(
        id: adminId,
        username: username,
        phone: phone,
        roleId: roleId,
        warehouseId: warehouseId,
        isActive: status != null ? status == 'active' : isActive,
      );
      emit(UpdateAdminSuccess(LocaleKeys.admin_updated.tr()));
      await getAdmins();
    } catch (e) {
      dev.log('AdminsCubit.updateAdmin error: $e');
      emit(UpdateAdminError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // ================= DELETE ADMIN =================
  Future<void> deleteAdmin(String adminId) async {
    emit(DeleteAdminLoading());
    try {
      await _repository.deleteAdmin(adminId);
      allAdmins.removeWhere((admin) => admin.id == adminId);
      emit(DeleteAdminSuccess(LocaleKeys.admin_deleted.tr()));
    } catch (e) {
      dev.log('AdminsCubit.deleteAdmin error: $e');
      emit(DeleteAdminError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
