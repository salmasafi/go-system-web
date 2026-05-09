import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/services/cache_helper.dart';
import 'package:GoSystem/core/supabase/supabase_client.dart';
import 'package:GoSystem/features/admin/auth/model/user_model.dart';
import 'package:GoSystem/features/pos/home/cubit/pos_home_state.dart';
import 'package:GoSystem/features/pos/home/model/pos_models.dart';
import 'package:GoSystem/features/admin/discount/model/discount_model.dart';
import 'package:GoSystem/features/admin/coupon/model/coupon_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../../../../core/utils/error_handler.dart';

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

  List<CouponModel> coupons = [
    CouponModel(
      id: 'null',
      couponCode: 'No Coupon',
      type: 'fixed',
      amount: 0.0,
      minimumAmount: 0.0,
      quantity: 0,
      available: 0,
      expiredDate: '',
      status: true,
      createdAt: '',
      updatedAt: '',
      version: 0,
    ),
  ];
  CouponModel? selectedCoupon;

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

  // ─── Role-based warehouse filtering ────────────────────────────────────────

  /// Returns the saved user from cache (to check role/warehouse assignment)
  User? get _currentUser {
    try {
      return CacheHelper.getModel<User>(
        key: 'user',
        fromJson: (json) => User.fromJson(json),
      );
    } catch (_) {
      return null;
    }
  }

  /// Returns the warehouse ID to filter by, or null if admin (no filter)
  String? get _filterWarehouseId {
    final user = _currentUser;
    if (user == null) return null;
    return user.isCashier ? (selectedWarhouse?.id ?? user.warehouseId) : null;
  }

  /// Returns product IDs registered in a specific warehouse.
  /// Used to filter the product list for cashiers.
  Future<Set<String>> _getWarehouseProductIds(String warehouseId) async {
    try {
      final rows = await _client
          .from('warehouse_products')
          .select('product_id')
          .eq('warehouse_id', warehouseId);
      return (rows as List).map((r) => r['product_id'].toString()).toSet();
    } catch (e) {
      log('_getWarehouseProductIds error: $e');
      return {};
    }
  }

  /// Filters products to only those registered in the cashier's warehouse.
  /// Admins get all products unfiltered.
  Future<List<Product>> _filterByWarehouse(List<Product> products) async {
    final warehouseId = _filterWarehouseId;
    if (warehouseId == null) return products; // admin → no filter
    final ids = await _getWarehouseProductIds(warehouseId);
    if (ids.isEmpty) return []; // cashier: don't show products not assigned to warehouse
    return products.where((p) => ids.contains(p.id)).toList();
  }

  // ─── Warehouse quantity merge ─────────────────────────────────────────────

  /// Bulk-fetches warehouse_products for the selected warehouse and merges
  /// the actual stock quantity into each product.
  Future<List<Product>> _withWarehouseQty(List<Product> products) async {
    if (selectedWarhouse == null || products.isEmpty) return products;
    try {
      final ids = products.map((p) => p.id).toList();
      final rows = await _client
          .from('warehouse_products')
          .select('product_id, quantity')
          .eq('warehouse_id', selectedWarhouse!.id)
          .inFilter('product_id', ids);

      final qtyMap = <String, int>{
        for (final r in (rows as List))
          r['product_id'].toString(): (r['quantity'] as num?)?.toInt() ?? 0,
      };
      return products
          .map((p) => p.copyWithWarehouseQuantity(qtyMap[p.id] ?? 0))
          .toList();
    } catch (e) {
      log('_withWarehouseQty error: $e');
      return products; // fallback: return as-is
    }
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

      final raw = (response as List).map((e) => Product.fromList(e)).toList();
      final filtered = await _filterByWarehouse(raw);
      featuredProducts = await _withWarehouseQty(filtered);
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

      final allBundles = (response as List).map((b) => BundleModel.fromJson(b)).toList();
      // For cashiers: show only bundles assigned to their warehouse (or allWarehouses)
      final warehouseId = _filterWarehouseId;
      if (warehouseId != null) {
        bundles = allBundles.where((b) {
          if (b.allWarehouses) return true;
          return b.warehouseIds.contains(warehouseId);
        }).toList();
      } else {
        bundles = allBundles; // admin → all bundles
      }
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
    coupons = [
      CouponModel(
        id: 'null',
        couponCode: 'No Coupon',
        type: 'fixed',
        amount: 0.0,
        minimumAmount: 0.0,
        quantity: 0,
        available: 0,
        expiredDate: '',
        status: true,
        createdAt: '',
        updatedAt: '',
        version: 0,
      ),
    ];
    selectedCoupon = null;

    try {
      final user = _currentUser;
      final warehousesResponse = await _client.from('warehouses').select();
      final allWarehouses =
          (warehousesResponse as List).map((e) => Warehouse.fromJson(e)).toList();

      if (user != null && user.isCashier) {
        // Cashier must be restricted to their assigned warehouse.
        final assignedId = user.warehouseId;
        warehouses = assignedId == null
            ? []
            : allWarehouses.where((w) => w.id == assignedId).toList();

        selectedWarhouse = warehouses.isNotEmpty ? warehouses.first : null;
      } else {
        warehouses = allWarehouses;
        selectedWarhouse = warehouses.isNotEmpty ? warehouses.first : null;
      }
    } catch (e) {
      log('Warehouses selection error: $e');
    }

    try {
      final customersResponse = await _client.from('customers').select();
      customers = (customersResponse as List).map((e) => Customer.fromJson(e)).toList();
      selectedCustomer = customers.isNotEmpty ? customers.first : null;
    } catch (e) {
      log('Customers selection error: $e');
    }

    try {
      final accountsResponse = await _client.from('bank_accounts').select().eq('status', true);
      accounts = (accountsResponse as List).map((e) => BankAccount.fromJson(e)).toList();
      selectedAccount = accounts.isNotEmpty ? accounts.first : null;
    } catch (e) {
      log('Bank accounts selection error: $e');
    }

    try {
      final taxesResponse = await _client.from('taxes').select().eq('status', true);
      final List<Tax> taxesFromJson = (taxesResponse as List).map((e) => Tax.fromJson(e)).toList();
      taxes.addAll(taxesFromJson);
      selectedTax = taxes.first;
    } catch (e) {
      log('Taxes selection error: $e');
    }

    try {
      final discountsResponse = await _client.from('discounts').select().eq('status', true);
      final List<DiscountModel> discountsFromJson = (discountsResponse as List).map((e) => DiscountModel.fromJson(e)).toList();
      discounts.addAll(discountsFromJson);
      selectedDiscount = discounts.first;
    } catch (e) {
      log('Discounts selection error: $e');
    }

    try {
      final couponsResponse = await _client
          .from('coupons')
          .select()
          .eq('status', true)
          .gte('end_date', DateTime.now().toIso8601String());
      final List<CouponModel> couponsFromJson = (couponsResponse as List).map((e) {
        final int limit = e['usage_limit'] ?? 0;
        final int count = e['usage_count'] ?? 0;
        return CouponModel(
          id: e['id'],
          couponCode: e['code'],
          type: e['discount_type'],
          amount: (e['discount_value'] as num).toDouble(),
          minimumAmount: (e['min_purchase'] as num).toDouble(),
          quantity: limit,
          available: limit - count,
          expiredDate: e['end_date'],
          status: e['is_active'] ?? true,
          createdAt: e['created_at'] ?? '',
          updatedAt: e['updated_at'] ?? '',
          version: 0,
        );
      }).where((c) => c.available > 0).toList();
      coupons.addAll(couponsFromJson);
      selectedCoupon = coupons.first;
    } catch (e) {
      log('Coupons selection error: $e');
    }

    try {
      final currenciesResponse = await _client.from('currencies').select();
      currencies = (currenciesResponse as List).map((e) => Currency.fromJson(e)).toList();
      selectedCurrency = currencies.isNotEmpty ? currencies.first : null;
    } catch (e) {
      log('Currencies selection error: $e');
    }

    try {
      final paymentMethodsResponse = await _client.from('payment_methods').select().eq('is_active', true);
      paymentMethods = (paymentMethodsResponse as List).map((e) => PaymentMethod.fromJson(e)).toList();
      
      selectedPaymentMethod = paymentMethods.isNotEmpty
          ? (paymentMethods.any((element) => element.name == 'Cash')
              ? paymentMethods.firstWhere((element) => element.name == 'Cash')
              : paymentMethods.first)
          : null;
    } catch (e) {
      log('Payment methods selection error: $e');
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

    // 1. Keep filter panel visible when "All" is selected, close only when specific category chosen
    if (categoryId != null) {
      showCategoryFilters = false;
      showBrandFilters = false;
    }

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

        final raw = (response as List).map((e) => Product.fromList(e)).toList();
        final fCat = await _filterByWarehouse(raw);
        categoryProducts = await _withWarehouseQty(fCat);
        selectedCategoryId = categoryId;
        isCategoryProductsLoading = false;
        emit(PosDataLoaded(categoryProducts));
      } catch (e) {
        final msg = _extractErrorMessage(e);
        isCategoryProductsLoading = false;
        emit(PosError(msg));
      }
    } else {
      // "All" selected — load ALL active products
      selectedCategoryId = null;
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
            .eq('status', true);

        final raw2 = (response as List).map((e) => Product.fromList(e)).toList();
        final fCat2 = await _filterByWarehouse(raw2);
        categoryProducts = await _withWarehouseQty(fCat2);
        isCategoryProductsLoading = false;
        emit(PosDataLoaded(categoryProducts));
      } catch (e) {
        final msg = _extractErrorMessage(e);
        isCategoryProductsLoading = false;
        emit(PosError(msg));
      }
    }
  }

  Future<void> getProductsByBrand(String? brandId) async {
    isBrandProductsLoading = true;

    // 1. Keep filter panel visible when "All" is selected, close only when specific brand chosen
    if (brandId != null) {
      showCategoryFilters = false;
      showBrandFilters = false;
    }

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

        final rawB = (response as List).map((e) => Product.fromList(e)).toList();
        final fBrand = await _filterByWarehouse(rawB);
        brandProducts = await _withWarehouseQty(fBrand);
        selectedBrandId = brandId;
        isBrandProductsLoading = false;
        emit(PosDataLoaded(brandProducts));
      } catch (e) {
        final msg = _extractErrorMessage(e);
        isBrandProductsLoading = false;
        emit(PosError(msg));
      }
    } else {
      // "All" selected — load ALL active products
      selectedBrandId = null;
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
            .eq('status', true);

        final rawB2 = (response as List).map((e) => Product.fromList(e)).toList();
        final fBrand2 = await _filterByWarehouse(rawB2);
        brandProducts = await _withWarehouseQty(fBrand2);
        isBrandProductsLoading = false;
        emit(PosDataLoaded(brandProducts));
      } catch (e) {
        final msg = _extractErrorMessage(e);
        isBrandProductsLoading = false;
        emit(PosError(msg));
      }
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
        final scanned = Product.fromScan(response);

        // If cashier is bound to a warehouse, the scanned product must be assigned to it.
        final warehouseId = _filterWarehouseId;
        if (warehouseId != null) {
          final ids = await _getWarehouseProductIds(warehouseId);
          if (ids.isEmpty || !ids.contains(scanned.id)) {
            emit(PosError('Product not available in this warehouse'));
            await selectTab();
            return null;
          }
        }

        final merged = await _withWarehouseQty([scanned]);
        final product = merged.first;
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
