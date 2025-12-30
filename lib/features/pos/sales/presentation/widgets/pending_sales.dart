// lib/features/orders/ui/tabs/pending_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/sales_cubit.dart';
import '../../cubit/sales_state.dart';

class PendingTab extends StatefulWidget {
  const PendingTab({super.key});
  @override
  State<PendingTab> createState() => _PendingTabState();
}

class _PendingTabState extends State<PendingTab> {
  @override
  void initState() {
    super.initState();
    context.read<OrdersCubit>().getPendingSales();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      buildWhen: (prev, curr) =>
          curr is PendingLoading ||
          curr is PendingLoaded ||
          curr is OrdersError,
      builder: (context, state) {
        if (state is PendingLoading)
          return const Center(child: CircularProgressIndicator());
        if (state is OrdersError) return Center(child: Text(state.message));
        if (state is PendingLoaded) {
          if (state.pendingSales.isEmpty)
            return const Center(child: Text("No pending sales"));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: state.pendingSales.length,
            itemBuilder: (context, index) {
              final sale = state.pendingSales[index];
              return Card(
                elevation: 2,
                color: Colors.orange[50], // تمييز لون المعلق
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  onTap: () {},
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.pause, color: Colors.white),
                  ),
                  title: Text(
                    sale.reference,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${sale.customerName} • ${sale.totalItems} Items",
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${sale.grandTotal} EGP",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        "Tap to resume",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
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
