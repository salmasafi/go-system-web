import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/pos/customer/cubit/pos_customer_cubit.dart';
import 'customer_create_dialog.dart';
import 'customer_picker_sheet.dart';

class CustomerSelectorWidget extends StatelessWidget {
  const CustomerSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PosCustomerCubit, PosCustomerState>(
      builder: (context, state) {
        final cubit = context.read<PosCustomerCubit>();
        final selected = state is PosCustomerLoaded
            ? state.selectedCustomer
            : cubit.selectedCustomer;

        return Row(
          children: [
            // ── Selector pill ──
            Expanded(
              child: GestureDetector(
                onTap: () => showCustomerPickerSheet(context),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUI.padding(context, 12),
                    vertical: ResponsiveUI.padding(context, 10),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlueBackground,
                    borderRadius: BorderRadius.circular(
                      ResponsiveUI.borderRadius(context, 10),
                    ),
                    border: Border.all(
                      color: selected != null
                          ? AppColors.primaryBlue.withValues(alpha: 0.4)
                          : AppColors.shadowGray.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selected != null
                            ? Icons.person
                            : Icons.person_outline,
                        size: ResponsiveUI.iconSize(context, 18),
                        color: selected != null
                            ? AppColors.primaryBlue
                            : AppColors.shadowGray,
                      ),
                      SizedBox(width: ResponsiveUI.spacing(context, 8)),
                      Expanded(
                        child: selected == null
                            ? Text(
                                'Select Customer',
                                style: TextStyle(
                                  fontSize: ResponsiveUI.fontSize(context, 13),
                                  color: AppColors.shadowGray,
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    selected.name,
                                    style: TextStyle(
                                      fontSize:
                                          ResponsiveUI.fontSize(context, 13),
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.darkGray,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    selected.phoneNumber,
                                    style: TextStyle(
                                      fontSize:
                                          ResponsiveUI.fontSize(context, 11),
                                      color: AppColors.shadowGray,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: ResponsiveUI.iconSize(context, 18),
                        color: AppColors.shadowGray,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(width: ResponsiveUI.spacing(context, 8)),

            // ── "+" button ──
            SizedBox(
              width: ResponsiveUI.value(context, 38),
              height: ResponsiveUI.value(context, 38),
              child: Material(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 10),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUI.borderRadius(context, 10),
                  ),
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => BlocProvider.value(
                      value: context.read<PosCustomerCubit>(),
                      child: const CustomerCreateDialog(),
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    color: AppColors.white,
                    size: ResponsiveUI.iconSize(context, 20),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
