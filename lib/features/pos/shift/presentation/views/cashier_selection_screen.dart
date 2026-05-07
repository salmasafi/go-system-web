import 'package:GoSystem/core/utils/responsive_ui.dart';
// lib/features/pos/shift/ui/cashier_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state.dart';
import 'package:GoSystem/features/pos/shift/cubit/pos_shift_cubit.dart';

class CashierSelectionScreen extends StatefulWidget {
  const CashierSelectionScreen({super.key});

  @override
  State<CashierSelectionScreen> createState() => _CashierSelectionScreenState();
}

class _CashierSelectionScreenState extends State<CashierSelectionScreen> {
  @override
  void initState() {
    super.initState();
    // جلب الكاشيرات عند فتح الشاشة
    context.read<PosShiftCubit>().getCashiers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      appBar: AppBar(
        title: const Text("Select Cashier Counter"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<PosShiftCubit, PosShiftState>(
        listener: (context, state) {
          if (state is PosCashierSelected) {
            // لا نحتاج للانتقال يدوياً هنا، لأن POSHomeScreen ستلاحظ التغيير وتعرض الشاشة التالية
            // ولكن يمكنك استخدام Navigator.pop() إذا كنت فتحتها كـ Route منفصل
          }
        },
        builder: (context, state) {
          final cubit = context.read<PosShiftCubit>();

          if (state is PosGetCashiersLoading) {
            return const CustomLoadingState();
          }

          if (state is PosGetCashiersError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: ResponsiveUI.iconSize(context, 60), color: AppColors.red),
                  SizedBox(height: ResponsiveUI.value(context, 10)),
                  Text(state.message),
                  TextButton(
                    onPressed: () => cubit.getCashiers(),
                    child: const Text("Retry"),
                  )
                ],
              ),
            );
          }

          if (cubit.cashiersList.isEmpty) {
            return Center(child: Text("No Cashiers Found"));
          }

          return ListView.builder(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            itemCount: cubit.cashiersList.length,
            itemBuilder: (context, index) {
              final cashier = cubit.cashiersList[index];
              final bool isBusy = cashier.cashierActive;

              return Card(
                elevation: isBusy ? 0 : 4,
                color: isBusy ? AppColors.greyLight : Colors.white,
                margin: EdgeInsets.only(bottom: ResponsiveUI.padding(context, 12)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12))),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 16), vertical: ResponsiveUI.padding(context, 8)),
                  enabled: !isBusy,
                  leading: CircleAvatar(
                    backgroundColor: isBusy ? AppColors.greyMedium : AppColors.primaryBlue,
                    child: Icon(
                      isBusy ? Icons.lock_clock : Icons.point_of_sale,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    cashier.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: isBusy ? TextDecoration.lineThrough : null,
                      color: isBusy ? AppColors.greyMedium : Colors.black,
                    ),
                  ),
                  subtitle: isBusy
                      ? const Text("Occupied", style: TextStyle(color: AppColors.red))
                      : Text(cashier.name),
                  trailing: isBusy
                      ? Icon(Icons.block, color: AppColors.red)
                      : Icon(Icons.arrow_forward_ios, size: ResponsiveUI.iconSize(context, 16), color: AppColors.primaryBlue),
                  onTap: isBusy ? null : () => cubit.selectCashier(cashier),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
