// lib/features/History/ui/tabs/dues_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../cubit/history_cubit.dart';
import '../../cubit/history_state.dart';

class DuesTab extends StatefulWidget {
  const DuesTab({super.key});
  @override
  State<DuesTab> createState() => _DuesTabState();
}

class _DuesTabState extends State<DuesTab> {
  @override
  void initState() {
    super.initState();
    context.read<HistoryCubit>().getAllDues();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryCubit, HistoryState>(
      buildWhen: (prev, curr) =>
          curr is DuesLoading || curr is DuesLoaded || curr is HistoryError,
      builder: (context, state) {
        if (state is DuesLoading) {
          return const Center(child: CustomLoadingState());
        }
        if (state is HistoryError) return Center(child: Text(state.message));
        if (state is DuesLoaded) {
          if (state.dueSales.isEmpty) {
            return const Center(child: Text("No dues found"));
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                color: Colors.red[50],
                width: double.infinity,
                child: Text(
                  "Total Dues: ${state.totalDueAmount.toStringAsFixed(2)} EGP",
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.dueSales.length,
                  itemBuilder: (context, index) {
                    final due = state.dueSales[index];
                    return Card(
                      color: AppColors.white,
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.red,
                          child: Icon(Icons.money_off, color: Colors.white),
                        ),
                        title: Text(
                          due.customerName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Ref: ${due.reference}\nPhone: ${due.phone}",
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${due.remainingAmount} EGP",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                            Text(
                              "of ${due.grandTotal}",
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }
}
