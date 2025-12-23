import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:systego/generated/locale_keys.g.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/animation/simple_fadein_animation_widget.dart';

class LogoAndTitleWidget extends StatelessWidget {
  const LogoAndTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeInAnimation(
      delay: const Duration(milliseconds: 200),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.bounceOut,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightBlueBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.shopping_cart_checkout_outlined,
              size: 80,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
           Text(
            LocaleKeys.app_name.tr(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
              letterSpacing: 1.2,
            ),
          ),
          Text(
            LocaleKeys.manage_your_business.tr(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}