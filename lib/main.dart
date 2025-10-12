import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:systego/core/constants/app_colors.dart';
//import 'features/auth/presentation/screens/login_screen.dart';
//import 'features/home/presentation/screens/home_screen.dart';
import 'features/product/presentation/screens/product_details_screen.dart';

void main() {
  runApp(DevicePreview(enabled: true, builder: (context) => const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Details',
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: AppColors.shadowGray[50],
      ),
      home: const ProductDetailsScreen(),
    );
  }
}
