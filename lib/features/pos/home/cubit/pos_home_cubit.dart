import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/pos/home/cubit/pos_home_state.dart';
import 'package:GoSystem/features/pos/home/model/pos_models.dart';
import 'package:GoSystem/features/admin/discount/model/discount_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  final SupabaseClient _client = SupabaseClientWrapper.instance;

  String _extractErrorMessage(dynamic error) {
    return ErrorHandler.handleError(error);
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
      final response = await _client
          .from('categories')
          .select()
          .order('name');
      
      categories = (response as List).map((e) => Category.fromJson(e)).toList();
      log("Loaded ${categories.length} categories");
    } catch (e) {
      log('Categories error: $e');
    }
  }

  Future<void> getBrands() async {
    try {
      final response = await _client
          .from('brands')
          .select()
          .order('name');
      
      brands = (response as List).map((e) => Brand.fromJson(e)).toList();
      log("Loaded ${brands.length} brands");
    } catch (e) {
      log('Brands error: $e');
    }
  }

  Future<void> getFeaturedProducts() async {
    try {
      final response = await _client
          .from('products')
          .select('''
            *,
            attributes:product_attributes(
              *,
              attribute_type:attribute_type_id(*)
            )
          ''')
          .eq('is_featured', true)
          .eq('status', true);

      featuredProducts = (response as List).map((e) => Product.fromList(e)).toList();
      log("Loaded ${featuredProducts.length} featured products.");
    } catch (e) {
      log('Featured error: $e');
      emit(PosError("Failed to load products: ${e.toString()}"));
    }
  }

  Future<void> getBundles() async {
    try {
      final response = await _client
          .from('bundles')
          .select('''
            *,
            products:bundle_products(
              quantity,
              product:product_id(
                *,
                attributes:product_attributes(
                  *,
                  attribute_type:attribute_type_id(*)
                )
              )
            )
          ''')
          .eq('status', true);

      bundles = (response as List).map((b) => BundleModel.fromJson(b)).toList();
      log("Loaded ${bundles.length} bundles");
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
      final warehousesResponse = await _client.from('warehouses').select();
      warehouses = (warehousesResponse as List).map((e) => Warehouse.fromJson(e)).toList();
      selectedWarhouse = warehouses.isNotEmpty ? warehouses.first : null;

      final customersResponse = await _client.from('customers').select();
      customers = (customersResponse as List).map((e) => Customer.fromJson(e)).toList();
      selectedCustomer = customers.isNotEmpty ? customers.first : null;

      final accountsResponse = await _client.from('bank_accounts').select().eq('status', true);
      accounts = (accountsResponse as List).map((e) => BankAccount.fromJson(e)).toList();
      selectedAccount = accounts.isNotEmpty ? accounts.first : null;

      final taxesResponse = await _client.from('taxes').select().eq('status', true);
      final List<Tax> taxesFromJson = (taxesResponse as List).map((e) => Tax.fromJson(e)).toList();
      taxes.addAll(taxesFromJson);
      selectedTax = taxes.first;

      final discountsResponse = await _client.from('discounts').select().eq('status', true);
      final List<DiscountModel> discountsFromJson = (discountsResponse as List).map((e) => DiscountModel.fromJson(e)).toList();
      discounts.addAll(discountsFromJson);
      selectedDiscount = discounts.first;

      final currenciesResponse = await _client.from('currencies').select();
      currencies = (currenciesResponse as List).map((e) => Currency.fromJson(e)).toList();
      selectedCurrency = currencies.isNotEmpty ? currencies.first : null;

      final paymentMethodsResponse = await _client.from('payment_methods').select().eq('is_active', true);
      paymentMethods = (paymentMethodsResponse as List).map((e) => PaymentMethod.fromJson(e)).toList();
      
      selectedPaymentMethod = paymentMethods.isNotEmpty
          ? (paymentMethods.any((element) => element.name == 'Cash')
              ? paymentMethods.firstWhere((element) => element.name == 'Cash')
              : paymentMethods.first)
          : null;
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
        final response = await _client
            .from('products')
            .select('''
              *,
              attributes:product_attributes(
                *,
                attribute_type:attribute_type_id(*)
              ),
              categories:product_categories!inner(category_id)
            ''')
            .eq('product_categories.category_id', categoryId)
            .eq('status', true);

        categoryProducts = (response as List).map((e) => Product.fromList(e)).toList();
        selectedCategoryId = categoryId;
        isCategoryProductsLoading = false;
        emit(PosDataLoaded(categoryProducts));
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
        final response = await _client
            .from('products')
            .select('''
              *,
              attributes:product_attributes(
                *,
                attribute_type:attribute_type_id(*)
              )
            ''')
            .eq('brand_id', brandId)
            .eq('status', true);

        brandProducts = (response as List).map((e) => Product.fromList(e)).toList();
        selectedBrandId = brandId;
        isBrandProductsLoading = false;
        emit(PosDataLoaded(brandProducts));
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
      final response = await _client
          .from('products')
          .select('''
            *,
            attributes:product_attributes(
              *,
              attribute_type:attribute_type_id(*)
            )
          ''')
          .eq('code', code)
          .maybeSingle();

      if (response != null) {
        final product = Product.fromScan(response);
        return product;
      } else {
        emit(PosError('Product not found'));
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
