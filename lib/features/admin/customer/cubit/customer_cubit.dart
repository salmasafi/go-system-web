import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/features/admin/customer/model/customer_model.dart';
import 'package:systego/features/admin/customer_group/model/customer_group.dart';
import 'package:systego/generated/locale_keys.g.dart';

part 'customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  CustomerCubit() : super(CustomerInitial());

  List<CustomerModel> allCustomers = [];
  List<CustomerGroup> allCustomerGroups = []; 

  Future<void> getAllCustomers() async {
    emit(GetCustomersLoading());
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getAllCustomers, // Update with your endpoint
      );

      log(response.data.toString());

      if (response.statusCode == 200) {
        final model = CustomerResponse.fromJson(response.data);

        if (model.success) {
          allCustomers = model.data.customers;
          emit(GetCustomersSuccess(model.data.customers));
        } else {
          final errorMessage = ErrorHandler.handleError(response);
          emit(GetCustomersError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(GetCustomersError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(GetCustomersError(errorMessage));
    }
  }

  Future<void> getCustomerById(String customerId) async {
    emit(GetCustomerByIdLoading());
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getCustomerById(customerId), // Update with your endpoint
      );

      if (response.statusCode == 200) {
        final model = CustomerResponse.fromJson(response.data);

        if (model.success && model.data.customers.isNotEmpty) {
          emit(GetCustomerByIdSuccess(model.data.customers.first));
        } else {
          emit(GetCustomerByIdError(LocaleKeys.customer_not_found.tr()));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(GetCustomerByIdError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(GetCustomerByIdError(errorMessage));
    }
  }

  Future<void> addCustomer({
    required String name,
    required String email,
    required String phoneNumber,
    required String address,
    required String country,
    required String city,
    String? customerGroupId,
    bool isDue = false,
    double amountDue = 0.0,
    int totalPointsEarned = 0,
  }) async {
    emit(CreateCustomerLoading());

    try {
      final data = {
        "name": name,
        "email": email,
        "phone_number": phoneNumber,
        "address": address,
        "country": country,
        "city": city,
        if (customerGroupId != null && customerGroupId.isNotEmpty) 
          "customer_group_id": customerGroupId,
        "is_Due": isDue,
        "amount_Due": amountDue,
        "total_points_earned": totalPointsEarned,
      };

      log("Add customer data: $data");

      final response = await DioHelper.postData(
        url: EndPoint.addCustomer, // Update with your endpoint
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(CreateCustomerSuccess(LocaleKeys.customer_created_success.tr()));
        // Refresh the list after creation
        await getAllCustomers();
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(CreateCustomerError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(CreateCustomerError(errorMessage));
    }
  }

  Future<void> updateCustomer({
    required String customerId,
    required String name,
    required String email,
    required String phoneNumber,
    required String address,
    required String country,
    required String city,
    String? customerGroupId,
  }) async {
    emit(UpdateCustomerLoading());

    try {
      final data = {
        "name": name,
        "email": email,
        "phone_number": phoneNumber,
        "address": address,
        "country": country,
        "city": city,
        if (customerGroupId != null && customerGroupId.isNotEmpty) 
          "customer_group_id": customerGroupId,
      };

      log("Update customer data: $data");

      final response = await DioHelper.putData(
        url: EndPoint.updateCustomer(customerId), // Update with your endpoint
        data: data,
      );

      if (response.statusCode == 200) {
        emit(UpdateCustomerSuccess(LocaleKeys.customer_updated_success.tr()));
        // Refresh the list after update
        await getAllCustomers();
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(UpdateCustomerError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(UpdateCustomerError(errorMessage));
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    emit(DeleteCustomerLoading());
    try {
      final response = await DioHelper.deleteData(
        url: EndPoint.deleteCustomer(customerId), // Update with your endpoint
      );

      if (response.statusCode == 200) {
        allCustomers.removeWhere((customer) => customer.id == customerId);
        emit(DeleteCustomerSuccess(LocaleKeys.customer_deleted_success.tr()));
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(DeleteCustomerError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(DeleteCustomerError(errorMessage));
    }
  }



  // ==================== CUSTOMER GROUP METHODS ====================

  Future<void> getAllCustomerGroups() async {
    emit(GetCustomerGroupsLoading());
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getCustomerGroup, // Update with your endpoint
      );

      log(response.data.toString());

      if (response.statusCode == 200) {
        final model = CustomerGroupResponse.fromJson(response.data);

        if (model.success) {
          allCustomerGroups = model.data.groups;
          emit(GetCustomerGroupsSuccess(model.data.groups));
        } else {
          final errorMessage = ErrorHandler.handleError(response);
          emit(GetCustomerGroupsError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(GetCustomerGroupsError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(GetCustomerGroupsError(errorMessage));
    }
  }

  Future<void> getCustomerGroupById(String groupId) async {
    emit(GetCustomerGroupByIdLoading());
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getCustomerGroupById(groupId), // Update with your endpoint
      );

      if (response.statusCode == 200) {
        final model = CustomerGroupResponse.fromJson(response.data);

        if (model.success && model.data.groups.isNotEmpty) {
          emit(GetCustomerGroupByIdSuccess(model.data.groups.first));
        } else {
          emit(GetCustomerGroupByIdError(LocaleKeys.customer_group_not_found.tr()));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(GetCustomerGroupByIdError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(GetCustomerGroupByIdError(errorMessage));
    }
  }

  Future<void> addCustomerGroup({
    required String name,
    required bool status,
  }) async {
    emit(CreateCustomerGroupLoading());

    try {
      final data = {
        "name": name,
        "status": status,
      };

      log("Add customer group data: $data");

      final response = await DioHelper.postData(
        url: EndPoint.createCustomerGroup, // Update with your endpoint
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(CreateCustomerGroupSuccess(LocaleKeys.customer_group_created_success.tr()));
        // Refresh the list after creation
        await getAllCustomerGroups();
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(CreateCustomerGroupError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(CreateCustomerGroupError(errorMessage));
    }
  }
 
}