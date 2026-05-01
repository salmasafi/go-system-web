import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state.dart';
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
          return Center(child: CustomLoadingState());
        }
        if (state is HistoryError) return Center(child: Text(state.message));
        if (state is DuesLoaded) {
          if (state.customers.isEmpty) {
            return Center(child: Text("No dues found"));
          }
          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 15)),
                color: Colors.red[50],
                width: double.infinity,
                child: Text(
                  "Total Dues: ${state.totalDueAmount.toStringAsFixed(2)} EGP",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveUI.fontSize(context, 18),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
                  itemCount: state.customers.length,
                  itemBuilder: (context, index) {
                    final customer = state.customers[index];
                    return Card(
                      elevation: ResponsiveUI.value(context, 2),
                      margin: EdgeInsets.only(bottom: ResponsiveUI.padding(context, 10)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryBlue,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          customer.customerName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(customer.phone),
                        trailing: Text(
                          "${customer.totalDue.toStringAsFixed(2)} EGP",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveUI.fontSize(context, 14),
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
        return SizedBox();
      },
    );
  }
}


