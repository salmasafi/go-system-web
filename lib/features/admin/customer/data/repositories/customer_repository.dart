import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/migration/migration_service.dart';
import '../../../../../core/services/dio_helper.dart';
import '../../../../../core/services/endpoints.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../model/customer_model.dart';
import '../../../customer_group/model/customer_group_model.dart';

/// Interface for customer data operations
abstract class CustomerRepositoryInterface {
  Future<List<CustomerModel>> getAllCustomers();
  Future<CustomerModel?> getCustomerById(String id);
  Future<List<CustomerModel>> getCustomersByGroup(String groupId);
  Future<CustomerModel> createCustomer({
    required String name,
    required String email,
    required String phoneNumber,
    required String address,
    String? countryId,
    String? cityId,
    String? customerGroupId,
  });
  Future<CustomerModel> updateCustomer({
    required String id,
    required String name,
    required String email,
    required String phoneNumber,
    required String address,
    String? countryId,
    String? cityId,
    String? customerGroupId,
  });
  Future<void> deleteCustomer(String id);
  Future<double> calculateDueAmount(String customerId);
  
  // Customer Group Methods
  Future<List<CustomerGroup>> getAllCustomerGroups();
  Future<CustomerGroup?> getCustomerGroupById(String id);
  Future<CustomerGroup> createCustomerGroup({
    required String name,
    required bool status,
  });
  Future<CustomerGroup> updateCustomerGroup({
    required String id,
    required String name,
    required bool status,
  });
  Future<void> deleteCustomerGroup(String id);
}

/// Customer repository using Supabase as the primary data source.
class CustomerRepository implements CustomerRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<List<CustomerModel>> getAllCustomers() async {
    try {
      log('CustomerRepository: Fetching all customers');

      final response = await _client
          .from('customers')
          .select('''
            *,
            country:country_id(id, name),
            city:city_id(id, name),
            customer_group:customer_group_id(id, name, status)
          ''')
          .order('name');

      final customers = (response as List)
          .map((json) => _mapSupabaseToCustomerModel(json))
          .toList();

      log('CustomerRepository: Fetched ${customers.length} customers');
      return customers;
    } catch (e) {
      log('CustomerRepository: Error fetching customers - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<CustomerModel?> getCustomerById(String id) async {
    try {
      log('CustomerRepository: Fetching customer by id: $id');

      final response = await _client
          .from('customers')
          .select('''
            *,
            country:country_id(id, name),
            city:city_id(id, name),
            customer_group:customer_group_id(id, name, status)
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return _mapSupabaseToCustomerModel(response);
    } catch (e) {
      log('CustomerRepository: Error fetching customer - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<CustomerModel>> getCustomersByGroup(String groupId) async {
    try {
      log('CustomerRepository: Fetching customers by group: $groupId');

      final response = await _client
          .from('customers')
          .select('''
            *,
            country:country_id(id, name),
            city:city_id(id, name),
            customer_group:customer_group_id(id, name, status)
          ''')
          .eq('customer_group_id', groupId)
          .order('name');

      final customers = (response as List)
          .map((json) => _mapSupabaseToCustomerModel(json))
          .toList();

      log('CustomerRepository: Fetched ${customers.length} customers for group');
      return customers;
    } catch (e) {
      log('CustomerRepository: Error fetching customers by group - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<CustomerModel> createCustomer({
    required String name,
    required String email,
    required String phoneNumber,
    required String address,
    String? countryId,
    String? cityId,
    String? customerGroupId,
  }) async {
    try {
      log('CustomerRepository: Creating customer: $name');

      final response = await _client
          .from('customers')
          .insert({
            'name': name,
            'email': email,
            'phone_number': phoneNumber,
            'address': address,
            'country_id': countryId,
            'city_id': cityId,
            'customer_group_id': customerGroupId,
            'is_due': false,
            'amount_due': 0.0,
            'total_points_earned': 0,
          })
          .select('''
            *,
            country:country_id(id, name),
            city:city_id(id, name),
            customer_group:customer_group_id(id, name, status)
          ''')
          .single();

      log('CustomerRepository: Created customer successfully');
      return _mapSupabaseToCustomerModel(response);
    } catch (e) {
      log('CustomerRepository: Error creating customer - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<CustomerModel> updateCustomer({
    required String id,
    required String name,
    required String email,
    required String phoneNumber,
    required String address,
    String? countryId,
    String? cityId,
    String? customerGroupId,
  }) async {
    try {
      log('CustomerRepository: Updating customer: $id');

      final response = await _client
          .from('customers')
          .update({
            'name': name,
            'email': email,
            'phone_number': phoneNumber,
            'address': address,
            'country_id': countryId,
            'city_id': cityId,
            'customer_group_id': customerGroupId,
          })
          .eq('id', id)
          .select('''
            *,
            country:country_id(id, name),
            city:city_id(id, name),
            customer_group:customer_group_id(id, name, status)
          ''')
          .single();

      log('CustomerRepository: Updated customer successfully');
      return _mapSupabaseToCustomerModel(response);
    } catch (e) {
      log('CustomerRepository: Error updating customer - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    try {
      log('CustomerRepository: Deleting customer: $id');

      await _client.from('customers').delete().eq('id', id);

      log('CustomerRepository: Deleted customer successfully');
    } catch (e) {
      log('CustomerRepository: Error deleting customer - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<double> calculateDueAmount(String customerId) async {
    try {
      log('CustomerRepository: Calculating due amount for customer: $customerId');

      // Get all sales with due amounts for this customer
      final response = await _client
          .from('sales')
          .select('due_amount')
          .eq('customer_id', customerId)
          .gt('due_amount', 0);

      double totalDue = 0.0;
      for (final sale in response) {
        totalDue += (sale['due_amount'] as num).toDouble();
      }

      // Update customer's amount_due
      await _client
          .from('customers')
          .update({'amount_due': totalDue, 'is_due': totalDue > 0})
          .eq('id', customerId);

      log('CustomerRepository: Calculated due amount: $totalDue');
      return totalDue;
    } catch (e) {
      log('CustomerRepository: Error calculating due amount - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<CustomerGroup>> getAllCustomerGroups() async {
    try {
      log('CustomerRepository: Fetching all customer groups');
      final response = await _client.from('customer_groups').select().order('name');
      return (response as List).map((json) => _mapSupabaseToCustomerGroup(json)).toList();
    } catch (e) {
      log('CustomerRepository: Error fetching customer groups - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<CustomerGroup?> getCustomerGroupById(String id) async {
    try {
      log('CustomerRepository: Fetching customer group by id: $id');
      final response = await _client.from('customer_groups').select().eq('id', id).maybeSingle();
      if (response == null) return null;
      return _mapSupabaseToCustomerGroup(response);
    } catch (e) {
      log('CustomerRepository: Error fetching customer group - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<CustomerGroup> createCustomerGroup({required String name, required bool status}) async {
    try {
      log('CustomerRepository: Creating customer group: $name');
      final response = await _client.from('customer_groups').insert({
        'name': name,
        'status': status,
      }).select().single();
      return _mapSupabaseToCustomerGroup(response);
    } catch (e) {
      log('CustomerRepository: Error creating customer group - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<CustomerGroup> updateCustomerGroup({required String id, required String name, required bool status}) async {
    try {
      log('CustomerRepository: Updating customer group: $id');
      final response = await _client.from('customer_groups').update({
        'name': name,
        'status': status,
      }).eq('id', id).select().single();
      return _mapSupabaseToCustomerGroup(response);
    } catch (e) {
      log('CustomerRepository: Error updating customer group - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteCustomerGroup(String id) async {
    try {
      log('CustomerRepository: Deleting customer group: $id');
      await _client.from('customer_groups').delete().eq('id', id);
    } catch (e) {
      log('CustomerRepository: Error deleting customer group - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  CustomerGroup _mapSupabaseToCustomerGroup(Map<String, dynamic> json) {
    return CustomerGroup(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? false,
    );
  }

  /// Map Supabase response to CustomerModel
  CustomerModel _mapSupabaseToCustomerModel(Map<String, dynamic> json) {
    final countryData = json['country'] as Map<String, dynamic>?;
    final cityData = json['city'] as Map<String, dynamic>?;
    final groupData = json['customer_group'] as Map<String, dynamic>?;

    return CustomerModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      address: json['address'] ?? '',
      country: countryData != null
          ? Country(
              id: countryData['id'] ?? '',
              name: countryData['name'] ?? '',
            )
          : null,
      city: cityData != null
          ? City(
              id: cityData['id'] ?? '',
              name: cityData['name'] ?? '',
            )
          : null,
      customerGroup: groupData != null
          ? CustomerGroup(
              id: groupData['id'] ?? '',
              name: groupData['name'] ?? '',
              status: groupData['status'] ?? false,
            )
          : null,
      isDue: json['is_due'] ?? false,
      amountDue: (json['amount_due'] as num?)?.toDouble() ?? 0.0,
      totalPointsEarned: (json['total_points_earned'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      version: json['version'] ?? 1,
    );
  }
}
