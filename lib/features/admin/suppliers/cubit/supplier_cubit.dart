import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/features/admin/suppliers/cubit/supplier_state.dart';
import 'dart:developer';
import '../model/supplier_model.dart' as supplier_list;
import '../model/supplier_whis_id_model.dart' as supplier_details;
import '../model/supplier_whis_id_model.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';
import 'package:GoSystem/features/admin/suppliers/data/repositories/supplier_repository.dart';

class SupplierCubit extends Cubit<SupplierStates> {
  final SupplierRepository _repository;
  SupplierCubit(this._repository) : super(SupplierInitial());

  supplier_list.SupplierModel? supplierModel;
  List<supplier_list.Suppliers>? suppliers;
  List<supplier_list.City>? cities;
  List<supplier_list.Country>? countries;

  supplier_details.SupplierWhisIdModel? supplierWhisIdModel;
  supplier_details.Supplier? currentSupplier;

  Future<void> getSuppliers() async {
    emit(SupplierLoading());
    try {
      final supplierList = await _repository.getAllSuppliers();
      suppliers = supplierList;
      emit(SupplierSuccess());
    } catch (error) {
      emit(SupplierError(error.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> getSupplierById(String id) async {
    emit(SupplierLoading());
    try {
      final supplier = await _repository.getSupplierById(id);
      if (supplier != null) {
        currentSupplier = supplier_details.Supplier(
          id: supplier.id,
          username: supplier.username,
          email: supplier.email,
          phoneNumber: supplier.phoneNumber,
          address: supplier.address,
          companyName: supplier.companyName,
          image: supplier.image,
          cityId: supplier.cityId != null ? supplier_details.CityId(id: supplier.cityId!.id, name: supplier.cityId!.name) : null,
          countryId: supplier.countryId != null ? supplier_details.CountryId(id: supplier.countryId!.id, name: supplier.countryId!.name) : null,
          v: supplier.v,
        );
        emit(SupplierSuccess());
      } else {
        emit(SupplierError('Supplier not found'));
      }
    } catch (error) {
      emit(SupplierError(error.toString().replaceAll('Exception: ', '')));
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
    emit(SupplierLoading());
    try {
      await _repository.createSupplier(
        username: username,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
        companyName: companyName,
        countryId: countryId,
        cityId: cityId,
        imageFile: imageFile != null ? File(imageFile.path) : null,
      );
      await getSuppliers();
      emit(SupplierSuccess());
    } catch (error) {
      emit(SupplierError(error.toString().replaceAll('Exception: ', '')));
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
    emit(SupplierLoading());
    try {
      // Get current values if not provided to satisfy repo interface
      final current = await _repository.getSupplierById(id);
      if (current == null) throw Exception('Supplier not found');

      await _repository.updateSupplier(
        id: id,
        username: username ?? current.username ?? '',
        email: email ?? current.email ?? '',
        phoneNumber: phoneNumber ?? current.phoneNumber ?? '',
        address: address ?? current.address ?? '',
        companyName: companyName ?? current.companyName ?? '',
        countryId: countryId ?? current.countryId?.id,
        cityId: cityId ?? current.cityId?.id,
        imageFile: imageFile != null ? File(imageFile.path) : null,
      );
      await getSuppliers();
      emit(SupplierSuccess());
    } catch (error) {
      emit(SupplierError(error.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteSupplier(String id) async {
    emit(SupplierLoading());
    try {
      await _repository.deleteSupplier(id);
      await getSuppliers();
      emit(SupplierSuccess());
    } catch (error) {
      emit(SupplierError(error.toString().replaceAll('Exception: ', '')));
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

