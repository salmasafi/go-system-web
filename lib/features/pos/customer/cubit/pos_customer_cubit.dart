import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:GoSystem/core/utils/error_handler.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import '../model/pos_customer_model.dart';

part 'pos_customer_state.dart';

class PosCustomerCubit extends Cubit<PosCustomerState> {
  PosCustomerCubit() : super(PosCustomerInitial());

  final SupabaseClient _client = SupabaseClientWrapper.instance;
  List<PosCustomer> customers = [];
  PosCustomer? selectedCustomer;

  Future<void> fetchCustomers() async {
    emit(PosCustomerLoading());
    try {
      final response = await _client.from('customers').select().order('name');
      customers = (response as List).map((e) => PosCustomer.fromJson(e)).toList();
      emit(PosCustomerLoaded(customers: customers, selectedCustomer: selectedCustomer));
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
      final newCustomerData = PosCustomer(
        id: '',
        name: name,
        phoneNumber: phone,
        email: email,
        address: address,
      ).toCreateJson();

      final response = await _client
          .from('customers')
          .insert(newCustomerData)
          .select()
          .single();

      final newCustomer = PosCustomer.fromJson(response);
      customers = [newCustomer, ...customers];
      selectedCustomer = newCustomer;
      
      emit(PosCustomerLoaded(customers: customers, selectedCustomer: selectedCustomer));
      emit(PosCustomerCreateSuccess(newCustomer));
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
