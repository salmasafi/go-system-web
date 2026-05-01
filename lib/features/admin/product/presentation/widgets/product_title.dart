import 'package:flutter/material.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';

class ProductTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const ProductTitle({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 20),
            fontWeight: FontWeight.w700,
            color: AppColors.darkBlue,
            height: ResponsiveUI.value(context, 1.3),
          ),
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 8)),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 14),
            color: AppColors.shadowGray[600],
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
