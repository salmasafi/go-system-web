import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:systego/generated/locale_keys.g.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/animation/simple_fadein_animation_widget.dart';

class LoginTitleWidget extends StatelessWidget {
  const LoginTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeInAnimation(
      delay: const Duration(milliseconds: 400),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          LocaleKeys.login.tr(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.darkBlue,
          ),
        ),
      ),
    );
  }
}