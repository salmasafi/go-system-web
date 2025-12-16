// import 'dart:convert';
// import 'dart:developer' as dev;
// import 'dart:developer';
// import 'package:bloc/bloc.dart';
// import 'package:meta/meta.dart';
// import 'package:systego/core/services/dio_helper.dart';
// import 'package:systego/core/services/endpoints.dart';
// import 'package:systego/core/utils/error_handler.dart';
// import 'package:systego/features/admin/admins_screen/model/admins_model.dart';
// import 'package:systego/features/admin/admins_screen/model/permission_model.dart';

// part 'admins_state.dart';

// class AdminsCubit extends Cubit<AdminsState> {
//   AdminsCubit() : super(AdminsInitial());

//   List<AdminModel> allAdmins = [];

//   // ================= GET ADMINS =================
//   Future<void> getAdmins() async {
//     emit(GetAdminsLoading());
//     try {
//       final response = await DioHelper.getData(
//         url: EndPoint.getAllAdmins,
//       );

//       dev.log(response.data.toString());

//       if (response.statusCode == 200) {
//         final model = AdminsResponse.fromJson(response.data);

//         if (model.success) {
//           allAdmins = model.data.admins;
//           emit(GetAdminsSuccess(allAdmins));
//         } else {
//           emit(GetAdminsError(ErrorHandler.handleError(response)));
//         }
//       } else {
//         emit(GetAdminsError(ErrorHandler.handleError(response)));
//       }
//     } catch (e) {
//       emit(GetAdminsError(ErrorHandler.handleError(e)));
//     }
//   }

//   // ================= GET ADMIN BY ID =================
//   Future<void> getAdminById(String adminId) async {
//     emit(GetAdminByIdLoading());
//     try {
//       final response = await DioHelper.getData(
//         url: EndPoint.getAdmin(adminId),
//       );

//       if (response.statusCode == 200) {
//         final admin = AdminModel.fromJson(response.data['data']);
//         emit(GetAdminByIdSuccess(admin));
//       } else {
//         emit(GetAdminByIdError(ErrorHandler.handleError(response)));
//       }
//     } catch (e) {
//       emit(GetAdminByIdError(ErrorHandler.handleError(e)));
//     }
//   }

//   // ================= CREATE ADMIN =================
//   Future<void> createAdmin({
//     required String username,
//     required String email,
//     required String phone,
//     required String password,
//     required String role,
//     required String companyName,
//     String? positionId,
//     String? warehouseId,
//     List<Map<String, dynamic>> permissions = const [],
//   }) async {
//     emit(CreateAdminLoading());
//     try {
//       final data = {
//         'username': username,
//         'email': email,
//         'phone': phone,
//         'role': role,
//         'password': password,
//         'company_name': companyName,
//         if (positionId != null) 'positionId': positionId,
//         if (warehouseId != null) 'warehouseId': warehouseId,
//         // 'permissions': permissions,
//       };

//       final response = await DioHelper.postData(
//         url: EndPoint.createAdmin,
//         data: data,
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         emit(CreateAdminSuccess('Admin created successfully'));
//       } else {
//         emit(CreateAdminError(ErrorHandler.handleError(response)));
//       }
//     } catch (e) {
//       emit(CreateAdminError(ErrorHandler.handleError(e)));
//     }
//   }

//   // ================= UPDATE ADMIN =================
//   Future<void> updateAdmin({
//     required String adminId,
//     required String username,
//     required String email,
//     required String phone,
//     required String role,
//     required String companyName,
//     String? positionId,
//     String? warehouseId,
//     List<Map<String, dynamic>> permissions = const [],
//   }) async {
//     emit(UpdateAdminLoading());
//     try {
//       final data = {
//         'username': username,
//         'email': email,
//         'phone': phone,
//         'role': role,
//         'company_name': companyName,
//         if (positionId != null) 'positionId': positionId,
//         if (warehouseId != null) 'warehouseId': warehouseId,
//         'permissions': permissions,
//       };

//       final response = await DioHelper.putData(
//         url: EndPoint.updateAdmin(adminId),
//         data: data,
//       );

//       if (response.statusCode == 200) {
//         emit(UpdateAdminSuccess('Admin updated successfully'));
//       } else {
//         emit(UpdateAdminError(ErrorHandler.handleError(response)));
//       }
//     } catch (e) {
//       emit(UpdateAdminError(ErrorHandler.handleError(e)));
//     }
//   }

//   Future<void> deleteAdmin(String adminId) async {
//     emit(DeleteAdminLoading());
//     try {
//       final response = await DioHelper.deleteData(
//         url: EndPoint.deleteAdmin(adminId),
//       );

//       if (response.statusCode == 200) {
//         allAdmins.removeWhere((admin) => admin.id == adminId);
//         emit(DeleteAdminSuccess('Admin deleted successfully'));
//       } else {
//         emit(DeleteAdminError(ErrorHandler.handleError(response)));
//       }
//     } catch (e) {
//       emit(DeleteAdminError(ErrorHandler.handleError(e)));
//     }
//   }


//   Future<void> getUserPermissions(String userId) async {
//   emit(PermissionsLoading());
//   try {
//     final response = await DioHelper.getData(
//       url: EndPoint.getUserPermissions(userId),
//     );

//     log("permissions: ${response}");

//     if (response.statusCode == 200) {
//       final data = response.data;
      
//       if (data is String) {
//         final jsonData = json.decode(data);
//         final permissions = AdminPermissionsModel.fromJson(jsonData['data']);
//         emit(PermissionsLoaded(permissions));
//       } else if (data is Map) {
//         final permissions = AdminPermissionsModel.fromJson(data['data']);
//         emit(PermissionsLoaded(permissions));
//       } else {
//         emit(PermissionsError('Invalid response format'));
//       }
//     } else {
//       emit(PermissionsError('Failed to load permissions'));
//     }
//   } catch (e) {
//     log('Error getting permissions: $e');
//     emit(PermissionsError(e.toString()));
//   }
// }


// Future<void> updatePermissions({
//   required String userId,
//   required List<ModulePermission> permissions,
// }) async {
//   emit(PermissionsUpdating());
//   try {
//     final data = {
//       'permissions': permissions
//           .map((p) => {'module': p.module, 'actions': p.actions})
//           .toList(),
//     };

//     final response = await DioHelper.putData(
//       url: EndPoint.updatepermission(userId),
//       data: data,
//     );

//     if (response.statusCode == 200) {
//       emit(PermissionsUpdateSuccess(
//           'Permissions updated successfully',
//         ));
//     } else {
//       emit(PermissionsUpdateError(
//         'Failed to update permissions'
//       ));
//     }
//   } catch (e) {
//     log("Update permissions error: $e");
//     emit(PermissionsUpdateError(
//       e.toString()
//     ));
//   }
// }

// }

import 'dart:developer' as dev;
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/features/admin/admins_screen/model/admins_model.dart';

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
          emit(GetAdminsError(ErrorHandler.handleError(response)));
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
    required String role,
    required String companyName,
    String? positionId,
    String? warehouseId,
  }) async {
    emit(CreateAdminLoading());
    try {
      final data = {
        'username': username,
        'email': email,
        'phone': phone,
        'role': role,
        'password': password,
        'company_name': companyName,
        if (positionId != null) 'positionId': positionId,
        if (warehouseId != null) 'warehouseId': warehouseId,
      };

      final response = await DioHelper.postData(
        url: EndPoint.createAdmin,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(CreateAdminSuccess('Admin created successfully'));
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
    required String role,
    required String companyName,
    String? positionId,
    String? warehouseId,
  }) async {
    emit(UpdateAdminLoading());
    try {
      final data = {
        'username': username,
        'email': email,
        'phone': phone,
        'role': role,
        'company_name': companyName,
        if (positionId != null) 'positionId': positionId,
        if (warehouseId != null) 'warehouseId': warehouseId,
      };

      final response = await DioHelper.putData(
        url: EndPoint.updateAdmin(adminId),
        data: data,
      );

      if (response.statusCode == 200) {
        emit(UpdateAdminSuccess('Admin updated successfully'));
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
        allAdmins.removeWhere((admin) => admin.id == adminId);
        emit(DeleteAdminSuccess('Admin deleted successfully'));
      } else {
        emit(DeleteAdminError(ErrorHandler.handleError(response)));
      }
    } catch (e) {
      emit(DeleteAdminError(ErrorHandler.handleError(e)));
    }
  }
}
