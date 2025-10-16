import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:systego/core/services/session_helper.dart';
import 'package:systego/features/home/presentation/screens/brands_screen/logic/cubit/brand_cubit.dart';
import 'package:systego/features/home/presentation/screens/categories_screen/logic/cubit/categories_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/features/product/cubit/get_products_cubit/product_cubit.dart';
import 'package:systego/features/product/cubit/product_details_cubit/product_details_cubit.dart';
import 'core/services/cache_helper.dart.dart';
import 'core/services/dio_helper.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/home/presentation/screens/warehouses/cubit/warehouse_cubit.dart';

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
      print('🔁 Session expired — navigating to login');
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
        BlocProvider<ProductDetailsCubit>(
          create: (context) => ProductDetailsCubit(),
        ),
        BlocProvider<WareHouseCubit>(create: (context) => WareHouseCubit()),
        BlocProvider<CategoriesCubit>(create: (context) => CategoriesCubit()),
        BlocProvider<BrandsCubit>(create: (context) => BrandsCubit()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        theme: ThemeData(
          fontFamily: 'Rubik',
          scaffoldBackgroundColor: AppColors.lightBlueBackground,
        ),
        home: widget.isLoggedIn ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }
}
