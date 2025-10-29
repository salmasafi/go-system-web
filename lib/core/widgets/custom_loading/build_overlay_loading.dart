import 'package:flutter/material.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state.dart';
import '../../constants/app_colors.dart';
import '../../utils/responsive_ui.dart';

Widget buildLoadingOverlay(BuildContext context, double size) {
  final borderRadius24 = ResponsiveUI.borderRadius(context, 24);
  final borderRadius20 = ResponsiveUI.borderRadius(context, 20);
  final padding30 = ResponsiveUI.padding(context, 30);
  final value10 = ResponsiveUI.value(context, 0.1);
  final value20Blur = ResponsiveUI.value(context, 20);

  return Container(
    decoration: BoxDecoration(
      color: AppColors.white.withOpacity(0.95),
      borderRadius: BorderRadius.circular(borderRadius24),
    ),
    child: Center(
      child: Container(
        padding: EdgeInsets.all(padding30),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(borderRadius20),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(value10),
              blurRadius: value20Blur,
            ),
          ],
        ),
        child: CustomLoadingState(
          color: AppColors.primaryBlue,
          message: 'Processing...',
          size: size,
        ),
      ),
    ),
  );
}
