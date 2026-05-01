import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/features/admin/brands/model/get_brand_by_id_model.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../model/get_brands_model.dart';
import 'brand_states.dart';

import 'package:systego/features/admin/brands/data/repositories/brand_repository.dart';

class BrandsCubit extends Cubit<BrandsState> {
  final BrandRepository _repository;
  BrandsCubit(this._repository) : super(BrandsInitial());

  static BrandsCubit get(context) => BlocProvider.of(context);

  List<Brands> allBrands = [];
  BrandById? selectedBrand;

  Future<void> getBrands() async {
    emit(GetBrandsLoading());
    try {
      final brands = await _repository.getAllBrands();
      allBrands = brands;
      emit(GetBrandsSuccess(brands));
    } catch (e) {
      emit(GetBrandsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> getBrandById(String brandId) async {
    emit(GetBrandByIdLoading());
    try {
      final brand = await _repository.getBrandById(brandId);
      if (brand != null) {
        // Map Brands to BrandById if necessary for the UI
        selectedBrand = BrandById(
          id: brand.id,
          name: brand.name,
          arName: brand.arName,
          logo: brand.logo,
          createdAt: brand.createdAt,
          updatedAt: brand.updatedAt,
          v: brand.v,
        );
        emit(GetBrandByIdSuccess(selectedBrand!));
      } else {
        emit(GetBrandByIdError('Brand not found'));
      }
    } catch (e) {
      emit(GetBrandByIdError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createBrand({
    required String name,
    required String arName,
    File? logoFile,
  }) async {
    emit(CreateBrandLoading());
    try {
      await _repository.createBrand(
        name: name,
        arName: arName,
        logoFile: logoFile,
      );
      await getBrands();
      emit(CreateBrandSuccess(LocaleKeys.success.tr()));
    } catch (e) {
      emit(CreateBrandError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateBrand({
    required String brandId,
    required String name,
    required String arName,
    File? logoFile,
  }) async {
    emit(UpdateBrandLoading());
    try {
      await _repository.updateBrand(
        id: brandId,
        name: name,
        arName: arName,
        logoFile: logoFile,
      );
      await getBrands();
      emit(UpdateBrandSuccess(LocaleKeys.success.tr()));
    } catch (e) {
      emit(UpdateBrandError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> deleteBrand(String brandId) async {
    emit(DeleteBrandLoading());
    try {
      await _repository.deleteBrand(brandId);
      allBrands.removeWhere((brand) => brand.id == brandId);
      if (selectedBrand?.id == brandId) selectedBrand = null;
      emit(DeleteBrandSuccess(LocaleKeys.success.tr()));
    } catch (e) {
      emit(DeleteBrandError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

