import 'dart:developer';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:systego/core/config/app_config.dart';
import 'package:systego/core/services/session_helper.dart';
import 'package:systego/core/supabase/supabase_client.dart';
import 'package:systego/features/pos/history/cubit/history_cubit.dart';
import 'package:systego/features/admin/adjustment/cubit/adjustment_cubit.dart';
import 'package:systego/features/admin/admins_screen/cubit/admins_cubit.dart';
import 'package:systego/features/admin/auth/cubit/login_cubit.dart';
import 'package:systego/features/admin/auth/data/repositories/auth_repository.dart';
import 'package:systego/features/admin/bank_account/cubit/bank_account_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/features/admin/cashier/cubit/cashier_cubit.dart';
import 'package:systego/features/admin/coupon/cubit/coupon_cubit.dart';
import 'package:systego/features/admin/currency/cubit/currency_cubit.dart';
import 'package:systego/features/admin/redeem_points/cubit/redeem_points_cubit.dart';
import 'package:systego/features/admin/redeem_points/data/repositories/redeem_points_repository.dart';
import 'package:systego/features/admin/department/cubit/department_cubit.dart';
import 'package:systego/features/admin/expense_admin/cubit/expense_admin_cubit.dart';
import 'package:systego/features/admin/expences/data/repositories/expense_repository.dart';
import 'package:systego/features/admin/discount/cubit/discount_cubit.dart';
import 'package:systego/features/admin/expences_category/cubit/expences_categories_cubit.dart';
import 'package:systego/features/admin/expences_category/data/repositories/expense_category_repository.dart';
import 'package:systego/features/admin/payment_methods/cubit/payment_method_cubit.dart';
import 'package:systego/features/admin/payment_methods/data/repositories/payment_method_repository.dart';
import 'package:systego/features/admin/permission/cubit/permission_cubit.dart';
import 'package:systego/features/admin/popup/cubit/popup_cubit.dart';
import 'package:systego/features/admin/popup/data/repositories/popup_repository.dart';
import 'package:systego/features/admin/product/cubit/get_products_cubit/product_cubit.dart';
import 'package:systego/features/admin/purchase_returns/cubit/purchase_return_cubit.dart';
import 'package:systego/features/admin/purchase_returns/data/repositories/purchase_return_repository.dart';
import 'package:systego/features/admin/purchase/cubit/purchase_cubit.dart';
import 'package:systego/features/admin/reason/cubit/reason_cubit.dart';
import 'package:systego/features/admin/print_labels/cubit/label_cubit.dart';
import 'package:systego/features/admin/print_labels/data/repositories/label_repository.dart';
import 'package:systego/features/admin/taxes/cubit/taxes_cubit.dart';
import 'package:systego/features/admin/transfer/cubit/transfers_cubit.dart';
import 'package:systego/features/admin/transfer/data/repositories/transfer_repository.dart';
import 'package:systego/features/admin/points/cubit/points_cubit.dart';
import 'package:systego/features/admin/points/data/repositories/points_repository.dart';
import 'package:systego/features/admin/units/cubit/units_cubit.dart';
import 'package:systego/features/admin/variations/cubit/variation_cubit.dart';
import 'package:systego/translations/codegen_loader.g.dart';
import 'package:systego/core/services/cache_helper.dart';
import 'package:systego/core/services/dio_helper.dart';
import 'package:systego/features/pos/return/cubit/return_cubit.dart';
import 'package:systego/features/pos/shift/cubit/pos_shift_cubit.dart';
import 'package:systego/features/pos/checkout/cubit/checkout_cubit/checkout_cubit.dart';
import 'package:systego/features/pos/home/cubit/pos_home_cubit.dart';
import 'package:systego/features/pos/customer/cubit/pos_customer_cubit.dart';
import 'package:systego/features/admin/auth/presentation/view/login_screen.dart';
import 'package:systego/features/admin/brands/cubit/brand_cubit.dart';
import 'package:systego/features/admin/categories/cubit/categories_cubit.dart';
import 'package:systego/features/admin/city/cubit/city_cubit.dart';
import 'package:systego/features/admin/country/cubit/country_cubit.dart';
import 'package:systego/features/admin/dashboard/cubit/notifications_cubit.dart';
import 'package:systego/features/admin/dashboard/presentation/view/home_screen.dart';
import 'package:systego/features/admin/product/cubit/filter_product_cubit/product_filter_cubit.dart';
import 'package:systego/features/admin/product/cubit/product_details_cubit/product_details_cubit.dart';
import 'package:systego/features/admin/suppliers/cubit/supplier_cubit.dart';
import 'package:systego/features/admin/warehouses/cubit/warehouse_cubit.dart';
import 'package:systego/features/admin/warehouses/data/repositories/warehouse_repository.dart';
import 'package:systego/features/admin/zone/cubit/zone_cubit.dart';

// Repository Imports
import 'package:systego/features/admin/taxes/data/repositories/tax_repository.dart';
import 'package:systego/features/admin/coupon/data/repositories/coupon_repository.dart';
import 'package:systego/features/admin/variations/data/repositories/variation_repository.dart';
import 'package:systego/features/admin/discount/data/repositories/discount_repository.dart';
import 'package:systego/features/admin/pandel/data/repositories/bundle_repository.dart';
import 'package:systego/features/admin/transfer/data/repositories/transfer_repository.dart';
import 'package:systego/features/admin/adjustment/data/repositories/adjustment_repository.dart';
import 'package:systego/features/admin/revenue/data/repositories/revenue_repository.dart';
import 'package:systego/features/admin/revenue/cubit/revenue_cubit.dart';
import 'package:systego/features/admin/customer/cubit/customer_cubit.dart';
import 'package:systego/features/admin/roloes_and_permissions/cubit/roles_cubit.dart';
import 'package:systego/features/admin/pandel/cubit/pandel_cubit.dart';

import 'package:systego/features/admin/product/data/repositories/product_repository.dart';
import 'package:systego/features/admin/categories/data/repositories/category_repository.dart';
import 'package:systego/features/admin/city/data/repositories/city_repository.dart';
import 'package:systego/features/admin/zone/data/repositories/zone_repository.dart';
import 'package:systego/features/admin/brands/data/repositories/brand_repository.dart';
import 'package:systego/features/admin/bank_account/data/repositories/bank_account_repository.dart';
import 'package:systego/features/admin/purchase/data/repositories/purchase_repository.dart';

import 'package:systego/features/admin/suppliers/data/repositories/supplier_repository.dart';
import 'package:systego/features/admin/customer/data/repositories/customer_repository.dart';
import 'package:systego/features/admin/units/data/repositories/unit_repository.dart';
import 'package:systego/features/admin/department/data/repositories/department_repository.dart';
import 'package:systego/features/admin/roloes_and_permissions/data/repositories/role_repository.dart';
import 'package:systego/features/admin/reason/data/repositories/reason_repository.dart';
import 'package:systego/features/admin/permission/data/repositories/permission_repository.dart';
import 'package:systego/features/admin/cashier/data/repositories/cashier_repository.dart';
import 'package:systego/features/admin/currency/data/repositories/currency_repository.dart';
import 'package:systego/features/admin/country/data/repositories/country_repository.dart';
import 'package:systego/features/admin/admins_screen/data/repositories/admin_repository.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AppConfig (loads .env files)
  await AppConfig.initialize();

  // Initialize Supabase
  await SupabaseClientWrapper.initialize();

  await EasyLocalization.ensureInitialized();

  // Initialize CacheHelper for local storage
  await CacheHelper.init();

  // Initialize DioHelper for API calls (legacy, will be phased out)
  DioHelper.init();

  // Check if user is logged in (support both Dio and Supabase)
  final String? token = CacheHelper.getData(key: 'token');
  final bool hasDioToken = token != null && token.toString().isNotEmpty;
  final bool hasSupabaseSession = SupabaseClientWrapper.isAuthenticated;
  final isLoggedIn = hasDioToken || hasSupabaseSession;
  log(
    'isLoggedIn $isLoggedIn (Dio: $hasDioToken, Supabase: $hasSupabaseSession)',
  );
  if (hasDioToken)
    log(
      'Dio token: ${token.substring(0, token.length > 20 ? 20 : token.length)}...',
    );

  final deviceLocale = PlatformDispatcher.instance.locale;
  final startLocale = deviceLocale.languageCode == 'ar'
      ? Locale('ar')
      : Locale('en');

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      assetLoader: CodegenLoader(),
      saveLocale: true,
      startLocale: startLocale,
      child: MainApp(isLoggedIn: isLoggedIn),

      // DevicePreview(
      //   enabled: true,
      //   builder: (context) => MainApp(isLoggedIn: isLoggedIn),
      // ),
    ),
  );
}

class MainApp extends StatefulWidget {
  final bool isLoggedIn;
  const MainApp({super.key, required this.isLoggedIn});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    SessionManager.onSessionExpired.listen((_) {
      log('🔁 Session expired — navigating to login');
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LabelCubit>(
          create: (context) => LabelCubit(LabelRepository()),
        ),
        BlocProvider<PointsCubit>(
          create: (context) => PointsCubit(PointsRepository()),
        ),
        BlocProvider<ExpenseAdminCubit>(
          create: (context) => ExpenseAdminCubit(ExpenseRepository()),
        ),
        BlocProvider<LoginCubit>(
          create: (context) => LoginCubit(AuthRepository()),
        ),
        BlocProvider<PosCubit>(
          create: (context) => PosCubit(), //..loadPosData()
        ),
        BlocProvider<PosShiftCubit>(create: (context) => PosShiftCubit()),
        BlocProvider<RedeemPointsCubit>(
          create: (context) => RedeemPointsCubit(RedeemPointsRepository()),
        ),
        BlocProvider<CheckoutCubit>(create: (context) => CheckoutCubit()),
        BlocProvider<PosCustomerCubit>(create: (context) => PosCustomerCubit()),
        BlocProvider<PurchaseReturnCubit>(
          create: (context) => PurchaseReturnCubit(PurchaseReturnRepository()),
        ),
        BlocProvider<ReturnCubit>(create: (context) => ReturnCubit()),
        BlocProvider<HistoryCubit>(create: (context) => HistoryCubit()),
        BlocProvider<WareHouseCubit>(
          create: (context) => WareHouseCubit(WarehouseRepository())..getWarehouses(),
        ),
        BlocProvider<ProductsCubit>(
          create: (context) => ProductsCubit(ProductRepository()),
        ),
        BlocProvider<CategoriesCubit>(
          create: (context) => CategoriesCubit(CategoryRepository()),
        ),
        BlocProvider<BrandsCubit>(
          create: (context) => BrandsCubit(BrandRepository()),
        ),
        BlocProvider<SupplierCubit>(
          create: (context) => SupplierCubit(SupplierRepository()),
        ),
        BlocProvider<CurrencyCubit>(create: (context) => CurrencyCubit(CurrencyRepository())),
        BlocProvider<CountryCubit>(create: (context) => CountryCubit(CountryRepository())),
        BlocProvider<UnitsCubit>(
          create: (context) => UnitsCubit(UnitRepository()),
        ),
        BlocProvider<CityCubit>(create: (context) => CityCubit(CityRepository())),
        BlocProvider<ZoneCubit>(create: (context) => ZoneCubit(ZoneRepository())),
        BlocProvider<TaxesCubit>(
          create: (context) => TaxesCubit(TaxRepository()),
        ),
        BlocProvider<BankAccountCubit>(
          create: (context) => BankAccountCubit(BankAccountRepository()),
        ),
        BlocProvider<PopupCubit>(
          create: (context) => PopupCubit(PopupRepository()),
        ),
        BlocProvider<CouponsCubit>(
          create: (context) => CouponsCubit(CouponRepository()),
        ),
        BlocProvider<DepartmentCubit>(
          create: (context) => DepartmentCubit(DepartmentRepository()),
        ),
        BlocProvider<VariationCubit>(
          create: (context) => VariationCubit(VariationRepository()),
        ),
        BlocProvider<TransfersCubit>(
          create: (context) => TransfersCubit(TransferRepository()),
        ),
        BlocProvider<DiscountsCubit>(
          create: (context) => DiscountsCubit(DiscountRepository()),
        ),
        BlocProvider<PermissionCubit>(
          create: (context) => PermissionCubit(PermissionRepository()),
        ),
        BlocProvider<ReasonCubit>(
          create: (context) => ReasonCubit(ReasonRepository()),
        ),
        BlocProvider<RevenueCubit>(
          create: (context) => RevenueCubit(RevenueRepository()),
        ),
        BlocProvider<CustomerCubit>(
          create: (context) => CustomerCubit(CustomerRepository()),
        ),
        BlocProvider<RolesCubit>(
          create: (context) => RolesCubit(RoleRepository()),
        ),
        BlocProvider<AdjustmentCubit>(
          create: (context) => AdjustmentCubit(AdjustmentRepository()),
        ),
        BlocProvider<CashierCubit>(
          create: (context) => CashierCubit(CashierRepository()),
        ),
        BlocProvider<PurchaseCubit>(
          create: (context) => PurchaseCubit(PurchaseRepository()),
        ),
        BlocProvider<PandelCubit>(
          create: (context) => PandelCubit(BundleRepository()),
        ),
        BlocProvider<TransfersCubit>(
          create: (context) => TransfersCubit(TransferRepository()),
        ),
        BlocProvider<ExpenseCategoryCubit>(
          create: (context) => ExpenseCategoryCubit(ExpenseCategoryRepository()),
        ),
        BlocProvider<AdminsCubit>(
          create: (context) => AdminsCubit(AdminRepository()),
        ),
        BlocProvider<PaymentMethodCubit>(
          create: (context) => PaymentMethodCubit(PaymentMethodRepository()),
        ),
        BlocProvider<ProductDetailsCubit>(
          create: (context) => ProductDetailsCubit(ProductRepository()),
        ),
        BlocProvider<ProductFiltersCubit>(
          create: (context) => ProductFiltersCubit(ProductRepository()),
        ),
        BlocProvider<NotificationsCubit>(create: (_) => NotificationsCubit()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        // locale: DevicePreview.locale(context),
        // builder: DevicePreview.appBuilder,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: ThemeData(
          fontFamily: 'Rubik',
          scaffoldBackgroundColor: AppColors.lightBlueBackground,
          primarySwatch: AppColors.mediumBlue700,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              foregroundColor: WidgetStatePropertyAll(AppColors.black),
              backgroundColor: WidgetStatePropertyAll(
                AppColors.mediumBlue700.shade200,
              ),
            ),
          ),
          checkboxTheme: CheckboxThemeData(
            fillColor: WidgetStateColor.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors
                    .mediumBlue700; // the color when checkbox is selected;
              }
              return AppColors.white; //the color when checkbox is unselected;
            }),
          ),
          dropdownMenuTheme: DropdownMenuThemeData(menuStyle: MenuStyle()),
          dialogTheme: DialogThemeData(backgroundColor: AppColors.white),
          textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
              foregroundColor: WidgetStatePropertyAll(AppColors.mediumBlue700),
              textStyle: WidgetStateProperty.all<TextStyle>(
                const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGray,
                ),
              ),
            ),
          ),

          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: AppColors.primaryBlue, // 🔵 لون المؤشر
            selectionColor: AppColors.primaryBlue, // لون التحديد (عند السحب)
            selectionHandleColor:
                AppColors.primaryBlue, // لون الدائرة الصغيرة في نهاية التحديد
          ),
        ),
        home: widget.isLoggedIn ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }
}
