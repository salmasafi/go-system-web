import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/services/endpoints.dart';
import 'package:systego/features/suppliers/cubit/supplier_state.dart';
import 'dart:developer';
import '../../../core/services/cache_helper.dart.dart';
import '../../../core/services/dio_helper.dart';
import '../../../core/utils/error_handler.dart';
import '../model/supplier_model.dart' as supplier_list;
import '../model/supplier_whis_id_model.dart' as supplier_details;
import '../model/supplier_whis_id_model.dart';
import 'package:image_picker/image_picker.dart';

class SupplierCubit extends Cubit<SupplierStates> {
  SupplierCubit() : super(SupplierInitial());

  supplier_list.SupplierModel? supplierModel;
  List<supplier_list.Suppliers>? suppliers;
  List<supplier_list.City>? cities;
  List<supplier_list.Country>? countries;

  supplier_details.SupplierWhisIdModel? supplierWhisIdModel;
  supplier_details.Supplier? currentSupplier;

  String? getToken() {
    return CacheHelper.getData(key: 'token');
  }

  Future<void> getSuppliers() async {
    emit(SupplierLoading());

    try {
      final token = getToken();

      final response = await DioHelper.getData(
        url: EndPoint.getSuppliers,
        token: token,
      );

      log('Suppliers Response: ${response.data}');

      if (response.statusCode == 200) {
        supplierModel = supplier_list.SupplierModel.fromJson(response.data);
        suppliers = supplierModel?.data?.suppliers;
        cities = supplierModel?.data?.city;
        countries = supplierModel?.data?.country;

        log('Suppliers Count: ${suppliers?.length}');
        log('Cities Count: ${cities?.length}');
        log('Countries Count: ${countries?.length}');

        emit(SupplierSuccess());
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        log('Error: $errorMessage');
        emit(SupplierError(errorMessage));
      }
    } catch (error) {
      final errorMessage = ErrorHandler.handleError(error);
      log('Exception: $errorMessage');
      emit(SupplierError(errorMessage));
    }
  }

  Future<void> getSupplierById(String id) async {
    emit(SupplierLoading());

    try {
      final token = getToken();

      final response = await DioHelper.getData(
        url: EndPoint.getSupplierById(id),
        token: token,
      );

      log('Supplier Details Response: ${response.data}');

      if (response.statusCode == 200) {
        supplierWhisIdModel = supplier_details.SupplierWhisIdModel.fromJson(response.data);
        currentSupplier = supplierWhisIdModel?.data?.supplier;

        log('Supplier Name: ${currentSupplier?.username}');
        log('Company: ${currentSupplier?.companyName}');

        emit(SupplierSuccess());
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        log('Error: $errorMessage');
        emit(SupplierError(errorMessage));
      }
    } catch (error) {
      final errorMessage = ErrorHandler.handleError(error);
      log('Exception: $errorMessage');
      emit(SupplierError(errorMessage));
    }
  }

  // Convert image file to base64
  Future<String?> convertImageToBase64(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = 'data:image/png;base64,${base64Encode(bytes)}';
      return base64Image;
    } catch (e) {
      log('Error converting image: $e');
      return null;
    }
  }

  Future<void> createSupplier({
    required String username,
    required String email,
    required String phoneNumber,
    required String address,
    required String cityId,
    required String countryId,
    required String companyName,
    XFile? imageFile,
  }) async {
    try {
      final token = getToken();

      String? base64Image;
      if (imageFile != null) {
        base64Image = await convertImageToBase64(imageFile);
      }

      final data = {
        'username': username,
        'email': email,
        'phone_number': phoneNumber,
        'address': address,
        'cityId': cityId,
        'countryId': countryId,
        'company_name': companyName,
        if (base64Image != null) 'image': base64Image,
      };

      final response = await DioHelper.postData(
        url: EndPoint.createSupplier,
        data: data,
        token: token,
      );

      log('Create Supplier Response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        log('Supplier created successfully');
        await getSuppliers();
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        log('Error: $errorMessage');
        emit(SupplierError(errorMessage));
      }
    } catch (error) {
      final errorMessage = ErrorHandler.handleError(error);
      log('Exception: $errorMessage');
      emit(SupplierError(errorMessage));
    }
  }

  Future<void> updateSupplier({
    required String id,
    String? username,
    String? email,
    String? phoneNumber,
    String? address,
    String? cityId,
    String? countryId,
    String? companyName,
    XFile? imageFile,
  }) async {
    try {
      final token = getToken();

      String? base64Image;
      if (imageFile != null) {
        base64Image = await convertImageToBase64(imageFile);
      }

      final data = {
        if (username != null) 'username': username,
        if (email != null) 'email': email,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (address != null) 'address': address,
        if (cityId != null) 'cityId': cityId,
        if (countryId != null) 'countryId': countryId,
        if (companyName != null) 'company_name': companyName,
        if (base64Image != null) 'image': base64Image,
      };

      final response = await DioHelper.putData(
        url: '${EndPoint.updateSupplier}/$id',
        data: data,
        token: token,
      );

      log('Update Supplier Response: ${response.data}');

      if (response.statusCode == 200) {
        log('Supplier updated successfully');
        // أعد تحميل البيانات فوراً
        await getSuppliers();
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        log('Error: $errorMessage');
        emit(SupplierError(errorMessage));
      }
    } catch (error) {
      final errorMessage = ErrorHandler.handleError(error);
      log('Exception: $errorMessage');
      emit(SupplierError(errorMessage));
    }
  }

  Future<void> deleteSupplier(String id) async {
    try {
      final token = getToken();

      final response = await DioHelper.deleteData(
        url: '${EndPoint.deleteSupplier}/$id',
        token: token,
      );

      log('Delete Supplier Response: ${response.data}');

      if (response.statusCode == 200) {
        log('Supplier deleted successfully');
        // أعد تحميل البيانات فوراً
        await getSuppliers();
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        log('Error: $errorMessage');
        emit(SupplierError(errorMessage));
      }
    } catch (error) {
      final errorMessage = ErrorHandler.handleError(error);
      log('Exception: $errorMessage');
      emit(SupplierError(errorMessage));
    }
  }

  List<supplier_list.Suppliers> filterSuppliersByCountry(String countryId) {
    if (suppliers == null) return [];
    return suppliers!
        .where((supplier) => supplier.countryId?.id == countryId)
        .toList();
  }

  List<supplier_list.Suppliers> filterSuppliersByCity(String cityId) {
    if (suppliers == null) return [];
    return suppliers!
        .where((supplier) => supplier.cityId?.id == cityId)
        .toList();
  }

  List<supplier_list.Suppliers> searchSuppliers(String query) {
    if (suppliers == null || query.isEmpty) return suppliers ?? [];

    final lowerQuery = query.toLowerCase();
    return suppliers!.where((supplier) {
      final username = supplier.username?.toLowerCase() ?? '';
      final companyName = supplier.companyName?.toLowerCase() ?? '';
      return username.contains(lowerQuery) || companyName.contains(lowerQuery);
    }).toList();
  }

  List<City>? getCitiesFromSupplierDetails() {
    return supplierWhisIdModel?.data?.city;
  }

  List<Country>? getCountriesFromSupplierDetails() {
    return supplierWhisIdModel?.data?.country;
  }

  List<supplier_list.City> getCitiesByCountry(String countryId) {
    if (cities == null) return [];
    return cities!.where((city) => city.country == countryId).toList();
  }

  void clearCurrentSupplier() {
    currentSupplier = null;
    supplierWhisIdModel = null;
  }
}