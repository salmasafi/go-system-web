// lib/features/History/ui/tabs/sales_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/features/POS/history/presentation/views/sale_details_screen.dart';
import '../../../../../core/widgets/custom_loading/custom_loading_state.dart';
import '../../cubit/history_cubit.dart';
import '../../cubit/history_state.dart';

class SalesTab extends StatefulWidget {
  const SalesTab({super.key});
  @override
  State<SalesTab> createState() => _SalesTabState();
}

class _SalesTabState extends State<SalesTab> {
  @override
  void initState() {
    super.initState();
    context.read<HistoryCubit>().getAllSales();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryCubit, HistoryState>(
      buildWhen: (prev, curr) =>
          curr is SalesLoading || curr is SalesLoaded || curr is HistoryError,
      builder: (context, state) {
        if (state is SalesLoading) {
          return const Center(child: CustomLoadingState());
        }
        if (state is HistoryError) return Center(child: Text(state.message));
        if (state is SalesLoaded) {
          if (state.sales.isEmpty) {
            return const Center(child: Text("No completed sales"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: state.sales.length,
            itemBuilder: (context, index) {
              final sale = state.sales[index];
              return Card(
                color: AppColors.white,
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
                    backgroundColor: AppColors.successGreen,
                    child: Icon(Icons.check, color: AppColors.white),
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
                      color: AppColors.successGreen,
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
