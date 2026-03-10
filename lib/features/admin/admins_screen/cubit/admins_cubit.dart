
import 'dart:developer' as dev;
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:meta/meta.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/features/admin/admins_screen/model/admins_model.dart';
import 'package:systego/generated/locale_keys.g.dart';

part 'admins_state.dart';

class AdminsCubit extends Cubit<AdminsState> {
  AdminsCubit() : super(AdminsInitial());

  List<AdminModel> allAdmins = [];

  // ================= GET ADMINS =================
  Future<void> getAdmins() async {
    emit(GetAdminsLoading());
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getAllAdmins,
      );

      dev.log(response.data.toString());

      if (response.statusCode == 200) {
        final model = AdminsResponse.fromJson(response.data);

        if (model.success) {
          allAdmins = model.data.admins;
          emit(GetAdminsSuccess(allAdmins));
        } else {
          // If success is false, handle as error
          emit(GetAdminsError(model.data.message));
        }
      } else {
        emit(GetAdminsError(ErrorHandler.handleError(response)));
      }
    } catch (e) {
      emit(GetAdminsError(ErrorHandler.handleError(e)));
    }
  }

  // ================= GET ADMIN BY ID =================
  Future<void> getAdminById(String adminId) async {
    emit(GetAdminByIdLoading());
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getAdmin(adminId),
      );

      if (response.statusCode == 200) {
        // Adjust parsing based on your specific single-admin API response structure
        // Assuming it returns { "success": true, "data": { ...admin object... } }
        final admin = AdminModel.fromJson(response.data['data']);
        emit(GetAdminByIdSuccess(admin));
      } else {
        emit(GetAdminByIdError(ErrorHandler.handleError(response)));
      }
    } catch (e) {
      emit(GetAdminByIdError(ErrorHandler.handleError(e)));
    }
  }

  // ================= CREATE ADMIN =================
  Future<void> createAdmin({
    required String username,
    required String email,
    required String phone,
    required String password,
    required String roleId,
    required String companyName,
    required String warehouseId,
    required String status,
  }) async {
    emit(CreateAdminLoading());
    try {
      final data = {
        'username': username,
        'email': email,
        'phone': phone,
        'password': password,
        'company_name': companyName,
        'role_id': roleId, // Send role_id
        'warehouse_id': warehouseId, // Send warehouse_id
        'status': status,
      };

      final response = await DioHelper.postData(
        url: EndPoint.createAdmin,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh list after creation
       
        emit(CreateAdminSuccess(LocaleKeys.admin_created.tr()));
         await getAdmins(); 
      } else {
        emit(CreateAdminError(ErrorHandler.handleError(response)));
      }
    } catch (e) {
      emit(CreateAdminError(ErrorHandler.handleError(e)));
    }
  }

  // ================= UPDATE ADMIN =================
  Future<void> updateAdmin({
    required String adminId,
    required String username,
    required String email,
    required String phone,
    required String roleId,
    required String companyName,
    required String warehouseId,
    required String status,
    String? password, // Optional for update
  }) async {
    emit(UpdateAdminLoading());
    try {
      final data = {
        'username': username,
        'email': email,
        'phone': phone,
        'company_name': companyName,
        'role_id': roleId,
        'warehouse_id': warehouseId,
        'status': status,
      };

      // Only add password to payload if it's not empty
      if (password != null && password.isNotEmpty) {
        data['password'] = password;
      }

      final response = await DioHelper.putData(
        url: EndPoint.updateAdmin(adminId),
        data: data,
      );

      if (response.statusCode == 200) {
        // Refresh list after update
        
        emit(UpdateAdminSuccess(LocaleKeys.update_admin.tr()));
        await getAdmins();
      } else {
        emit(UpdateAdminError(ErrorHandler.handleError(response)));
      }
    } catch (e) {
      emit(UpdateAdminError(ErrorHandler.handleError(e)));
    }
  }

  // ================= DELETE ADMIN =================
  Future<void> deleteAdmin(String adminId) async {
    emit(DeleteAdminLoading());
    try {
      final response = await DioHelper.deleteData(
        url: EndPoint.deleteAdmin(adminId),
      );

      if (response.statusCode == 200) {
        // Optimistically remove from local list to update UI instantly
        allAdmins.removeWhere((admin) => admin.id == adminId);
        emit(DeleteAdminSuccess(LocaleKeys.admin_deleted.tr()));
        // Optionally fetch from server to ensure sync
        // await getAdmins(); 
      } else {
        emit(DeleteAdminError(ErrorHandler.handleError(response)));
      }
    } catch (e) {
      emit(DeleteAdminError(ErrorHandler.handleError(e)));
    }
  }
}