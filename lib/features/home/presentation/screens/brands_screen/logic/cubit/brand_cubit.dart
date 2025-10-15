import 'dart:io';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/features/home/presentation/screens/brands_screen/logic/model/get_brand_by_id_model.dart';
//import '../../../../../../../core/services/cache_helper.dart.dart';
import '../../../../../../../core/services/dio_helper.dart';
import '../../../../../../../core/services/end_point.dart';
import '../../../../../../../core/utils/error_handler.dart';
import '../model/get_brands_model.dart';
import '../model/create_brand_model.dart';
import '../model/delete_brand_model.dart';
import 'brand_states.dart';

class BrandsCubit extends Cubit<BrandsState> {
  BrandsCubit() : super(BrandsInitial());

  static BrandsCubit get(context) => BlocProvider.of(context);

  CreateBrandModel? brandModel;
  List<Brands> allBrands = [];
  BrandById? selectedBrand;

  Future<void> getBrands() async {
    emit(GetBrandsLoading());
    try {
    //  final token = CacheHelper.getData(key: 'token') as String?;
      final response = await DioHelper.getData(
        url: EndPoint.getBrands,
       // token: token,
      );

      if (response.statusCode == 200) {
        final model = GeBrandsModel.fromJson(response.data);
        if (model.success == true && model.data != null) {
          allBrands = model.data!.brands ?? [];
          emit(GetBrandsSuccess(allBrands));
        } else {
          final errorMessage = ErrorHandler.handleError(response);
          emit(GetBrandsError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(GetBrandsError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(GetBrandsError(errorMessage));
    }
  }

  Future<void> getBrandById(String brandId) async {
    emit(GetBrandByIdLoading());
    try {
    //  final token = CacheHelper.getData(key: 'token') as String?;
      final response = await DioHelper.getData(
        url: EndPoint.getBrandById(brandId),
        //token: token,
      );

      if (response.statusCode == 200) {
        final model = GetBrandByIdModel.fromJson(response.data);
        if (model.success == true && model.data?.brand != null) {
          selectedBrand = model.data!.brand;
          emit(GetBrandByIdSuccess(selectedBrand!));
        } else {
          final errorMessage = ErrorHandler.handleError(response);
          emit(GetBrandByIdError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(GetBrandByIdError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(GetBrandByIdError(errorMessage));
    }
  }

  Future<void> createBrand({
    required String name,
    required File logoFile,
  }) async {
    emit(CreateBrandLoading());
    try {
      if (await logoFile.length() > 5 * 1024 * 1024) {
        emit(CreateBrandError('Image exceeds 5MB'));
        return;
      }

  //    final token = CacheHelper.getData(key: 'token') as String?;
      final bytes = await logoFile.readAsBytes();
      final base64Logo = base64Encode(bytes);

      final data = {
        'name': name,
        'logo': base64Logo,
      };

      final response = await DioHelper.postData(
        url: EndPoint.createBrand,
        data: data,
     //   token: token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        brandModel = CreateBrandModel.fromJson(response.data);
        if (brandModel?.success == true) {
          await getBrands();
          emit(CreateBrandSuccess(
            brandModel?.data?.message ?? 'Brand created successfully',
          ));
        } else {
          final errorMessage = ErrorHandler.handleError(response);
          emit(CreateBrandError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(CreateBrandError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(CreateBrandError(errorMessage));
    }
  }

  Future<void> updateBrand({
    required String brandId,
    required String name,
    File? logoFile,
  }) async {
    emit(UpdateBrandLoading());
    try {
   //   final token = CacheHelper.getData(key: 'token') as String?;
      final data = <String, dynamic>{'name': name};

      if (logoFile != null) {
        if (await logoFile.length() > 5 * 1024 * 1024) {
          emit(UpdateBrandError('Image exceeds 5MB'));
          return;
        }
        final bytes = await logoFile.readAsBytes();
        data['logo'] = base64Encode(bytes);
      }

      final response = await DioHelper.putData(
        url: EndPoint.getBrandById(brandId),
        data: data,
    //    token: token,
      );

      if (response.statusCode == 200) {
        brandModel = CreateBrandModel.fromJson(response.data);
        if (brandModel?.success == true) {
          await getBrands();
          emit(UpdateBrandSuccess(
            brandModel?.data?.message ?? 'Brand updated successfully',
          ));
        } else {
          final errorMessage = ErrorHandler.handleError(response);
          emit(UpdateBrandError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(UpdateBrandError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(UpdateBrandError(errorMessage));
    }
  }

  Future<void> deleteBrand(String brandId) async {
    emit(DeleteBrandLoading());
    try {
      //final token = CacheHelper.getData(key: 'token') as String?;
      final response = await DioHelper.deleteData(
        url: EndPoint.getBrandById(brandId),
       // token: token,
      );

      if (response.statusCode == 200) {
        final model = DeleteBrandModel.fromJson(response.data);
        if (model.success == true) {
          allBrands.removeWhere((brand) => brand.id == brandId);
          if (selectedBrand?.id == brandId) {
            selectedBrand = null;
          }
          emit(DeleteBrandSuccess(
            model.data?.message ?? 'Brand deleted successfully',
          ));
        } else {
          final errorMessage = ErrorHandler.handleError(response);
          emit(DeleteBrandError(errorMessage));
        }
      } else {
        final errorMessage = ErrorHandler.handleError(response);
        emit(DeleteBrandError(errorMessage));
      }
    } catch (e) {
      final errorMessage = ErrorHandler.handleError(e);
      emit(DeleteBrandError(errorMessage));
    }
  }
}