import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/supabase/supabase_client.dart';
import '../../../../../core/supabase/supabase_error_handler.dart';
import '../../model/cashirer_model.dart';

/// Interface for cashier data operations
abstract class CashierRepositoryInterface {
  Future<List<CashierModel>> getAllCashiers();
  Future<void> createCashier({
    required String name,
    String? warehouseId,
    required bool status,
  });
  Future<void> updateCashier({
    required String id,
    required String name,
    String? warehouseId,
    required bool status,
  });
  Future<void> deleteCashier(String id);
}

/// Repository implementation using Supabase for cashiers
class CashierRepository implements CashierRepositoryInterface {
  final _CashierSupabaseDataSource _dataSource = _CashierSupabaseDataSource();

  @override
  Future<List<CashierModel>> getAllCashiers() => _dataSource.getAllCashiers();

  @override
  Future<void> createCashier({
    required String name,
    String? warehouseId,
    required bool status,
  }) => _dataSource.createCashier(
        name: name,
        warehouseId: warehouseId,
        status: status,
      );

  @override
  Future<void> updateCashier({
    required String id,
    required String name,
    String? warehouseId,
    required bool status,
  }) => _dataSource.updateCashier(
        id: id,
        name: name,
        warehouseId: warehouseId,
        status: status,
      );

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
    String? warehouseId,
    required bool status,
  }) async {
    try {
      log('CashierSupabase: Creating cashier: $name');
      await _client.from('cashiers').insert({
        'name': name,
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
    String? warehouseId,
    required bool status,
  }) async {
    try {
      log('CashierSupabase: Updating cashier: $id');
      await _client.from('cashiers').update({
        'name': name,
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
