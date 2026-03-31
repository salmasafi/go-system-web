import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/POS/home/cubit/pos_home_cubit.dart';
import 'package:systego/features/POS/home/cubit/pos_home_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:systego/generated/locale_keys.g.dart';


class POSTabBar extends StatelessWidget {
  const POSTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PosCubit, PosState>(
      builder: (context, state) {
        final cubit = context.read<PosCubit>(); // Safe here inside BlocBuilder
        final selectedTab = cubit.selectedTab;

        return Container(
          padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
          color: AppColors.white,
          child: Row(
            children: [
              Expanded(
                child: _TabItem(
                  label: 'Featured',
                  value: 'featured',
                  isSelected: selectedTab == 'featured',
                  onTap: () => cubit.selectTab(tab: 'featured'),
                ),
              ),
              SizedBox(width: ResponsiveUI.value(context, 8)),
              Expanded(
                child: _TabItem(
                  label: LocaleKeys.category.tr(),
                  value: 'category',
                  isSelected: selectedTab == 'category',
                  onTap: () => cubit.selectTab(tab: 'category'),
                ),
              ),
              SizedBox(width: ResponsiveUI.value(context, 8)),
              Expanded(
                child: _TabItem(
                  label: LocaleKeys.brand.tr(),
                  value: 'brand',
                  isSelected: selectedTab == 'brand',
                  onTap: () => cubit.selectTab(tab: 'brand'),
                ),
              ),
              SizedBox(width: ResponsiveUI.value(context, 8)),
              Expanded(
                child: _TabItem(
                  label: LocaleKeys.bundles_title.tr(),
                  value: 'bundles',
                  isSelected: selectedTab == 'bundles',
                  onTap: () => cubit.selectTab(tab: 'bundles'),
                ),
              ),

            ],
          ),
        );
      },
    );
  }
}

// Private reusable tab item
class _TabItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 12)),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(colors: [AppColors.primaryBlue, AppColors.mediumBlue700])
              : null,
          color: isSelected ? null : AppColors.lightBlueBackground,
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.white : AppColors.darkGray,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: ResponsiveUI.fontSize(context, 14),
            ),
          ),
        ),
      ),
    );
  }
}


