import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';

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
