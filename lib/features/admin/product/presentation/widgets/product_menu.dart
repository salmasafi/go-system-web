import 'package:flutter/material.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';

class ProductMenu extends StatelessWidget {
  const ProductMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.more_vert,
        color: AppColors.shadowGray[600],
        size: ResponsiveUI.iconSize(context, 20),
      ),
      onPressed: () {
        // Handle menu tap
      },
    );
  }
}
