import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state.dart';
import '../../cubit/orders_cubit.dart';
import '../../cubit/orders_state.dart';
import '../../model/order_model.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String saleId; // نستقبل الـ ID فقط

  const OrderDetailsScreen({super.key, required this.saleId});

  @override
  Widget build(BuildContext context) {
    // نستخدم BlocProvider جديد هنا خاص بهذه الشاشة لكي لا يؤثر على القائمة الخلفية
    // أو يمكن استخدام نفس الكيوبت اذا كنت تدير الـ States بحذر
    return BlocProvider(
      create: (context) => OrdersCubit()..getOrderDetails(saleId),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Order Details"),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            if (state is OrderDetailsLoading) {
              return const CustomLoadingState();
            } else if (state is OrderDetailsError) {
              return Center(child: Text(state.message));
            } else if (state is OrderDetailsSuccess) {
              return _buildContent(context, state.order);
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, OrderModel order) {
    return Column(
      children: [
        // Header Info
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.lightBlueBackground,
          child: Column(
            children: [
              _buildInfoRow("Reference", order.reference, isBold: true),
              _buildInfoRow("Customer", order.customerName),
              _buildInfoRow("Warehouse", order.warehouseName),
              _buildInfoRow(
                "Status",
                order.status.toUpperCase(),
                isStatus: true,
              ),
              _buildInfoRow("Date", order.date.split('T')[0]),
            ],
          ),
        ),

        const Divider(height: 1),

        // Products List
        Expanded(
          child: order.items.isEmpty
              ? const Center(child: Text("No items details available"))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: order.items.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          image: item.image != null
                              ? DecorationImage(
                                  image: NetworkImage(item.image!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: item.image == null
                            ? const Icon(Icons.image, color: Colors.grey)
                            : null,
                      ),
                      title: Text(
                        item.productName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("${item.quantity} x ${item.price} EGP"),
                      trailing: Text(
                        "${item.subtotal.toStringAsFixed(2)} EGP",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    );
                  },
                ),
        ),

        // Payment Summary
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSummaryRow("Total Paid", order.paidAmount),
              if (order.dueAmount > 0)
                _buildSummaryRow("Total Due", order.dueAmount, isDue: true),
              const Divider(),
              _buildSummaryRow("Grand Total", order.grandTotal, isTotal: true),

              const SizedBox(height: 20),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.print),
                      label: const Text("Print"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        foregroundColor: AppColors.darkGray,
                        backgroundColor: AppColors.white,
                      ),
                    ),
                  ),
                  if (order.status == 'pending' || order.dueAmount > 0) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Payment Logic Here
                        },
                        icon: const Icon(Icons.payment),
                        label: const Text("Pay Now"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isStatus = false,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold || isStatus
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
              color: isStatus
                  ? (value == 'PENDING' ? Colors.orange : Colors.green)
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double value, {
    bool isTotal = false,
    bool isDue = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDue ? Colors.red : Colors.black,
            ),
          ),
          Text(
            "${value.toStringAsFixed(2)} EGP",
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.bold,
              color: isDue
                  ? Colors.red
                  : (isTotal ? AppColors.primaryBlue : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
