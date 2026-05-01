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
}

/// Hybrid repository that supports both Dio and Supabase for customers
class CustomerRepository implements CustomerRepositoryInterface {
  late final CustomerRepositoryInterface _dataSource;

  CustomerRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('customers')) {
      log('CustomerRepository: Using Supabase');
      _dataSource = _CustomerSupabaseDataSource();
    } else {
      log('CustomerRepository: Using Dio (legacy)');
      _dataSource = _CustomerDioDataSource();
    }
  }

  @override
  Future<List<CustomerModel>> getAllCustomers() => _dataSource.getAllCustomers();

  @override
  Future<CustomerModel?> getCustomerById(String id) => _dataSource.getCustomerById(id);

  @override
  Future<List<CustomerModel>> getCustomersByGroup(String groupId) => _dataSource.getCustomersByGroup(groupId);

  @override
  Future<CustomerModel> createCustomer({
    required String name,
    required String email,
    required String phoneNumber,
    required String address,
    String? countryId,
    String? cityId,
    String? customerGroupId,
  }) => _dataSource.createCustomer(
    name: name,
    email: email,
    phoneNumber: phoneNumber,
    address: address,
    countryId: countryId,
    cityId: cityId,
    customerGroupId: customerGroupId,
  );

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
  }) => _dataSource.updateCustomer(
    id: id,
    name: name,
    email: email,
    phoneNumber: phoneNumber,
    address: address,
    countryId: countryId,
    cityId: cityId,
    customerGroupId: customerGroupId,
  );

  @override
  Future<void> deleteCustomer(String id) => _dataSource.deleteCustomer(id);

  @override
  Future<double> calculateDueAmount(String customerId) => _dataSource.calculateDueAmount(customerId);

  void enableSupabase() {
    MigrationService.enableSupabase('customers');
    _initializeDataSource();
  }

  void enableDio() {
    MigrationService.enableDio('customers');
    _initializeDataSource();
  }
}

/// Supabase implementation for Customer data source
class _CustomerSupabaseDataSource implements CustomerRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<List<CustomerModel>> getAllCustomers() async {
    try {
      log('CustomerSupabase: Fetching all customers');

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

      log('CustomerSupabase: Fetched ${customers.length} customers');
      return customers;
    } catch (e) {
      log('CustomerSupabase: Error fetching customers - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<CustomerModel?> getCustomerById(String id) async {
    try {
      log('CustomerSupabase: Fetching customer by id: $id');

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
      log('CustomerSupabase: Error fetching customer - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<CustomerModel>> getCustomersByGroup(String groupId) async {
    try {
      log('CustomerSupabase: Fetching customers by group: $groupId');

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

      log('CustomerSupabase: Fetched ${customers.length} customers for group');
      return customers;
    } catch (e) {
      log('CustomerSupabase: Error fetching customers by group - $e');
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
      log('CustomerSupabase: Creating customer: $name');

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

      log('CustomerSupabase: Created customer successfully');
      return _mapSupabaseToCustomerModel(response);
    } catch (e) {
      log('CustomerSupabase: Error creating customer - $e');
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
      log('CustomerSupabase: Updating customer: $id');

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

      log('CustomerSupabase: Updated customer successfully');
      return _mapSupabaseToCustomerModel(response);
    } catch (e) {
      log('CustomerSupabase: Error updating customer - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    try {
      log('CustomerSupabase: Deleting customer: $id');

      await _client.from('customers').delete().eq('id', id);

      log('CustomerSupabase: Deleted customer successfully');
    } catch (e) {
      log('CustomerSupabase: Error deleting customer - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<double> calculateDueAmount(String customerId) async {
    try {
      log('CustomerSupabase: Calculating due amount for customer: $customerId');

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

      log('CustomerSupabase: Calculated due amount: $totalDue');
      return totalDue;
    } catch (e) {
      log('CustomerSupabase: Error calculating due amount - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
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

/// Dio implementation for Customer data source (legacy)
class _CustomerDioDataSource implements CustomerRepositoryInterface {
  @override
  Future<List<CustomerModel>> getAllCustomers() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.getAllCustomers);

      if (response.statusCode == 200) {
        final model = CustomerResponse.fromJson(response.data);
        if (model.success) {
          return model.data.customers;
        }
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<CustomerModel?> getCustomerById(String id) async {
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getCustomerById(id),
      );

      if (response.statusCode == 200) {
        final model = CustomerResponse.fromJson(response.data);
        if (model.success && model.data.customers.isNotEmpty) {
          return model.data.customers.first;
        }
      }
      return null;
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<List<CustomerModel>> getCustomersByGroup(String groupId) async {
    try {
      final allCustomers = await getAllCustomers();
      return allCustomers.where((c) => c.customerGroup?.id == groupId).toList();
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
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
      final response = await DioHelper.postData(
        url: EndPoint.addCustomer,
        data: {
          'name': name,
          'email': email,
          'phone_number': phoneNumber,
          'address': address,
          'country_id': countryId,
          'city_id': cityId,
          'customer_group_id': customerGroupId,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final customerJson = response.data['data']?['customer'];
        if (customerJson != null) {
          return CustomerModel.fromJson(customerJson);
        }
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
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
      final response = await DioHelper.putData(
        url: EndPoint.updateCustomer(id),
        data: {
          'name': name,
          'email': email,
          'phone_number': phoneNumber,
          'address': address,
          'country_id': countryId,
          'city_id': cityId,
          'customer_group_id': customerGroupId,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final customerJson = response.data['data']?['customer'];
        if (customerJson != null) {
          return CustomerModel.fromJson(customerJson);
        }
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    try {
      final response = await DioHelper.deleteData(
        url: EndPoint.deleteCustomer(id),
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<double> calculateDueAmount(String customerId) async {
    try {
      final response = await DioHelper.getData(
        url: EndPoint.getCustomerDue(customerId),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return (response.data['data']?['due_amount'] as num?)?.toDouble() ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }
}
