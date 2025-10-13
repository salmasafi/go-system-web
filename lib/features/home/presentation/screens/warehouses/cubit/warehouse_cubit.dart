import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/features/home/presentation/screens/warehouses/cubit/warehouse_state.dart';

import '../../../../../../core/services/cache_helper.dart.dart';
import '../../../../../../core/services/dio_helper.dart';
import '../../../../../../core/services/end_point.dart';
import '../data/model/ware_house_model.dart';


class WareHouseCubit extends Cubit<WarehousesState> {
  WareHouseCubit() : super(WarehousesInitial());

  WareHouseModel? warehouseModel;
  List<Warehouses> warehouses = [];

  // Method لجلب الـ warehouses
  Future<void> getWarehouses() async {
    emit(WarehousesLoading());

    try {
      // جلب الـ token من الـ cache
      final token = CacheHelper.getData(key: 'token');

      print('🔑 Token: $token');

      // عمل request للـ API
      final response = await DioHelper.getData(
        url: EndPoint.warehouses,
        token: token,
      );

      print('📊 Response Status Code: ${response.statusCode}');
      print('📦 Response Data: ${response.data}');

      // التحقق من نجاح الـ request
      if (response.statusCode == 200) {
        // تحويل الـ response لـ Model
        warehouseModel = WareHouseModel.fromJson(response.data);

        // جلب الـ warehouses من الـ Model (already converted to Warehouses objects)
        warehouses = warehouseModel?.data?.warehouses ?? [];

        print('✅ Warehouses loaded successfully: ${warehouses.length} items');
        print('📋 Message: ${warehouseModel?.data?.message}');
        print('📦 First warehouse type: ${warehouses.isNotEmpty ? warehouses.first.runtimeType : "empty"}');

        emit(WarehousesSuccess());
      } else {
        print('❌ Failed with status: ${response.statusCode}');
        emit(WarehousesError('Failed to load warehouses: ${response.statusCode}'));
      }
    } catch (error) {
      print('❌ Error: $error');
      emit(WarehousesError(error.toString()));
    }
  }

  // Method إضافية لتحديث warehouse معين
  // Future<void> updateWarehouse({
  //   required String id,
  //   required Map<String, dynamic> data,
  // }) async {
  //   emit(WarehousesLoading());
  //
  //   try {
  //     final token = CacheHelper.getData(key: 'token');
  //
  //     final response = await DioHelper.patchData(
  //       url: '${EndPoints.warehouses}/$id',
  //       data: data,
  //       token: token,
  //     );
  //
  //     if (response.statusCode == 200) {
  //       // تحديث القائمة المحلية
  //       await getWarehouses();
  //       emit(WarehousesSuccess());
  //     } else {
  //       emit(WarehousesError('Failed to update warehouse'));
  //     }
  //   } catch (error) {
  //     emit(WarehousesError(error.toString()));
  //   }
  // }

  // Method لحذف warehouse
  // Future<void> deleteWarehouse(String id) async {
  //   emit(WarehousesLoading());
  //
  //   try {
  //     final token = CacheHelper.getData(key: 'token');
  //
  //     final response = await DioHelper.deleteData(
  //       url: '${EndPoints.warehouses}/$id',
  //       token: token,
  //     );
  //
  //     if (response.statusCode == 200) {
  //       // تحديث القائمة بعد الحذف
  //       await getWarehouses();
  //       emit(WarehousesSuccess());
  //     } else {
  //       emit(WarehousesError('Failed to delete warehouse'));
  //     }
  //   } catch (error) {
  //     emit(WarehousesError(error.toString()));
  //   }
  // }
}