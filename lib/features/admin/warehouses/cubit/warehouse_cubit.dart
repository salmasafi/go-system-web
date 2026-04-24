import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/features/admin/warehouses/cubit/warehouse_state.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../core/services/dio_helper.dart';
import '../../../../core/services/endpoints.dart';
import '../../../../core/utils/error_handler.dart';
import '../model/ware_house_model.dart';

class WareHouseCubit extends Cubit<WarehousesState> {
  WareHouseCubit() : super(WarehousesInitial());

  WareHouseModel? warehouseModel;
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
      //final token = CacheHelper.getData(key: 'token');

      //log(' Token: $token');

      final response = await DioHelper.getData(
        url: EndPoint.getWarehouses,
        // token: token,
      );

      log(' Response Status Code: ${response.statusCode}');
      log(' Response Data: ${response.data}');

      if (response.statusCode == 200) {
        warehouseModel = WareHouseModel.fromJson(response.data);

        warehouses = warehouseModel?.data?.warehouses ?? [];

        log(' Warehouses loaded successfully: ${warehouses.length} items');
        log(' Message: ${warehouseModel?.data?.message}');
        log(
          ' First warehouse type: ${warehouses.isNotEmpty ? warehouses.first.runtimeType : "empty"}',
        );
        log(' Warehouses loaded successfully: $warehouses');
        emit(WarehousesLoaded(warehouses));

        // emit(WarehousesSuccess());

        
      } else {
        log(' Failed with status: ${response.statusCode}');
        emit(
          WarehousesError('${LocaleKeys.failed_to_load_warehouses.tr()} ${response.statusCode}'),
        );
      }
    } catch (error) {
      log(' Error: $error');
      emit(WarehousesError(error.toString()));
    }
  }

  
  Future<void> getWarehouse(String id) async {
    emit(WarehousesLoading());

    try {
      final response = await DioHelper.getData(
        url: EndPoint.getWareHouseById(id),
      );


      if (response.statusCode == 200) {
        emit(WarehousesSuccess());
      } else {
        log(' Failed with status: ${response.statusCode}');
        emit(
          WarehousesError('${LocaleKeys.failed_to_load_warehouses.tr()} ${response.statusCode}'),
        );
      }
    } catch (error) {
      log(' Error: $error');
      emit(WarehousesError(error.toString()));
    }
  }


  /// Create Warehouse
  Future<void> createWarehouse({
    required String name,
    required String address,
    required String phone,
    required String email,
  }) async {
    emit(WarehouseCreating());

    try {
      //  final token = CacheHelper.getData(key: 'token');

      log(' Creating warehouse with name: $name');

      final response = await DioHelper.postData(
        url: EndPoint.createWarehouse,
        // token: token,
        data: {
          'name': name,
          'address': address,
          'phone': phone,
          'email': email,
        },
      );

      log(' Create Response Status Code: ${response.statusCode}');
      log(' Create Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        log(' Warehouse created successfully');
        emit(WarehouseCreated());

        // Refresh warehouses list
        await getWarehouses();
      } else {
        log(' Failed to create warehouse: ${response.statusCode}');
        emit(
          WarehousesError('${LocaleKeys.failed_to_create_warehouse.tr()} ${response.statusCode}'),
        );
      }
    } catch (error) {
      log(' Create Error: $error');
      emit(WarehousesError(error.toString()));
    }
  }

  /// Update Warehouse
  Future<void> updateWarehouse({
    required String warehouseId,
    required String name,
    required String address,
    required String phone,
    required String email,
  }) async {
    emit(WarehouseUpdating());

    try {
      // final token = CacheHelper.getData(key: 'token');

      log(' Updating warehouse ID: $warehouseId');

      final response = await DioHelper.putData(
        url: '${EndPoint.updateWarehouse}/$warehouseId',
        // token: token,
        data: {
          'name': name,
          'address': address,
          'phone': phone,
          'email': email,
        },
      );

      log(' Update Response Status Code: ${response.statusCode}');
      log(' Update Response Data: ${response.data}');

      if (response.statusCode == 200) {
        log(' Warehouse updated successfully');
        emit(WarehouseUpdated());

        // Refresh warehouses list
        await getWarehouses();
      } else {
        log(' Failed to update warehouse: ${response.statusCode}');
        emit(
          WarehousesError('${LocaleKeys.failed_to_update_warehouse.tr()} ${response.statusCode}'),
        );
      }
    } catch (error) {
      log(' Update Error: $error');
      emit(WarehousesError(error.toString()));
    }
  }

  /// Delete Warehouse
  Future<void> deleteWarehouse({required String warehouseId}) async {
    emit(WarehouseDeleting());

    try {
      // final token = CacheHelper.getData(key: 'token');

      log(' Deleting warehouse ID: $warehouseId');

      final response = await DioHelper.deleteData(
        url: '${EndPoint.deleteWarehouse}/$warehouseId',
        // token: token,
      );

      log(' Delete Response Status Code: ${response.statusCode}');
      log(' Delete Response Data: ${response.data}');

      if (response.statusCode == 200) {
        log(' Warehouse deleted successfully');

        /// Remove from local list
        warehouses.removeWhere((warehouse) => warehouse.id == warehouseId);

        emit(WarehouseDeleted());

        /// Refresh warehouses list
        await getWarehouses();
      } else {
        log(' Failed to delete warehouse: ${response.statusCode}');
       emit(
          WarehousesError('${LocaleKeys.failed_to_delete_warehouse.tr()} ${response.statusCode}'),
        );
      }
    } catch (error) {
      log(' Delete Error: $error');
      emit(WarehousesError(error.toString()));
    }
  }

  /// Get Warehouse Products
  Future<Map<String, dynamic>?> getWarehouseProducts(String warehouseId) async {
    emit(WarehousesLoading());

    try {
      log(' Fetching products for warehouse ID: $warehouseId');

      final response = await DioHelper.getData(
        url: EndPoint.getWareHouseProducts(warehouseId),
      );

      log(' Warehouse Products Response Status Code: ${response.statusCode}');
      log(' Warehouse Products Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          log(' Warehouse products fetched successfully');
          emit(WarehousesSuccess());
          return data['data'];
        } else {
          final errorMessage = data['message'] ?? 'Failed to fetch warehouse products';
          log(' Warehouse products fetch failed: $errorMessage');
          emit(WarehousesError(errorMessage));
          return null;
        }
      } else {
        final errorMessage = 'Failed to fetch warehouse products: ${response.statusCode}';
        log(' Response error: $errorMessage');
        emit(WarehousesError(errorMessage));
        return null;
      }
    } catch (error) {
      log(' Warehouse products fetch error caught: $error');
      final errorMessage = ErrorHandler.handleError(error);
      emit(WarehousesError(errorMessage));
      return null;
    }
  }

  /// Add Product to Warehouse
  Future<bool> addProductToWarehouse({
    required String productId,
    required String warehouseId,
    required int quantity,
    required int lowStock,
  }) async {
    emit(WarehousesLoading());

    try {
      log(' Adding product $productId to warehouse $warehouseId');

      final response = await DioHelper.postData(
        url: EndPoint.addProductToWarehouse(warehouseId),
        data: {
          'productId': productId,
          'warehouseId': warehouseId,
          'quantity': quantity,
          'low_stock': lowStock,
        },
      );

      log(' Add Product Response Status Code: ${response.statusCode}');
      log(' Add Product Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          log(' Product added to warehouse successfully');
          emit(WarehousesSuccess());
          return true;
        } else {
          final errorMessage = data['message'] ?? 'Failed to add product to warehouse';
          log(' Add product failed: $errorMessage');
          emit(WarehousesError(errorMessage));
          return false;
        }
      } else {
        final errorMessage = 'Failed to add product to warehouse: ${response.statusCode}';
        log(' Response error: $errorMessage');
        emit(WarehousesError(errorMessage));
        return false;
      }
    } catch (error) {
      log(' Add product error caught: $error');
      final errorMessage = ErrorHandler.handleError(error);
      emit(WarehousesError(errorMessage));
      return false;
    }
  }
}