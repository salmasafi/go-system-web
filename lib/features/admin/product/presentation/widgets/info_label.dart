import 'package:flutter/material.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';

class InfoLabel extends StatelessWidget {
  final String label;

  const InfoLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: AppColors.shadowGray[500],
        fontSize: ResponsiveUI.fontSize(context, 11),
      ),
    );
  }
}
