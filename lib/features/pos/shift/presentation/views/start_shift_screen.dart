import 'package:easy_localization/easy_localization.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
// lib/features/pos/shift/ui/start_shift_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state.dart';
import 'package:GoSystem/features/pos/shift/cubit/pos_shift_cubit.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';

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
          padding: EdgeInsets.all(ResponsiveUI.padding(context, 24.0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.storefront_rounded,
                size: ResponsiveUI.iconSize(context, 100),
                color: AppColors.primaryBlue,
              ),
              SizedBox(height: ResponsiveUI.value(context, 30)),
              Text(
                LocaleKeys.welcome_cashier.tr(namedArgs: {'name': cashier?.name ?? LocaleKeys.cashier.tr()}),
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 24),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ResponsiveUI.value(context, 10)),
              Text(
                LocaleKeys.ready_to_start_shift.tr(),
                style: TextStyle(color: AppColors.shadowGray, fontSize: ResponsiveUI.fontSize(context, 16)),
              ),
              SizedBox(height: ResponsiveUI.value(context, 25)),

              // Start Button
              BlocBuilder<PosShiftCubit, PosShiftState>(
                builder: (context, state) {
                  if (state is PosShiftActionLoading) {
                    return const CustomLoadingState();
                  }

                  return SizedBox(
                    width: double.infinity,
                    height: ResponsiveUI.value(context, 55),
                    child: ElevatedButton.icon(
                      onPressed: () => cubit.startShift(),
                      icon: Icon(Icons.play_circle_fill),
                      label: Text(
                        LocaleKeys.start_shift_btn.tr(),
                        style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 18)),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: ResponsiveUI.value(context, 10)),

              // Change Cashier Button
              TextButton(
                onPressed: () {
                  // إعادة تعيين الاختيار للعودة للشاشة السابقة
                  cubit.selectedCashier = null;
                  cubit.getCashiers(); // تحديث القائمة
                },
                child: Text(
                  LocaleKeys.change_cashier.tr(),
                  style: const TextStyle(color: AppColors.shadowGray),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
