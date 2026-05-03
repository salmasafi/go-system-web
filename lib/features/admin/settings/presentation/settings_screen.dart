import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/services/cache_helper.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/features/admin/auth/presentation/view/login_screen.dart';
import 'package:GoSystem/features/admin/warehouses/view/widgets/custom_delete_dialog.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import 'package:GoSystem/main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scale down for web
    Widget screenContent = Scaffold(
      backgroundColor: Colors.white,
      appBar: appBarWithActions(
        context,
        title: LocaleKeys.settings.tr(),
        showBackButton: true,
      ),
      body: SafeArea(
        child: Center(
          child: Text(
            'Settings Screen - Under Development',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
    if (kIsWeb) {
      screenContent = MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(0.55),
        ),
        child: screenContent,
      );
    }
    return screenContent;
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16))),
        title: Text(LocaleKeys.select_language.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Text('🇬🇧', style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 24))),
              title: Text(LocaleKeys.english.tr()),
              onTap: () {
                context.setLocale(Locale('en'));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: Text('🇸🇦', style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 24))),
              title: Text(LocaleKeys.arabic.tr()),
              onTap: () {
                context.setLocale(const Locale('ar'));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: LocaleKeys.exit.tr(),
        message: LocaleKeys.exit_confirmation_message.tr(),
        icon: Icons.exit_to_app_rounded,
        iconColor: AppColors.red,
        deleteText: LocaleKeys.exit.tr(),
        onDelete: () async {
          Navigator.pop(dialogContext);
          await CacheHelper.clearAllData();
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        },
      ),
    );
  }
}

// ─── Settings Card ────────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsCard({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.red : accentColor;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
        ),
        leading: Container(
          padding: EdgeInsets.all(ResponsiveUI.padding(context, 8)),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10)),
          ),
          child: Icon(icon, color: color, size: ResponsiveUI.iconSize(context, 20)),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 15),
            fontWeight: FontWeight.w600,
            color: isDestructive ? AppColors.red : AppColors.darkGray,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: isDestructive ? AppColors.red : AppColors.shadowGray,
          size: ResponsiveUI.iconSize(context, 20),
        ),
      ),
    );
  }
}
