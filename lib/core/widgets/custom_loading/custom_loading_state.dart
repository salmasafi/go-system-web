import 'package:flutter/material.dart';
import 'package:systego/core/utils/responsive_ui.dart';

import '../../constants/app_colors.dart';

class CustomLoadingState extends StatelessWidget {
  final String? message;
  final Color? color;
  final double? size;

  const CustomLoadingState({super.key, this.message, this.color, this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: ResponsiveUI.spacing(context, size ?? 45),
            height: ResponsiveUI.spacing(context, size ?? 45),
            child: CircularProgressIndicator(
              color: color ?? AppColors.primaryBlue,
              strokeWidth: 5,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 20),
            Text(
              message!,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
