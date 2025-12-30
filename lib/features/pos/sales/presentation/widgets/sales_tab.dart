// lib/features/orders/ui/tabs/sales_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:systego/features/POS/sales/presentation/views/sales_details_screen.dart';
import '../../cubit/sales_cubit.dart';
import '../../cubit/sales_state.dart';

class SalesTab extends StatefulWidget {
  const SalesTab({super.key});
  @override
  State<SalesTab> createState() => _SalesTabState();
}

class _SalesTabState extends State<SalesTab> {
  @override
  void initState() {
    super.initState();
    context.read<OrdersCubit>().getAllSales();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      buildWhen: (prev, curr) =>
          curr is SalesLoading || curr is SalesLoaded || curr is OrdersError,
      builder: (context, state) {
        if (state is SalesLoading)
          return const Center(child: CircularProgressIndicator());
        if (state is OrdersError) return Center(child: Text(state.message));
        if (state is SalesLoaded) {
          if (state.sales.isEmpty)
            return const Center(child: Text("No completed sales"));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: state.sales.length,
            itemBuilder: (context, index) {
              final sale = state.sales[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SaleDetailsScreen(saleId: sale.id),
                      ),
                    );
                  },
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.check, color: Colors.white),
                  ),
                  title: Text(
                    sale.reference,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${sale.customerName}\n${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(sale.date))}",
                  ),
                  trailing: Text(
                    "${sale.grandTotal} EGP",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }
}
