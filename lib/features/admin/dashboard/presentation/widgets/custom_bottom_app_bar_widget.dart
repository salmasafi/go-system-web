import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/generated/locale_keys.g.dart';

class CustomBottomAppBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomAppBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ConvexAppBar(
      style: TabStyle.fixedCircle,
      backgroundColor: Colors.white,
      activeColor: AppColors.linkBlue,
      color: Colors.grey[600],
      height: 60,
      top: -25,
      curveSize: 90,
      elevation: 8,
      shadowColor: Colors.black26,
      items: [
        TabItem(
          icon: Icons.dashboard_rounded,
          title: LocaleKeys.dashboard.tr(),
        ),
        // TabItem(
        //   icon: Icons.category_rounded,
        //   title: 'Product',
        // ),
        TabItem(
          // icon: Icons.print_rounded,
          // title: 'Print',
          icon: Icons.point_of_sale_rounded,
          title: LocaleKeys.point_of_sale.tr(),
        ),
        // TabItem(
        //   icon: Icons.bar_chart_rounded,
        //   title: 'Reports',
        // ),
        TabItem(
          icon: Icons.exit_to_app_rounded, //Icons.more_horiz_rounded,
          title: LocaleKeys.exit.tr(),
        ),
      ],
      initialActiveIndex: currentIndex,
      onTap: onTap,
    );
  }
}
