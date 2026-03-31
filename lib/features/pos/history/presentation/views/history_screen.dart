import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import '../widgets/sales_tab.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      appBar: AppBar(
        title: const Text(
          "Orders",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.black),
      ),
      body: const SalesTab(),
    );
  }
}
