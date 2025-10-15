import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:systego/features/home/presentation/screens/brands_screen/logic/cubit/brand_cubit.dart';
import 'package:systego/features/home/presentation/screens/categories_screen/logic/cubit/categories_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/features/product/cubit/product_cubit.dart';
import 'core/services/cache_helper.dart.dart';
import 'core/services/dio_helper.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/home/presentation/screens/warehouses/cubit/warehouse_cubit.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize DioHelper for API calls
  DioHelper.init();

  // Initialize CacheHelper for local storage
  await CacheHelper.init();

  // Check if user is logged in
  final token = CacheHelper.getData(key: 'token');
  final isLoggedIn = token != null && token.toString().isNotEmpty;

  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => MainApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn;

  const MainApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WareHouseCubit>(create: (context) => WareHouseCubit()),
        BlocProvider<ProductsCubit>(create: (context) => ProductsCubit()),
        BlocProvider<WareHouseCubit>(
          create: (context) => WareHouseCubit(),
        ),BlocProvider<CategoriesCubit>(
          create: (context) => CategoriesCubit(),
        ),BlocProvider<BrandsCubit>(
          create: (context) => BrandsCubit(),
        ),
      ],
      child: MaterialApp(
        title: 'Product Details',
        debugShowCheckedModeBanner: false,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.lightBlueBackground,
        ),
        home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }
}
