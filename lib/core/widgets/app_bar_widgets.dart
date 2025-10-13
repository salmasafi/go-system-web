import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

AppBar appBarWithActions(
    BuildContext context,
    String title,
    void Function() onPressed,
    ) {
  return AppBar(
    scrolledUnderElevation: 0,
    elevation: 0,
    backgroundColor: AppColors.white,
    centerTitle: true,
    title: Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.darkGray,
        letterSpacing: 0.5,
      ),
    ),
    leading: Container(
      margin: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.lightBlueBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.primaryBlue,
          size: 20,
        ),
        padding: EdgeInsets.zero,
      ),
    ),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(
        height: 1,
        color: AppColors.lightGray.withOpacity(0.3),
      ),
    ),
  );
}