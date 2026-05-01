import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/migration/migration_service.dart';
import '../../../../../core/services/dio_helper.dart';
import '../../../../../core/services/endpoints.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../model/cashirer_model.dart';

/// Interface for cashier data operations
abstract class CashierRepositoryInterface {
  Future<List<CashierModel>> getAllCashiers();
  Future<void> createCashier({
    required String name,
    required String arName,
    String? warehouseId,
    required bool status,
  });
  Future<void> updateCashier({
    required String id,
    required String name,
    required String arName,
    String? warehouseId,
    required bool status,
  });
  Future<void> deleteCashier(String id);
}

/// Hybrid repository that supports both Dio and Supabase for cashiers
class CashierRepository implements CashierRepositoryInterface {
  late final CashierRepositoryInterface _dataSource;

  CashierRepository() {
    _initializeDataSource();
  }

  void _initializeDataSource() {
    if (MigrationService.isUsingSupabase('cashiers')) {
      log('CashierRepository: Using Supabase');
      _dataSource = _CashierSupabaseDataSource();
    } else {
      log('CashierRepository: Using Dio (legacy)');
      _dataSource = _CashierDioDataSource();
    }
  }

  @override
  Future<List<CashierModel>> getAllCashiers() => _dataSource.getAllCashiers();

  @override
  Future<void> createCashier({
    required String name,
    required String arName,
    String? warehouseId,
    required bool status,
  }) => _dataSource.createCashier(
        name: name, arName: arName, warehouseId: warehouseId, status: status);

  @override
  Future<void> updateCashier({
    required String id,
    required String name,
    required String arName,
    String? warehouseId,
    required bool status,
  }) => _dataSource.updateCashier(
        id: id, name: name, arName: arName, warehouseId: warehouseId, status: status);

  @override
  Future<void> deleteCashier(String id) => _dataSource.deleteCashier(id);
}

/// Supabase implementation for Cashier data source
class _CashierSupabaseDataSource implements CashierRepositoryInterface {
  final SupabaseClient _client = SupabaseClientWrapper.instance;

  @override
  Future<List<CashierModel>> getAllCashiers() async {
    try {
      log('CashierSupabase: Fetching all cashiers');
      final response = await _client.from('cashiers').select('*, warehouse:warehouse_id(*)').order('name');
      return (response as List).map((json) => _mapSupabaseToCashierModel(json)).toList();
    } catch (e) {
      log('CashierSupabase: Error fetching cashiers - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> createCashier({
    required String name,
    required String arName,
    String? warehouseId,
    required bool status,
  }) async {
    try {
      log('CashierSupabase: Creating cashier: $name');
      await _client.from('cashiers').insert({
        'name': name,
        'ar_name': arName,
        'warehouse_id': warehouseId,
        'status': status,
      });
    } catch (e) {
      log('CashierSupabase: Error creating cashier - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> updateCashier({
    required String id,
    required String name,
    required String arName,
    String? warehouseId,
    required bool status,
  }) async {
    try {
      log('CashierSupabase: Updating cashier: $id');
      await _client.from('cashiers').update({
        'name': name,
        'ar_name': arName,
        'warehouse_id': warehouseId,
        'status': status,
      }).eq('id', id);
    } catch (e) {
      log('CashierSupabase: Error updating cashier - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteCashier(String id) async {
    try {
      log('CashierSupabase: Deleting cashier: $id');
      await _client.from('cashiers').delete().eq('id', id);
    } catch (e) {
      log('CashierSupabase: Error deleting cashier - $e');
      throw Exception(SupabaseErrorHandler.handleError(e));
    }
  }

  CashierModel _mapSupabaseToCashierModel(Map<String, dynamic> json) {
    final warehouse = json['warehouse'] as Map<String, dynamic>?;
    return CashierModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      arName: json['ar_name'] ?? '',
      warehouse: warehouse != null ? WarehouseFromCashier(
        id: warehouse['id'] ?? '',
        name: warehouse['name'] ?? '',
      ) : WarehouseFromCashier(id: '', name: ''),
      status: json['status'] ?? true,
      cashierActive: json['cashier_active'] ?? true,
      version: json['version'] ?? 1,
      createdAt: json['created_at'] != null ? json['created_at'].toString() : DateTime.now().toIso8601String(),
      updatedAt: json['updated_at'] != null ? json['updated_at'].toString() : DateTime.now().toIso8601String(),
      users: [],
      bankAccounts: [],
    );
  }
}

/// Dio implementation for Cashier data source (legacy)
class _CashierDioDataSource implements CashierRepositoryInterface {
  @override
  Future<List<CashierModel>> getAllCashiers() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.getAllCashiers);
      if (response.statusCode == 200) {
        final model = CashierResponse.fromJson(response.data);
        return model.data.cashiers;
      }
      throw Exception(ErrorHandler.handleError(response));
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> createCashier({
    required String name,
    required String arName,
    String? warehouseId,
    required bool status,
  }) async {
    try {
      final response = await DioHelper.postData(
        url: EndPoint.createCashier,
        data: {
          'name': name,
          'ar_name': arName,
          'warehouse_id': warehouseId,
          'status': status,
        },
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> updateCashier({
    required String id,
    required String name,
    required String arName,
    String? warehouseId,
    required bool status,
  }) async {
    try {
      final response = await DioHelper.putData(
        url: EndPoint.updateCashier(id),
        data: {
          'name': name,
          'ar_name': arName,
          'warehouse_id': warehouseId,
          'status': status,
        },
      );
      if (response.statusCode != 200) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }

  @override
  Future<void> deleteCashier(String id) async {
    try {
      final response = await DioHelper.deleteData(url: EndPoint.deleteCashier(id));
      if (response.statusCode != 200) {
        throw Exception(ErrorHandler.handleError(response));
      }
    } catch (e) {
      throw Exception(ErrorHandler.handleError(e));
    }
  }
}
