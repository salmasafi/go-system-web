import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import 'package:GoSystem/core/services/dio_helper.dart';
import 'package:GoSystem/core/services/endpoints.dart';
import 'package:GoSystem/core/utils/error_handler.dart';
import 'package:GoSystem/features/admin/customer/model/customer_model.dart';
import 'package:GoSystem/features/admin/customer_group/model/customer_group_model.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';

import 'package:GoSystem/features/admin/customer/data/repositories/customer_repository.dart';

part 'customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final CustomerRepository _repository;
  CustomerCubit(this._repository) : super(CustomerInitial());

  List<CustomerModel> allCustomers = [];
  List<CustomerGroup> allCustomerGroups = []; 

  Future<void> getAllCustomers() async {
    emit(GetCustomersLoading());
    try {
      final customers = await _repository.getAllCustomers();
      allCustomers = customers;
      emit(GetCustomersSuccess(customers));
    } catch (e) {
      emit(GetCustomersError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> getCustomerById(String customerId) async {
    emit(GetCustomerByIdLoading());
    try {
      final customer = await _repository.getCustomerById(customerId);
      if (customer != null) {
        emit(GetCustomerByIdSuccess(customer));
      } else {
        emit(GetCustomerByIdError(LocaleKeys.customer_not_found.tr()));
      }
    } catch (e) {
      emit(GetCustomerByIdError(e.toString().replaceAll('Exception: ', '')));
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
      await _repository.createCustomer(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
        countryId: country,
        cityId: city,
        customerGroupId: customerGroupId,
      );
      emit(CreateCustomerSuccess(LocaleKeys.customer_created_success.tr()));
      await getAllCustomers();
    } catch (e) {
      emit(CreateCustomerError(e.toString().replaceAll('Exception: ', '')));
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
      await _repository.updateCustomer(
        id: customerId,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
        countryId: country,
        cityId: city,
        customerGroupId: customerGroupId,
      );
      emit(UpdateCustomerSuccess(LocaleKeys.customer_updated_success.tr()));
      await getAllCustomers();
    } catch (e) {
      emit(UpdateCustomerError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    emit(DeleteCustomerLoading());
    try {
      await _repository.deleteCustomer(customerId);
      allCustomers.removeWhere((customer) => customer.id == customerId);
      emit(DeleteCustomerSuccess(LocaleKeys.customer_deleted_success.tr()));
    } catch (e) {
      emit(DeleteCustomerError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // ==================== CUSTOMER GROUP METHODS ====================

  Future<void> getAllCustomerGroups() async {
    emit(GetCustomerGroupsLoading());
    try {
      final groups = await _repository.getAllCustomerGroups();
      allCustomerGroups = groups;
      emit(GetCustomerGroupsSuccess(groups));
    } catch (e) {
      emit(GetCustomerGroupsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> getCustomerGroupById(String groupId) async {
    emit(GetCustomerGroupByIdLoading());
    try {
      final group = await _repository.getCustomerGroupById(groupId);
      if (group != null) {
        emit(GetCustomerGroupByIdSuccess(group));
      } else {
        emit(GetCustomerGroupByIdError(LocaleKeys.customer_group_not_found.tr()));
      }
    } catch (e) {
      emit(GetCustomerGroupByIdError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> addCustomerGroup({
    required String name,
    required bool status,
  }) async {
    emit(CreateCustomerGroupLoading());
    try {
      await _repository.createCustomerGroup(name: name, status: status);
      emit(CreateCustomerGroupSuccess(LocaleKeys.customer_group_created_success.tr()));
      await getAllCustomerGroups();
    } catch (e) {
      emit(CreateCustomerGroupError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateCustomerGroup({
    required String name,
    required bool status,
    required String id,
  }) async {
    emit(UpdateCustomerGroupLoading());
    try {
      await _repository.updateCustomerGroup(id: id, name: name, status: status);
      emit(UpdateCustomerGroupSuccess(LocaleKeys.customer_group_updated_success.tr()));
      await getAllCustomerGroups();
    } catch (e) {
      emit(UpdateCustomerGroupError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteCustomerGroup(String id) async {
    emit(DeleteCustomerGroupLoading());
    try {
      await _repository.deleteCustomerGroup(id);
      emit(DeleteCustomerGroupSuccess(LocaleKeys.customer_group_deleted_success.tr()));
      await getAllCustomerGroups();
    } catch (e) {
      emit(DeleteCustomerGroupError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
