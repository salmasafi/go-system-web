import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/features/pos/customer/presentation/widgets/customer_selector_widget.dart';
import 'package:GoSystem/features/pos/home/cubit/pos_home_cubit.dart';
import 'package:GoSystem/features/pos/home/cubit/pos_home_state.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/responsive_ui.dart';
import 'search_bar.dart';

class POSHeaderSection extends StatelessWidget {
  final TextEditingController searchController;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool showCustomerSelector;

  const POSHeaderSection({
    required this.searchController,
    required this.onChanged,
    required this.onTap,
    this.showCustomerSelector = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PosCubit, PosState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.only(
            right: ResponsiveUI.padding(context, 16),
            left: ResponsiveUI.padding(context, 16),
            top: ResponsiveUI.padding(context, 12),
            bottom: ResponsiveUI.padding(context, 12),
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: AppColors.shadowGray.withValues(alpha: 0.06),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              if (showCustomerSelector) ...[
                const CustomerSelectorWidget(),
                SizedBox(height: ResponsiveUI.spacing(context, 8)),
              ],
              POSSearchBar(
                controller: searchController,
                onChanged: onChanged,
                onTap: onTap,
              ),
            ],
          ),
        );
      },
    );
  }
}
