import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:systego/core/services/session_helper.dart';
import 'package:systego/features/brands/cubit/brand_cubit.dart';
import 'package:systego/features/categories/cubit/categories_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/features/city/cubit/city_cubit.dart';
import 'package:systego/features/currency/cubit/currency_cubit.dart';
import 'package:systego/features/payment_methods/cubit/payment_method_cubit.dart';
import 'package:systego/features/product/cubit/get_products_cubit/product_cubit.dart';
import 'package:systego/features/product/cubit/product_details_cubit/product_details_cubit.dart';
import 'package:systego/features/product/cubit/product_filter_cubit.dart';
import 'package:systego/features/zone/cubit/zone_cubit.dart';
import 'core/services/cache_helper.dart.dart';
import 'core/services/dio_helper.dart';
import 'features/auth/presentation/view/login_screen.dart';
import 'features/country/cubit/country_cubit.dart';
import 'features/home/cubit/notifications_cubit.dart';
import 'features/home/presentation/view/home_screen.dart';
import 'features/suppliers/cubit/supplier_cubit.dart';
import 'features/warehouses/cubit/warehouse_cubit.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize CacheHelper for local storage
  await CacheHelper.init();

  // Initialize DioHelper for API calls
  DioHelper.init();

  // Check if user is logged in
  final String? token = CacheHelper.getData(key: 'token');
  final isLoggedIn = token != null && token.toString().isNotEmpty;
  log('isLoggedIn $isLoggedIn');
  log(token ?? '');

  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => MainApp(isLoggedIn: isLoggedIn),
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
        BlocProvider<WareHouseCubit>(create: (context) => WareHouseCubit()),
        BlocProvider<ProductsCubit>(create: (context) => ProductsCubit()),
        BlocProvider<CategoriesCubit>(create: (context) => CategoriesCubit()),
        BlocProvider<BrandsCubit>(create: (context) => BrandsCubit()),
        BlocProvider<SupplierCubit>(create: (context) => SupplierCubit()),
        BlocProvider<CurrencyCubit>(create: (context) => CurrencyCubit()),
        BlocProvider<CountryCubit>(create: (context) => CountryCubit()),
        BlocProvider<CityCubit>(create: (context) => CityCubit()),
        BlocProvider<ZoneCubit>(create: (context) => ZoneCubit()),
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
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        theme: ThemeData(
          fontFamily: 'Rubik',
          scaffoldBackgroundColor: AppColors.lightBlueBackground,
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
