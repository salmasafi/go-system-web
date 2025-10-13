import 'package:flutter/material.dart';

import '../../../../../../../core/constants/app_colors.dart';

class CustomDragHandle extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? color;

  const CustomDragHandle({
    super.key,
    this.width,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width ?? 50,
        height: height ?? 5,
        decoration: BoxDecoration(
          color: color ?? AppColors.lightGray,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}