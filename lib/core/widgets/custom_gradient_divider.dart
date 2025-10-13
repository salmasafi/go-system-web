import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CustomGradientDivider extends StatelessWidget {
  final double? height;
  final List<Color>? colors;

  const CustomGradientDivider({
    super.key,
    this.height,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors ??
              [
                AppColors.lightGray.withOpacity(0.3),
                AppColors.primaryBlue.withOpacity(0.3),
                AppColors.lightGray.withOpacity(0.3),
              ],
        ),
      ),
    );
  }
}
