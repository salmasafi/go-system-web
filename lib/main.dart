import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:systego/core/services/session_helper.dart';
import 'package:systego/features/POS/history/cubit/history_cubit.dart';
import 'package:systego/features/admin/adjustment/cubit/adjustment_cubit.dart';
import 'package:systego/features/admin/admins_screen/cubit/admins_cubit.dart';
import 'package:systego/features/admin/admins_screen/cubit/permissions_cubit.dart';
import 'package:systego/features/admin/auth/cubit/login_cubit.dart';
import 'package:systego/features/admin/bank_account/cubit/bank_account_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/features/admin/cashier/cubit/cashier_cubit.dart';
import 'package:systego/features/admin/coupon/cubit/coupon_cubit.dart';
import 'package:systego/features/admin/currency/cubit/currency_cubit.dart';
import 'package:systego/features/admin/department/cubit/department_cubit.dart';
import 'package:systego/features/admin/discount/cubit/discount_cubit.dart';
import 'package:systego/features/admin/expences_category/cubit/expences_categories_cubit.dart';
import 'package:systego/features/admin/payment_methods/cubit/payment_method_cubit.dart';
import 'package:systego/features/admin/permission/cubit/permission_cubit.dart';
import 'package:systego/features/admin/popup/cubit/popup_cubit.dart';
import 'package:systego/features/admin/product/cubit/get_products_cubit/product_cubit.dart';
import 'package:systego/features/admin/reason/cubit/reason_cubit.dart';
import 'package:systego/features/admin/taxes/cubit/taxes_cubit.dart';
import 'package:systego/features/admin/units/cubit/unit_cubit.dart';
import 'package:systego/features/admin/variations/cubit/variation_cubit.dart';
import 'package:systego/translations/codegen_loader.g.dart';
import 'core/services/cache_helper.dart';
import 'core/services/dio_helper.dart';
import 'features/POS/shift/cubit/pos_shift_cubit.dart';
import 'features/POS/checkout/cubit/checkout_cubit/checkout_cubit.dart';
import 'features/POS/home/cubit/pos_home_cubit.dart';
import 'features/admin/auth/presentation/view/login_screen.dart';
import 'features/admin/brands/cubit/brand_cubit.dart';
import 'features/admin/categories/cubit/categories_cubit.dart';
import 'features/admin/city/cubit/city_cubit.dart';
import 'features/admin/country/cubit/country_cubit.dart';
import 'features/admin/dashboard/cubit/notifications_cubit.dart';
import 'features/admin/dashboard/presentation/view/home_screen.dart';
import 'features/admin/product/cubit/filter_product_cubit/product_filter_cubit.dart';
import 'features/admin/product/cubit/product_details_cubit/product_details_cubit.dart';
import 'features/admin/suppliers/cubit/supplier_cubit.dart';
import 'features/admin/warehouses/cubit/warehouse_cubit.dart';
import 'features/admin/zone/cubit/zone_cubit.dart';
import 'package:systego/features/admin/revenue/cubit/revenue_cubit.dart';
import 'package:systego/features/admin/customer/cubit/customer_cubit.dart';
import 'package:systego/features/admin/roloes_and_permissions/cubit/roles_cubit.dart';
import 'package:systego/features/admin/pandel/cubit/pandel_cubit.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize CacheHelper for local storage
  await CacheHelper.init();

  // Initialize DioHelper for API calls
  DioHelper.init();

  // Check if user is logged in
  final String? token = CacheHelper.getData(key: 'token');
  final isLoggedIn = token != null && token.toString().isNotEmpty;
  log('isLoggedIn $isLoggedIn');
  log(token ?? '');

  final deviceLocale = WidgetsBinding.instance.window.locale;
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
        BlocProvider<LoginCubit>(create: (context) => LoginCubit()),
        BlocProvider<PosCubit>(
          create: (context) => PosCubit(), //..loadPosData()
        ),
        BlocProvider<PosShiftCubit>(create: (context) => PosShiftCubit()),
        BlocProvider<CheckoutCubit>(create: (context) => CheckoutCubit()),
        BlocProvider<HistoryCubit>(create: (context) => HistoryCubit()),
        BlocProvider<WareHouseCubit>(create: (context) => WareHouseCubit()),
        BlocProvider<ProductsCubit>(create: (context) => ProductsCubit()),
        BlocProvider<CategoriesCubit>(create: (context) => CategoriesCubit()),
        BlocProvider<BrandsCubit>(create: (context) => BrandsCubit()),
        BlocProvider<SupplierCubit>(create: (context) => SupplierCubit()),
        BlocProvider<CurrencyCubit>(create: (context) => CurrencyCubit()),
        BlocProvider<CountryCubit>(create: (context) => CountryCubit()),
        BlocProvider<CityCubit>(create: (context) => CityCubit()),
        BlocProvider<ZoneCubit>(create: (context) => ZoneCubit()),
        BlocProvider<TaxesCubit>(create: (context) => TaxesCubit()),
        BlocProvider<BankAccountCubit>(create: (context) => BankAccountCubit()),
        BlocProvider<PopupCubit>(create: (context) => PopupCubit()),
        BlocProvider<CouponsCubit>(create: (context) => CouponsCubit()),
        BlocProvider<DepartmentCubit>(create: (context) => DepartmentCubit()),
        BlocProvider<VariationCubit>(create: (context) => VariationCubit()),
        BlocProvider<DiscountsCubit>(create: (context) => DiscountsCubit()),
        BlocProvider<PermissionCubit>(create: (context) => PermissionCubit()),
        BlocProvider<ReasonCubit>(create: (context) => ReasonCubit()),
        BlocProvider<PandelCubit>(create: (context) => PandelCubit()),
        BlocProvider<RevenueCubit>(create: (context) => RevenueCubit()),
        BlocProvider<CustomerCubit>(create: (context) => CustomerCubit()),
        BlocProvider<RolesCubit>(create: (context) => RolesCubit()),
        BlocProvider<UnitsCubit>(create: (context) => UnitsCubit()),
        BlocProvider<AdjustmentCubit>(create: (context) => AdjustmentCubit()),
        BlocProvider<PermissionsCubit>(create: (context) => PermissionsCubit()),
        BlocProvider<CashierCubit>(create: (context) => CashierCubit()),
        BlocProvider<ExpenseCategoryCubit>(
          create: (context) => ExpenseCategoryCubit(),
        ),
        BlocProvider<AdminsCubit>(create: (context) => AdminsCubit()),
        BlocProvider<PaymentMethodCubit>(
          create: (context) => PaymentMethodCubit(),
        ),
        BlocProvider<ProductDetailsCubit>(
          create: (context) => ProductDetailsCubit(),
        ),
        BlocProvider<ProductFiltersCubit>(
          create: (context) => ProductFiltersCubit(),
        ),
        BlocProvider<NotificationsCubit>(
          create: (_) => NotificationsCubit()..getNotifications(),
        ),
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
            fillColor: MaterialStateColor.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
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
