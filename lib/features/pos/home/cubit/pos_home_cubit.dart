// lib/features/pos/home/cubit/pos_home_cubit.dart
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/features/POS/home/cubit/pos_home_state.dart';
import 'package:systego/features/POS/home/model/pos_models.dart';
import 'package:systego/features/admin/discount/model/discount_model.dart';
import '../../../../core/services/dio_helper.dart';
import '../../../../core/services/endpoints.dart';
import '../../../../core/utils/error_handler.dart';

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

  // Expose current selected IDs
  String? get currentCategoryId => selectedCategoryId;
  String? get currentBrandId => selectedBrandId;

  // Clear filter and go back to featured
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
      await selectTab();
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
        featuredProducts = data.map((e) => Product.fromList(e)).toList();
      }
    } catch (e) {
      log('Featured error: $e');
    }
  }

  Future<void> getSelections() async {
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
        // في pos_home_cubit.dart → داخل getSelections()
        final json = response.data['data'];
        log('$json');
        warehouses = (json['warehouses'] as List)
            .map((e) => Warehouse.fromJson(e))
            .toList();
        selectedWarhouse = warehouses.isNotEmpty ? warehouses.first : null;

        customers = (json['customers'] as List)
            .map((e) => Customer.fromJson(e))
            .toList();
        selectedCustomer = customers.isNotEmpty ? customers.first : null;

        // ←←← الجديد: نضيف Account + Tax + Currency
        accounts = (json['accounts'] as List? ?? [])
            .map((e) => BankAccount.fromJson(e))
            .toList();

        // var filteredAccounts = accounts.isNotEmpty
        //     ? accounts.where((element) => element.isDefault)
        //     : null;
        selectedAccount = accounts.first;
        List<Tax> taxesFromJson = ((json['taxes'] as List?) ?? [])
            .map<Tax>((dynamic e) => Tax.fromJson(e as Map<String, dynamic>))
            .toList();

        //taxes.addAll(taxesFromJson);

        var filteredTaxes = taxesFromJson.isNotEmpty
            ? taxesFromJson.where((element) => element.status)
            : null;
        taxes.addAll(filteredTaxes ?? []);

        selectedTax = taxes.first;

        List<DiscountModel> discountsFromJson =
            ((json['discounts'] as List?) ?? [])
                .map<DiscountModel>(
                  (dynamic e) =>
                      DiscountModel.fromJson(e as Map<String, dynamic>),
                )
                .toList();

        //discounts.addAll(discountsFromJson);

        var filteredDiscounts = discountsFromJson.isNotEmpty
            ? discountsFromJson.where((element) => element.status)
            : null;
        discounts.addAll(filteredDiscounts ?? []);

        selectedDiscount = discounts.first;

        currencies = (json['currencies'] as List? ?? [])
            .map((e) => Currency.fromJson(e))
            .toList();
        selectedCurrency = currencies.isNotEmpty ? currencies.first : null;

        paymentMethods = (json['paymentMethods'] as List)
            .map((e) => PaymentMethod.fromJson(e))
            .toList();
        selectedPaymentMethod = paymentMethods.isNotEmpty
            ? paymentMethods.where((element) => element.name == 'Cash').first
            : null;
      }
    } catch (e) {
      log('Selections error: $e');
    }
  }

  void changeAccount(BankAccount account) {
    selectedAccount = account;
    emit(PosDataLoaded(featuredProducts)); // أو أي state
  }

  void changeTax(Tax? tax) {
    selectedTax = tax;
    emit(PosDataLoaded(featuredProducts));
  }

  void changeDiscount(DiscountModel? discount) {
    selectedDiscount = discount;
    emit(PosDataLoaded(featuredProducts));
  }

  void changeCurrency(Currency currency) {
    selectedCurrency = currency;
    emit(PosDataLoaded(featuredProducts));
  }

  Future<void> changeWarhouseValue(Warehouse warehouse) async {
    selectedWarhouse = warehouse;
    selectTab();
  }

  Future<void> changeCustomerValue(Customer customer) async {
    selectedCustomer = customer;
    selectTab();
  }

  Future<void> changePaymentMethodValue(PaymentMethod paymentMethod) async {
    selectedPaymentMethod = paymentMethod;
    selectTab();
  }

  Future<void> getProductsByCategory(String? categoryId) async {
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
          hideFilterPanels();
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
          brandProducts = data.map((e) => Product.fromList(e)).toList();
          selectedBrandId = brandId;
          hideFilterPanels();
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

  Future<void> selectTab({
    String tab = 'featured',
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
    } else {
      emit(PosDataLoaded([]));
    }
  }

  Future<void> refreshCartProducts() async {
    if (selectedTab == 'featured') {
      hideFilterPanels();
      emit(PosDataLoaded(featuredProducts));
    } else if (selectedTab == 'category') {
      showFilterPanel(isCategory: true);
      emit(PosDataLoaded(categoryProducts));
    } else if (selectedTab == 'brand') {
      showFilterPanel(isCategory: false);
      emit(PosDataLoaded(brandProducts));
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

  // ────────────────────────────────────────────────────────────────
  //  NEW: Get product by barcode
  // ────────────────────────────────────────────────────────────────
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
