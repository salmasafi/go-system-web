import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';

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
    return Container(
      height: kIsWeb ? 60 : ResponsiveUI.value(context, 75),
      child: ConvexAppBar(
        style: TabStyle.fixedCircle,
        backgroundColor: Colors.white,
        activeColor: AppColors.primaryBlue,
        color: Colors.grey[600],
        height: kIsWeb ? 60 : ResponsiveUI.value(context, 65),
        top: kIsWeb ? -15 : -25,
        curveSize: kIsWeb ? 60 : 100,
        elevation: 2,
        shadowColor: Colors.black12,
        items: [
          TabItem(
            icon: Icons.dashboard_rounded,
            title: LocaleKeys.dashboard.tr(),
          ),
          // TabItem(icon: Icons.shopping_bag_outlined, title: 'Online'),
          TabItem(
            icon: Icons.point_of_sale_rounded,
            title: LocaleKeys.point_of_sale.tr(),
          ),
          TabItem(
            icon: Icons.settings_rounded,
            title: LocaleKeys.settings.tr(),
          ),
          // TabItem(icon: Icons.exit_to_app_rounded, title: LocaleKeys.exit.tr()),
        ],
        initialActiveIndex: currentIndex,
        onTap: onTap,
      ),
    );
  }
}
