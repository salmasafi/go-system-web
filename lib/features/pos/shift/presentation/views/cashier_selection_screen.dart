// lib/features/pos/shift/ui/cashier_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state.dart';
import 'package:systego/features/POS/shift/cubit/pos_shift_cubit.dart';

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
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 10),
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
            return const Center(child: Text("No Cashiers Found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cubit.cashiersList.length,
            itemBuilder: (context, index) {
              final cashier = cubit.cashiersList[index];
              final bool isBusy = cashier.cashierActive;

              return Card(
                elevation: isBusy ? 0 : 4,
                color: isBusy ? Colors.grey.shade200 : Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  enabled: !isBusy,
                  leading: CircleAvatar(
                    backgroundColor: isBusy ? Colors.grey : AppColors.primaryBlue,
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
                      color: isBusy ? Colors.grey : Colors.black,
                    ),
                  ),
                  subtitle: isBusy
                      ? const Text("Occupied", style: TextStyle(color: Colors.red))
                      : Text(cashier.arName),
                  trailing: isBusy
                      ? const Icon(Icons.block, color: Colors.red)
                      : const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primaryBlue),
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