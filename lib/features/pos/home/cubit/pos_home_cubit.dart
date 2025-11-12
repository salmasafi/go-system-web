// lib/features/pos/home/cubit/pos_home_cubit.dart
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/dio_helper.dart';
import '../../../../core/services/endpoints.dart';
import '../../../../core/utils/error_handler.dart';
import '../model/pos_models.dart';
import 'pos_home_state.dart';

class PosCubit extends Cubit<PosState> {
  PosCubit() : super(PosInitial());

  String selectedTab = 'featured';
  bool showCategoryFilters = false;
  bool showBrandFilters = false;

  List<Category> categories = [];
  List<Brand> brands = [];
  List<Product> categoryProducts = [];
  List<Product> brandProducts = [];
  List<Product> featuredProducts = [];

  // Selections
  List<Warehouse> warehouses = [];
  List<Customer> customers = [];
  List<PaymentMethod> paymentMethods = [];

  // Selected filters
  String? selectedCategoryId;
  String? selectedBrandId;

  // NEW: expose current selected IDs
  String? get currentCategoryId => selectedCategoryId;
  String? get currentBrandId => selectedBrandId;

  // NEW: clear filter and go back to featured
  void clearFilter() {
    selectedTab = 'featured';
    selectedCategoryId = null;
    selectedBrandId = null;
    showBrandFilters = false;
    showCategoryFilters = false;
    categoryProducts = [];
    brandProducts = [];
    emit(PosDataLoaded(featuredProducts));
  }

  String _extractErrorMessage(dynamic errorOrResponse) {
    if (errorOrResponse is Map<String, dynamic>) {
      return errorOrResponse['message']?.toString() ?? 'Unknown error occurred';
    } else if (errorOrResponse is Response) {
      final data = errorOrResponse.data;
      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ??
            'Server error: ${errorOrResponse.statusCode}';
      }
      return 'Server error: ${errorOrResponse.statusCode}';
    }
    return ErrorHandler.handleError(errorOrResponse);
  }

  // Load all initial data
  Future<void> loadPosData() async {
    emit(PosLoading());
    try {
      await Future.wait([
        getCategories(),
        getBrands(),
        getSelections(),
        getFeaturedProducts(),
      ]);
      emit(PosLoaded());
      await selectTab(isEmit: true);
    } catch (e) {
      final msg = _extractErrorMessage(e);
      emit(PosError(msg));
    }
  }

  Future<void> getCategories() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.posCategories);
      if (response.statusCode == 200) {
        final data = response.data['data']['category'] as List;
        categories = data.map((e) => Category.fromJson(e)).toList();
        if (selectedCategoryId == null && categories.isNotEmpty) {
          //selectedCategoryId = categories.first.id;
          //await getProductsByCategory(selectedCategoryId);
        }
      }
    } catch (e) {
      log('Categories error: $e');
    }
  }

  Future<void> getBrands() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.posBrands);
      if (response.statusCode == 200) {
        final data = response.data['data']['brand'] as List;
        brands = data.map((e) => Brand.fromJson(e)).toList();
        if (selectedBrandId == null && brands.isNotEmpty) {
          //selectedBrandId = brands.first.id;
          //await getProductsByBrand(selectedBrandId!);
        }
      }
    } catch (e) {
      log('Brands error: $e');
    }
  }

  Future<void> getFeaturedProducts() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.posFeatured);
      if (response.statusCode == 200) {
        final data = response.data['data']['products'] as List;
        featuredProducts = data.map((e) => Product.fromJson(e)).toList();
      }
    } catch (e) {
      log('Featured error: $e');
    }
  }

  Future<void> getSelections() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.posSelections);
      if (response.statusCode == 200) {
        final json = response.data['data'];
        warehouses = (json['warehouses'] as List)
            .map((e) => Warehouse.fromJson(e))
            .toList();
        customers = (json['customers'] as List)
            .map((e) => Customer.fromJson(e))
            .toList();
        paymentMethods = (json['paymentMethods'] as List)
            .map((e) => PaymentMethod.fromJson(e))
            .toList();
      }
    } catch (e) {
      log('Selections error: $e');
    }
  }

  Future<void> getProductsByCategory(String? categoryId) async {
    emit(PosProductsLoading());
    if (categoryId != null) {
      emit(PosProductsLoading());
      try {
        final response = await DioHelper.getData(
          url: EndPoint.posCategoryProducts(categoryId),
        );
        if (response.statusCode == 200) {
          final data = response.data['data']['products'] as List;
          categoryProducts = data.map((e) => Product.fromJson(e)).toList();
          selectedCategoryId = categoryId;
          hideFilterPanels(); // CHANGED: emit PosDataLoaded
          emit(PosDataLoaded(categoryProducts));
        }
      } catch (e) {
        final msg = _extractErrorMessage(e);
        emit(PosError(msg));
      }
    } else {
      emit(PosDataLoaded([]));
    }
  }

  Future<void> getProductsByBrand(String? brandId) async {
    emit(PosProductsLoading());
    if (brandId != null) {
      try {
        final response = await DioHelper.getData(
          url: EndPoint.posBrandProducts(brandId),
        );
        if (response.statusCode == 200) {
          final data = response.data['data']['products'] as List;
          brandProducts = data.map((e) => Product.fromJson(e)).toList();
          selectedBrandId = brandId;
          hideFilterPanels();
          // CHANGED: emit PosDataLoaded
          emit(PosDataLoaded(brandProducts));
        }
      } catch (e) {
        final msg = _extractErrorMessage(e);
        emit(PosError(msg));
      }
    } else {
      emit(PosDataLoaded([]));
    }
  }

  Future<void> selectTab({String tab = 'featured', bool isEmit = false}) async {
    // emit(PosProductsLoading());
    selectedTab = tab;
    if (tab == 'featured') {
      hideFilterPanels();
      //  if (isEmit) {
      emit(PosDataLoaded(featuredProducts));
      // }
    } else if (tab == 'category') {
      showFilterPanel(isCategory: true);
      emit(PosDataLoaded(featuredProducts));

      // getProductsByCategory(selectedCategoryId);
      emit(PosDataLoaded(categoryProducts));
    } else if (tab == 'brand') {
      showFilterPanel(isCategory: false);
      emit(PosDataLoaded(brandProducts));

      // getProductsByBrand(selectedBrandId);
    } else {
      emit(PosDataLoaded([]));
    }
  }

  Future<void> showFilterPanel({required bool isCategory}) async {
    if (isCategory) {
      showCategoryFilters = true;
      showBrandFilters = false;
    } else {
      showCategoryFilters = false;
      showBrandFilters = true;
    }
  }

  Future<void> hideFilterPanels({
    bool isCategoryRefresh = false,
    bool isBrandRefresh = false,
  }) async {
    // if (isCategoryRefresh || isBrandRefresh) {
    //   emit(PosProductsLoading());
    // }
    showCategoryFilters = false;
    showBrandFilters = false;

    if (isCategoryRefresh || isBrandRefresh) {
      if (isCategoryRefresh) {
        emit(PosDataLoaded(categoryProducts));
      } else {
        emit(PosDataLoaded(brandProducts));
      }
    }
  }
}
