import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/features/admin/warehouses/cubit/warehouse_state.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../core/services/dio_helper.dart';
import '../../../../core/services/endpoints.dart';
import '../../../../core/utils/error_handler.dart';
import '../model/ware_house_model.dart';

import 'package:systego/features/admin/warehouses/data/repositories/warehouse_repository.dart';

class WareHouseCubit extends Cubit<WarehousesState> {
  final WarehouseRepository _repository;
  WareHouseCubit(this._repository) : super(WarehousesInitial());

  List<Warehouses> warehouses = [];

  String getWarehouseNameById(String warehouseId) {
    try {
      return warehouses.firstWhere((w) => w.id == warehouseId).name;
    } catch (e) {
      return warehouseId;
    }
  }

  Future<void> getWarehouses() async {
    emit(WarehousesLoading());
    try {
      final list = await _repository.getAllWarehouses();
      warehouses = list;
      emit(WarehousesLoaded(list));
    } catch (error) {
      log(' Error: $error');
      emit(WarehousesError(error.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> getWarehouse(String id) async {
    emit(WarehousesLoading());
    try {
      final warehouse = await _repository.getWarehouseById(id);
      if (warehouse != null) {
        emit(WarehousesSuccess());
      } else {
        emit(WarehousesError(LocaleKeys.failed_to_load_warehouses.tr()));
      }
    } catch (error) {
      log(' Error: $error');
      emit(WarehousesError(error.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createWarehouse({
    required String name,
    required String address,
    required String phone,
    required String email,
  }) async {
    emit(WarehouseCreating());
    try {
      await _repository.createWarehouse(
        name: name,
        address: address,
        phone: phone,
        email: email,
      );
      emit(WarehouseCreated());
      await getWarehouses();
    } catch (error) {
      log(' Create Error: $error');
      emit(WarehousesError(error.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateWarehouse({
    required String warehouseId,
    required String name,
    required String address,
    required String phone,
    required String email,
  }) async {
    emit(WarehouseUpdating());
    try {
      await _repository.updateWarehouse(
        id: warehouseId,
        name: name,
        address: address,
        phone: phone,
        email: email,
      );
      emit(WarehouseUpdated());
      await getWarehouses();
    } catch (error) {
      log(' Update Error: $error');
      emit(WarehousesError(error.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteWarehouse({required String warehouseId}) async {
    emit(WarehouseDeleting());
    try {
      await _repository.deleteWarehouse(warehouseId);
      warehouses.removeWhere((warehouse) => warehouse.id == warehouseId);
      emit(WarehouseDeleted());
      await getWarehouses();
    } catch (error) {
      log(' Delete Error: $error');
      emit(WarehousesError(error.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<Map<String, dynamic>?> getWarehouseProducts(String warehouseId) async {
    emit(WarehousesLoading());
    try {
      final products = await _repository.getWarehouseProducts(warehouseId);
      emit(WarehousesSuccess());
      return {'products': products};
    } catch (error) {
      log(' Warehouse products fetch error caught: $error');
      emit(WarehousesError(error.toString().replaceAll('Exception: ', '')));
      return null;
    }
  }

  Future<bool> addProductToWarehouse({
    required String productId,
    required String warehouseId,
    required int quantity,
    required int lowStock,
  }) async {
    emit(WarehousesLoading());
    try {
      final success = await _repository.addProductToWarehouse(
        productId: productId,
        warehouseId: warehouseId,
        quantity: quantity,
        lowStock: lowStock,
      );
      if (success) {
        emit(WarehousesSuccess());
      }
      return success;
    } catch (error) {
      log(' Add product error caught: $error');
      emit(WarehousesError(error.toString().replaceAll('Exception: ', '')));
      return false;
    }
  }
}
