// ── Header (search + chips) ───────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/features/POS/home/cubit/pos_home_cubit.dart';
import 'package:systego/features/POS/home/cubit/pos_home_state.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/responsive_ui.dart';
import 'search_bar.dart';

class POSHeaderSection extends StatefulWidget {
  final TextEditingController searchController;
  final void Function(String)? onChanged;
  final void Function()? onTap;

  const POSHeaderSection({
    required this.searchController,
    required this.onChanged,
    required this.onTap,
    super.key,
  });

  @override
  State<POSHeaderSection> createState() => _POSHeaderSectionState();
}

class _POSHeaderSectionState extends State<POSHeaderSection> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PosCubit, PosState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.only(
            right: ResponsiveUI.padding(context, 16),
            left: ResponsiveUI.padding(context, 16),
            top: ResponsiveUI.padding(context, 16),
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowGray.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              POSSearchBar(
                controller: widget.searchController,
                onChanged: widget.onChanged,
                onTap: widget.onTap,
              ),
              //SizedBox(height: ResponsiveUI.spacing(context, 12)),
              // Row(
              //   children: [
              //     Expanded(
              //       child: InkWell(
              //         onTap: () {
              //           _showWarhouseDialog();
              //         },
              //         child: POSInfoChip(
              //           icon: Icons.warehouse_outlined,
              //           label: 'Warehouse',
              //           value: cubit.selectedWarhouse?.name ?? '',
              //           color: AppColors.primaryBlue,
              //         ),
              //       ),
              //     ),
              //     SizedBox(width: ResponsiveUI.spacing(context, 8)),
              //     Expanded(
              //       child: InkWell(
              //         onTap: () {
              //           _showCustomerDialog();
              //         },
              //         child: POSInfoChip(
              //           icon: Icons.person_outline,
              //           label: 'Customer',
              //           value: cubit.selectedCustomer?.name ?? '',
              //           color: AppColors.successGreen,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // // داخل الـ Row في POSHeaderSection
              // Row(
              //   children: [
              //     Expanded(
              //       child: InkWell(
              //         onTap: () => _showWarhouseDialog(),
              //         child: POSInfoChip(
              //           icon: Icons.warehouse_outlined,
              //           label: 'Warehouse',
              //           value: cubit.selectedWarhouse?.name ?? 'Select',
              //           color: AppColors.primaryBlue,
              //         ),
              //       ),
              //     ),
              //     SizedBox(width: ResponsiveUI.spacing(context, 8)),
              //     Expanded(
              //       child: InkWell(
              //         onTap: () => _showCustomerDialog(),
              //         child: POSInfoChip(
              //           icon: Icons.person_outline,
              //           label: 'Customer',
              //           value: cubit.selectedCustomer?.name ?? 'Walk-in',
              //           color: AppColors.successGreen,
              //         ),
              //       ),
              //     ),
              //     SizedBox(width: ResponsiveUI.spacing(context, 8)),
              //     Expanded(
              //       child: InkWell(
              //         onTap: () => _showBankAccountDialog(),
              //         child: POSInfoChip(
              //           icon: Icons.account_balance_wallet_outlined,
              //           label: 'Bank Account',
              //           value: cubit.selectedAccount?.name ?? 'Default Account',
              //           color: AppColors.categoryPurple,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
           
            ],
          ),
        );
      },
    );
  }

  // void _showBankAccountDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (_) => POSBankAccountDialog(), // هنعملها دلوقتي
  //   );
  // }

  // void _showWarhouseDialog() {
  //   showDialog(context: context, builder: (_) => POSWarhouseDialog());
  // }

  // void _showCustomerDialog() {
  //   showDialog(context: context, builder: (_) => POSCustomerDialog());
  // }
}
