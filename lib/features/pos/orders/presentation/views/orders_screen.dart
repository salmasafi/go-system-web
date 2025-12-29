// lib/features/orders/ui/orders_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state.dart';
import '../../cubit/orders_cubit.dart';
import '../../cubit/orders_state.dart';
import '../../model/order_model.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrdersCubit()..getOrders(type: 'all'),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: AppColors.lightBlueBackground,
          appBar: AppBar(
            title: const Text(
              "Sales History",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            bottom: const TabBar(
              labelColor: AppColors.primaryBlue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primaryBlue,
              tabs: [
                Tab(text: "All Sales"),
                Tab(text: "Pending"),
                Tab(text: "Dues"),
              ],
            ),
          ),
          body: const TabBarView(
            physics:
                NeverScrollableScrollPhysics(), // لمنع السحب العرضي وتعارض التحديث
            children: [
              OrdersList(type: 'all'),
              OrdersList(type: 'pending'),
              OrdersList(type: 'dues'),
            ],
          ),
        ),
      ),
    );
  }
}

// ... imports

class OrdersList extends StatefulWidget {
  final String type;
  const OrdersList({super.key, required this.type});

  @override
  State<OrdersList> createState() => _OrdersListState();
}

class _OrdersListState extends State<OrdersList> {
  @override
  void initState() {
    super.initState();
    // جلب القائمة
    context.read<OrdersCubit>().getOrders(type: widget.type);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      buildWhen: (previous, current) {
        // تحديث فقط إذا كانت الحالة تخص القوائم
        return current is OrdersLoading ||
            current is OrdersLoaded ||
            current is OrdersError;
      },
      builder: (context, state) {
        if (state is OrdersLoading) {
          return const CustomLoadingState();
        } else if (state is OrdersError) {
          return Center(child: Text(state.message));
        } else if (state is OrdersLoaded) {
          if (state.type != widget.type) return const CustomLoadingState();

          if (state.orders.isEmpty) {
            return const Center(child: Text("No sales found"));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<OrdersCubit>().getOrders(type: widget.type);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                return _buildOrderCard(context, state.orders[index]);
              },
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel summaryOrder) {
    // ... تصميم الكرت كما هو في الكود السابق ...
    // عند الضغط:
    return Card(
      // ... خصائص الكرت
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              // نمرر الـ summaryOrder لغرض العرض الأولي (اختياري) أو الـ ID فقط
              builder: (_) => OrderDetailsScreen(saleId: summaryOrder.id),
            ),
          );
        },
        // ... محتوى الكرت
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // ... نفس محتوى عرض الكرت السابق (Reference, Total, Status, Customer)
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    summaryOrder.reference,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    summaryOrder.status.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(summaryOrder.customerName),
                  Text(
                    "${summaryOrder.grandTotal} EGP",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
