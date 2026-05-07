import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import '../../../../../core/widgets/animation/simple_fadein_animation_widget.dart';

class LogoAndTitleWidget extends StatelessWidget {
  const LogoAndTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeInAnimation(
      delay: const Duration(milliseconds: 200),
      child: Column(
        children: [
          Image.asset(
            'assets/images/gosystem_logo.png',
            height: ResponsiveUI.value(context, 110),
            fit: BoxFit.contain,
          ),
          SizedBox(height: ResponsiveUI.value(context, 12)),
          Text(
            LocaleKeys.manage_your_business.tr(),
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 14),
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
