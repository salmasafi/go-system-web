import 'package:flutter/material.dart';
import 'package:systego/core/utils/responsive_ui.dart';

import '../constants/app_colors.dart';

AppBar appBarWithActions(
    BuildContext context,
    String title,
    void Function() onPressed,
    {bool showActions = false}
    ) {
  return AppBar(
    scrolledUnderElevation: 0,
    elevation: 0,
    backgroundColor: AppColors.white,
    centerTitle: true,
    title: Text(
      title,
      style: TextStyle(
        fontSize: ResponsiveUI.fontSize(context, 20),
        fontWeight: FontWeight.w600,
        color: AppColors.darkGray,
        letterSpacing: 0.5,
      ),
    ),
    leading: Container(
      margin: EdgeInsets.only(
        left: ResponsiveUI.padding(context, 8),
        top: ResponsiveUI.padding(context, 8),
        bottom: ResponsiveUI.padding(context, 8),
      ),
      decoration: BoxDecoration(
        color: AppColors.lightBlueBackground,
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12),),
      ),
      child: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.primaryBlue,
          size: ResponsiveUI.fontSize(context, 20),
        ),
        padding: EdgeInsets.zero,
      ),
    ),
    actions: showActions ? [
      Container(
        margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.lightBlueBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: const Icon(
            Icons.add,
            color: AppColors.primaryBlue,
            size: 20,
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    ] : null,
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(ResponsiveUI.value(context, 1)),
      child: Container(
        height: ResponsiveUI.value(context, 1),
        color: AppColors.lightGray.withOpacity(0.3),
      ),
    ),
  );
}