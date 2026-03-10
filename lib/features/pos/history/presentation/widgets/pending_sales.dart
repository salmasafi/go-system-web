// lib/features/History/ui/tabs/pending_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/features/POS/history/presentation/views/pending_sale_details_screen.dart';
import '../../../../../core/widgets/custom_loading/custom_loading_state.dart';
import '../../cubit/history_cubit.dart';
import '../../cubit/history_state.dart';

class PendingTab extends StatefulWidget {
  const PendingTab({super.key});
  @override
  State<PendingTab> createState() => _PendingTabState();
}

class _PendingTabState extends State<PendingTab> {
  @override
  void initState() {
    super.initState();
    context.read<HistoryCubit>().getPendingSales();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryCubit, HistoryState>(
      buildWhen: (prev, curr) =>
          curr is PendingLoading ||
          curr is PendingLoaded ||
          curr is HistoryError,
      builder: (context, state) {
        if (state is PendingLoading) {
          return const Center(child: CustomLoadingState());
        }
        if (state is HistoryError) return Center(child: Text(state.message));
        if (state is PendingLoaded) {
          if (state.pendingSales.isEmpty) {
            return const Center(child: Text("No pending sales"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: state.pendingSales.length,
            itemBuilder: (context, index) {
              final sale = state.pendingSales[index];
              return Card(
                elevation: 2,
                color: AppColors.white,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PendingSaleDetailsScreen(saleId: sale.id),
                      ),
                    );
                  },
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.pause, color: AppColors.white),
                  ),
                  title: Text(
                    sale.reference,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(sale.customerName),
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
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.shadowGray,
                        ),
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
