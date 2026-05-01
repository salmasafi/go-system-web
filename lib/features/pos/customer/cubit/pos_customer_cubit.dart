import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/services/dio_helper.dart';
import 'package:GoSystem/core/services/endpoints.dart';
import 'package:GoSystem/core/utils/error_handler.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import '../model/pos_customer_model.dart';

part 'pos_customer_state.dart';

class PosCustomerCubit extends Cubit<PosCustomerState> {
  PosCustomerCubit() : super(PosCustomerInitial());

  List<PosCustomer> customers = [];
  PosCustomer? selectedCustomer;

  Future<void> fetchCustomers() async {
    emit(PosCustomerLoading());
    try {
      final response = await DioHelper.getData(url: EndPoint.getPosCustomers);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data['data'] as Map<String, dynamic>? ?? {};
        final data = responseData['customers'] as List? ?? [];
        customers = data.map((e) => PosCustomer.fromJson(e)).toList();
        emit(PosCustomerLoaded(customers: customers, selectedCustomer: selectedCustomer));
      } else {
        final msg = response.data['message'] ?? LocaleKeys.failed_to_load_customers.tr();
        emit(PosCustomerError(msg));
      }
    } catch (e) {
      log('fetchCustomers error: $e');
      emit(PosCustomerError(ErrorHandler.handleError(e)));
    }
  }

  void selectCustomer(PosCustomer customer) {
    selectedCustomer = customer;
    emit(PosCustomerLoaded(customers: customers, selectedCustomer: selectedCustomer));
  }

  Future<void> createCustomer({
    required String name,
    required String phone,
    String? email,
    String? address,
  }) async {
    emit(PosCustomerCreating());
    try {
      final body = PosCustomer(
        id: '',
        name: name,
        phoneNumber: phone,
        email: email,
        address: address,
      ).toCreateJson();

      final response = await DioHelper.postData(
        url: EndPoint.createPosCustomer,
        data: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = response.data['data'];
        final newCustomer = PosCustomer.fromJson(json);
        customers = [newCustomer, ...customers];
        selectedCustomer = newCustomer;
        // Emit loaded first so CustomerSelectorWidget rebuilds with the new selection,
        // then emit create success to trigger dialog close
        emit(PosCustomerLoaded(customers: customers, selectedCustomer: selectedCustomer));
        emit(PosCustomerCreateSuccess(newCustomer));
      } else {
        final msg = response.data['message'] ?? LocaleKeys.failed_to_create_customer.tr();
        emit(PosCustomerCreateError(msg));
      }
    } catch (e) {
      log('createCustomer error: $e');
      emit(PosCustomerCreateError(ErrorHandler.handleError(e)));
    }
  }

  void clearSelectedCustomer() {
    selectedCustomer = null;
    emit(PosCustomerLoaded(customers: customers, selectedCustomer: null));
  }

  void clearAll() {
    customers = [];
    selectedCustomer = null;
    emit(PosCustomerInitial());
  }
}
