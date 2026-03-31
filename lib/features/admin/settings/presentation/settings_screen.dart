import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/services/cache_helper.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/auth/presentation/view/login_screen.dart';
import 'package:systego/features/admin/warehouses/view/widgets/custom_delete_dialog.dart';
import 'package:systego/generated/locale_keys.g.dart';
import 'package:systego/main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.shadowGray[50],
      appBar: AppBar(
        title: Text(
          LocaleKeys.settings.tr(),
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: ResponsiveUI.fontSize(context, 18)),
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.darkGray,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: ResponsiveUI.value(context, 1), color: AppColors.lightGray),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
        children: [
          _SettingsCard(
            icon: Icons.translate_rounded,
            label: LocaleKeys.select_language.tr(),
            accentColor: AppColors.primaryBlue,
            onTap: () => _showLanguageDialog(context),
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          _SettingsCard(
            icon: Icons.logout_rounded,
            label: LocaleKeys.exit.tr(),
            accentColor: AppColors.red,
            isDestructive: true,
            onTap: () => _showLogoutDialog(context),
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 24)),
        ],
      ),
    );
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
