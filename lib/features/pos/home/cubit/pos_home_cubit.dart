// lib/features/pos/home/cubit/pos_home_cubit.dart

import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/features/pos/home/cubit/pos_home_state.dart';
import 'package:GoSystem/features/pos/home/model/pos_models.dart';
import 'package:GoSystem/features/admin/discount/model/discount_model.dart';
import '../../../../core/services/dio_helper.dart';
import '../../../../core/services/endpoints.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../generated/locale_keys.g.dart';

class PosCubit extends Cubit<PosState> {
  PosCubit() : super(PosInitial());

  String selectedTab = 'featured';
  bool showCategoryFilters = false;
  bool showBrandFilters = false;
  bool isCategoryProductsLoading = false;
  bool isBrandProductsLoading = false;

  List<Category> categories = [];
  List<Brand> brands = [];
  List<Product> categoryProducts = [];
  List<Product> brandProducts = [];
  List<Product> featuredProducts = [];
  List<BundleModel> bundles = [];

  // Selections
  List<Warehouse> warehouses = [];
  List<Customer> customers = [];
  List<PaymentMethod> paymentMethods = [];
  List<BankAccount> accounts = [];
  BankAccount? selectedAccount;

  List<Tax> taxes = [
    Tax(id: 'null', name: 'No Tax', amount: 0.0, type: 'fixed', status: true),
  ];
  Tax? selectedTax;

  List<DiscountModel> discounts = [
    DiscountModel(
      id: 'null',
      name: 'No Discount',
      amount: 0.0,
      type: 'fixed',
      status: true,
      createdAt: '',
      updatedAt: '',
      version: null,
    ),
  ];
  DiscountModel? selectedDiscount;

  List<Currency> currencies = [];
  Currency? selectedCurrency;

  // Selected filters
  String? selectedCategoryId;
  String? selectedBrandId;
  Warehouse? selectedWarhouse;
  PaymentMethod? selectedPaymentMethod;
  Customer? selectedCustomer;

  String? get currentCategoryId => selectedCategoryId;
  String? get currentBrandId => selectedBrandId;

  // ─── Helpers ───
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
      return errorOrResponse['message']?.toString() ?? LocaleKeys.unknown_error_occurred.tr();
    } else if (errorOrResponse is Response) {
      final data = errorOrResponse.data;
      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ??
            '${LocaleKeys.server_error.tr()}: ${errorOrResponse.statusCode}';
      }
      return '${LocaleKeys.server_error.tr()}: ${errorOrResponse.statusCode}';
    }
    return ErrorHandler.handleError(errorOrResponse);
  }
  // ─── Main Data Loading ───

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
      await selectTab();
    } catch (e) {
      final msg = _extractErrorMessage(e);
      emit(PosError(msg));
    }
  }

  Future<void> getCategories() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.posCategories);
      log('Categories response: ${response.data}');
      if (response.statusCode == 200) {
        // Try different possible response structures
        List<dynamic> data = [];
        
        if (response.data['data'] != null) {
          if (response.data['data']['category'] != null) {
            data = response.data['data']['category'] as List;
          } else if (response.data['data']['categories'] != null) {
            data = response.data['data']['categories'] as List;
          } else if (response.data['data'] is List) {
            data = response.data['data'] as List;
          }
        } else if (response.data['category'] != null) {
          data = response.data['category'] as List;
        } else if (response.data['categories'] != null) {
          data = response.data['categories'] as List;
        } else if (response.data is List) {
          data = response.data as List;
        }
        
        categories = data.map((e) => Category.fromJson(e)).toList();
        log("Loaded ${categories.length} categories");
      } else {
        log('Categories failed with status: ${response.statusCode}');
      }
    } catch (e) {
      log('Categories error: $e');
    }
  }

  Future<void> getBrands() async {
    try {
      final response = await DioHelper.getData(url: EndPoint.posBrands);
      log('Brands response: ${response.data}');
      if (response.statusCode == 200) {
        // Try different possible response structures
        List<dynamic> data = [];
        
        if (response.data['data'] != null) {
          if (response.data['data']['brand'] != null) {
            data = response.data['data']['brand'] as List;
          } else if (response.data['data']['brands'] != null) {
            data = response.data['data']['brands'] as List;
          } else if (response.data['data'] is List) {
            data = response.data['data'] as List;
          }
        } else if (response.data['brand'] != null) {
          data = response.data['brand'] as List;
        } else if (response.data['brands'] != null) {
          data = response.data['brands'] as List;
        } else if (response.data is List) {
          data = response.data as List;
        }
        
        brands = data.map((e) => Brand.fromJson(e)).toList();
        log("Loaded ${brands.length} brands");
      } else {
        log('Brands failed with status: ${response.statusCode}');
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
        // هنا يتم استخدام الموديل المحدث الذي يعالج variations
        featuredProducts = data.map((e) => Product.fromList(e)).toList();

        log("Loaded ${featuredProducts.length} featured products.");
      }
    } catch (e) {
      log('Featured error: $e');
      emit(PosError("Failed to load products: ${e.toString()}"));
    }
  }

  Future<void> getBundles() async {
    try {
      var response = await DioHelper.getData(url: EndPoint.posBundles);
      if (response.statusCode == 200) {
        final data = response.data['data']['bundles'] as List;
        bundles = data.map((b) => BundleModel.fromJson(b)).toList();
      }
    } catch (e) {
      log('Bundles error: $e');
      bundles = [];
    }
  }

  Future<void> getSelections() async {
    // Reset defaults
    taxes = [
      Tax(id: 'null', name: 'No Tax', amount: 0.0, type: 'fixed', status: true),
    ];
    selectedTax = null;
    discounts = [
      DiscountModel(
        id: 'null',
        name: 'No Discount',
        amount: 0.0,
        type: 'fixed',
        status: true,
        createdAt: '',
        updatedAt: '',
        version: null,
      ),
    ];
    selectedDiscount = null;

    try {
      final response = await DioHelper.getData(url: EndPoint.posSelections);
      if (response.statusCode == 200) {
        final json = response.data['data'];

        warehouses = (json['warehouses'] as List)
            .map((e) => Warehouse.fromJson(e))
            .toList();
        selectedWarhouse = warehouses.isNotEmpty ? warehouses.first : null;

        customers = (json['customers'] as List)
            .map((e) => Customer.fromJson(e))
            .toList();
        selectedCustomer = customers.isNotEmpty ? customers.first : null;

        accounts = (json['accounts'] as List? ?? [])
            .map((e) => BankAccount.fromJson(e))
            .toList();
        selectedAccount = accounts.isNotEmpty ? accounts.first : null;

        List<Tax> taxesFromJson = ((json['taxes'] as List?) ?? [])
            .map<Tax>((dynamic e) => Tax.fromJson(e as Map<String, dynamic>))
            .toList();
        var filteredTaxes = taxesFromJson.isNotEmpty
            ? taxesFromJson.where((element) => element.status).toList()
            : null;
        if (filteredTaxes != null) taxes.addAll(filteredTaxes);
        selectedTax = taxes.first;

        List<DiscountModel> discountsFromJson =
            ((json['discounts'] as List?) ?? [])
                .map<DiscountModel>(
                  (dynamic e) =>
                      DiscountModel.fromJson(e as Map<String, dynamic>),
                )
                .toList();
        var filteredDiscounts = discountsFromJson.isNotEmpty
            ? discountsFromJson.where((element) => element.status).toList()
            : null;
        if (filteredDiscounts != null) discounts.addAll(filteredDiscounts);
        selectedDiscount = discounts.first;

        currencies = (json['currencies'] as List? ?? [])
            .map((e) => Currency.fromJson(e))
            .toList();
        selectedCurrency = currencies.isNotEmpty ? currencies.first : null;

        paymentMethods = (json['paymentMethods'] as List)
            .map((e) => PaymentMethod.fromJson(e))
            .toList();
        
        // Select the first payment method with name 'Cash', or just the first one
        selectedPaymentMethod = paymentMethods.isNotEmpty
            ? (paymentMethods.where((element) => element.name == 'Cash').isNotEmpty
                ? paymentMethods.where((element) => element.name == 'Cash').first
                : paymentMethods.first)
            : null;
      }
    } catch (e) {
      log('Selections error: $e');
    }
  }

  // ─── Filter & Selection Updates ───

  // void changeTax(Tax? tax) {
  //   selectedTax = tax;
  // }

  // void changeDiscount(DiscountModel? discount) {
  //   selectedDiscount = discount;
  // }

  // void changeCurrency(Currency currency) {
  //   selectedCurrency = currency;
  // }

  // Future<void> changeWarhouseValue(Warehouse warehouse) async {
  //   selectedWarhouse = warehouse;
  //   selectTab();
  // }

  // Future<void> changeCustomerValue(Customer customer) async {
  //   selectedCustomer = customer;
  //   selectTab();
  // }

  // Future<void> changePaymentMethodValue(PaymentMethod paymentMethod) async {
  //   selectedPaymentMethod = paymentMethod;
  //   selectTab();
  // }

  // ─── Product Listing & Filtering ───

  // ─── Product Listing & Filtering ───

  Future<void> getProductsByCategory(String? categoryId) async {
    isCategoryProductsLoading = true;

    // 1. إغلاق الفلتر فوراً
    showCategoryFilters = false;
    showBrandFilters = false;

    // 2. تصفير القائمة القديمة لمنع ظهور بيانات سابقة
    categoryProducts = [];

    // 3. إظهار التحميل
    emit(PosProductsLoading());

    if (categoryId != null) {
      try {
        final response = await DioHelper.getData(
          url: EndPoint.posCategoryProducts(categoryId),
        );
        if (response.statusCode == 200) {
          final data = response.data['data']['products'] as List;
          categoryProducts = data.map((e) => Product.fromList(e)).toList();
          selectedCategoryId = categoryId;

          // hideFilterPanels(); // لا نحتاج لاستدعائها هنا لأننا أغلقناها في البداية

          isCategoryProductsLoading = false;
          emit(PosDataLoaded(categoryProducts));
        }
      } catch (e) {
        final msg = _extractErrorMessage(e);
        isCategoryProductsLoading = false;
        emit(PosError(msg));
      }
    } else {
      isCategoryProductsLoading = false;
      emit(PosDataLoaded([]));
    }
  }

  Future<void> getProductsByBrand(String? brandId) async {
    isBrandProductsLoading = true;

    // 1. إغلاق الفلتر فوراً
    showCategoryFilters = false;
    showBrandFilters = false;

    // 2. تصفير القائمة القديمة
    brandProducts = [];

    // 3. إظهار التحميل
    emit(PosProductsLoading());

    if (brandId != null) {
      try {
        final response = await DioHelper.getData(
          url: EndPoint.posBrandProducts(brandId),
        );
        if (response.statusCode == 200) {
          final data = response.data['data']['products'] as List;
          brandProducts = data.map((e) => Product.fromList(e)).toList();
          selectedBrandId = brandId;

          // hideFilterPanels(); // تم الإغلاق مسبقاً

          isBrandProductsLoading = false;
          emit(PosDataLoaded(brandProducts));
        }
      } catch (e) {
        final msg = _extractErrorMessage(e);
        isBrandProductsLoading = false;
        emit(PosError(msg));
      }
    } else {
      isBrandProductsLoading = false;
      emit(PosDataLoaded([]));
    }
  }

  Future<void> selectTab({
    String tab = 'category',
    bool noFliterRefresh = false,
  }) async {
    selectedTab = tab;
    if (tab == 'featured') {
      hideFilterPanels();
      emit(PosDataLoaded(featuredProducts));
    } else if (tab == 'category') {
      if (!noFliterRefresh) showFilterPanel(isCategory: true);
      emit(PosDataLoaded(categoryProducts));
    } else if (tab == 'brand') {
      if (!noFliterRefresh) showFilterPanel(isCategory: false);
      emit(PosDataLoaded(brandProducts));
    } else if (tab == 'bundles') {
      hideFilterPanels();
      if (bundles.isEmpty) await getBundles();
      emit(PosBundlesLoaded(bundles));
    } else {
      emit(PosDataLoaded([]));
    }
  }

  Future<void> refreshCartProducts() async {
    await selectTab(tab: selectedTab, noFliterRefresh: true);
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
    showCategoryFilters = false;
    showBrandFilters = false;

    if (isCategoryRefresh) {
      emit(PosDataLoaded(categoryProducts));
    } else if (isBrandRefresh) {
      emit(PosDataLoaded(brandProducts));
    }
  }

  // ─── Barcode Scanning ───

  Future<Product?> getProductByCode(String code) async {
    emit(PosLoading());
    try {
      final response = await DioHelper.postData(
        url: EndPoint.productByCode,
        data: {'code': code},
      );

      if (response.statusCode == 200) {
        final data = response.data['data']['product'];
        if (data != null) {
          final product = Product.fromScan(data);
          return product;
        } else {
          emit(PosError('Product not found'));
          selectTab();
          return null;
        }
      } else {
        final msg = _extractErrorMessage(response);
        emit(PosError(msg));
        selectTab();
        return null;
      }
    } catch (e) {
      final msg = _extractErrorMessage(e);
      emit(PosError(msg));
      selectTab();
      return null;
    }
  }
}
