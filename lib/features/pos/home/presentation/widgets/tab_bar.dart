import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/features/pos/home/cubit/pos_home_cubit.dart';
import 'package:GoSystem/features/pos/home/cubit/pos_home_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';

class POSTabBar extends StatelessWidget {
  const POSTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PosCubit, PosState>(
      builder: (context, state) {
        final cubit = context.read<PosCubit>();
        final selectedTab = cubit.selectedTab;

        return Container(
          color: AppColors.white,
          child: Row(
            children: [
              _Tab(
                label: 'Featured',
                icon: Icons.star_rounded,
                isSelected: selectedTab == 'featured',
                onTap: () => cubit.selectTab(tab: 'featured'),
              ),
              _Tab(
                label: LocaleKeys.category.tr(),
                icon: Icons.category_rounded,
                isSelected: selectedTab == 'category',
                onTap: () => cubit.selectTab(tab: 'category'),
              ),
              _Tab(
                label: LocaleKeys.brand.tr(),
                icon: Icons.business_rounded,
                isSelected: selectedTab == 'brand',
                onTap: () => cubit.selectTab(tab: 'brand'),
              ),
              _Tab(
                label: LocaleKeys.bundles_title.tr(),
                icon: Icons.card_giftcard_rounded,
                isSelected: selectedTab == 'bundles',
                onTap: () => cubit.selectTab(tab: 'bundles'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveUI.padding(context, 10),
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: ResponsiveUI.iconSize(context, 20),
                color: isSelected ? AppColors.primaryBlue : AppColors.shadowGray,
              ),
              SizedBox(height: ResponsiveUI.value(context, 3)),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primaryBlue : AppColors.shadowGray,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: ResponsiveUI.fontSize(context, 11),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
