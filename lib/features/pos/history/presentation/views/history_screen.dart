// lib/features/orders/ui/orders_screen.dart

import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import '../widgets/dues_tab.dart';
import '../widgets/pending_sales.dart';
import '../widgets/sales_tab.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // نوفر الكيوبت للصفحة كاملة
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.lightBlueBackground,
        appBar: AppBar(
          title: const Text(
            "History",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          backgroundColor: AppColors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.black),
          bottom: const TabBar(
            labelColor: AppColors.primaryBlue,
            unselectedLabelColor: AppColors.shadowGray,
            indicatorColor: AppColors.primaryBlue,
            tabs: [
              Tab(text: "Sales"),
              Tab(text: "Pending"),
              Tab(text: "Dues"),
            ],
          ),
        ),
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            SalesTab(), // 1. المبيعات المكتملة
            PendingTab(), // 2. البيعات المعلقة
            DuesTab(), // 3. المستحقات والديون
          ],
        ),
      ),
    );
  }
}
