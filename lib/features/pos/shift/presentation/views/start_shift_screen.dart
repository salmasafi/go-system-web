// lib/features/pos/shift/ui/start_shift_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state.dart';
import 'package:systego/features/POS/shift/cubit/pos_shift_cubit.dart';

class StartShiftScreen extends StatelessWidget {
  const StartShiftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PosShiftCubit>();
    final cashier = cubit.selectedCashier;

    return Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.storefront_rounded,
                size: 100,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(height: 30),
              Text(
                "Welcome, ${cashier?.name ?? 'User'}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "You are ready to start your shift.",
                style: TextStyle(color: AppColors.shadowGray, fontSize: 16),
              ),
              const SizedBox(height: 25),

              // Start Button
              BlocBuilder<PosShiftCubit, PosShiftState>(
                builder: (context, state) {
                  if (state is PosShiftActionLoading) {
                    return const CustomLoadingState();
                  }

                  return SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () => cubit.startShift(),
                      icon: const Icon(Icons.play_circle_fill),
                      label: const Text(
                        "START SHIFT",
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              // Change Cashier Button
              TextButton(
                onPressed: () {
                  // إعادة تعيين الاختيار للعودة للشاشة السابقة
                  cubit.selectedCashier = null;
                  cubit.getCashiers(); // تحديث القائمة
                },
                child: const Text(
                  "Change Cashier",
                  style: TextStyle(color: AppColors.shadowGray),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
