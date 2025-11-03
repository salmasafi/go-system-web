import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';

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
        width: ResponsiveUI.value(context, width ?? 50),
        height: ResponsiveUI.value(context, height ?? 5),
        decoration: BoxDecoration(
          color: color ?? AppColors.lightGray,
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10)),
        ),
      ),
    );
  }
}