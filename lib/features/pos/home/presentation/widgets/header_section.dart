// ── Header (search + chips) ───────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/responsive_ui.dart';
import 'info_chip.dart';
import 'search_bar.dart';

class POSHeaderSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
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
            controller: searchController,
            onChanged: onChanged,
            onTap: onTap,
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          Row(
            children: [
              Expanded(
                child: POSInfoChip(
                  icon: Icons.warehouse_outlined,
                  label: 'Warehouse',
                  value: 'Shop 1',
                  color: AppColors.primaryBlue,
                ),
              ),
              SizedBox(width: ResponsiveUI.spacing(context, 8)),
              Expanded(
                child: POSInfoChip(
                  icon: Icons.person_outline,
                  label: 'Customer',
                  value: 'Walk in',
                  color: AppColors.successGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
