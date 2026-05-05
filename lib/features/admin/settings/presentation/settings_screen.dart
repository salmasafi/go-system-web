import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/services/cache_helper.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/core/widgets/animation/animated_element.dart';
import 'package:GoSystem/features/admin/auth/presentation/view/login_screen.dart';
import 'package:GoSystem/features/admin/warehouses/view/widgets/custom_delete_dialog.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import 'package:GoSystem/main.dart';
import 'package:GoSystem/features/pos/profile/presentation/profile_screen.dart';
import 'package:GoSystem/features/admin/auth/cubit/login_cubit.dart';

class SettingsScreen extends StatefulWidget {
  final bool showBackButton;
  const SettingsScreen({super.key, this.showBackButton = true});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Map<String, String> _languageMap = {
    'en': LocaleKeys.english,
    'ar': LocaleKeys.arabic,
  };

  String? _selectedLanguageCode;
  final List<MapEntry<String, String>> _languages = _languageMap.entries.toList();
  bool _isDarkMode = false; 
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _selectedLanguageCode = context.locale.languageCode;
      });
    });
  }

  void _changeAppLanguage(String languageCode) {
    if (languageCode == 'ar') {
      context.setLocale(const Locale('ar'));
    } else {
      context.setLocale(const Locale('en'));
    }
    setState(() {
      _selectedLanguageCode = languageCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<LoginCubit>().savedUser;

    Widget screenContent = Scaffold(
      backgroundColor: AppColors.shadowGray[50],
      appBar: appBarWithActions(
        context,
        title: LocaleKeys.settings.tr(),
        showBackButton: widget.showBackButton,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Profile Section ──────────────────────────────────────────
                _buildSectionTitle('الملف الشخصي'.tr()),
                _buildProfileCard(user),
                SizedBox(height: ResponsiveUI.spacing(context, 20)),

                // ─── Appearance Section ───────────────────────────────────────
                _buildSectionTitle('المظهر'.tr()), 
                _buildAppearanceCard(),
                SizedBox(height: ResponsiveUI.spacing(context, 20)),

                // ─── Notifications Section ───────────────────────────────────
                _buildSectionTitle('التنبيهات'.tr()),
                _buildNotificationsCard(),
                SizedBox(height: ResponsiveUI.spacing(context, 20)),

                // ─── App Language Section ─────────────────────────────────────
                _buildSectionTitle(LocaleKeys.language.tr()),
                _buildLanguageCard(),
                SizedBox(height: ResponsiveUI.spacing(context, 20)),

                // ─── Logout Section ───────────────────────────────────────────
                _buildLogoutCard(),
                SizedBox(height: ResponsiveUI.spacing(context, 40)),
              ],
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(
        left: ResponsiveUI.padding(context, 4),
        bottom: ResponsiveUI.padding(context, 8),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveUI.fontSize(context, 14),
          fontWeight: FontWeight.bold,
          color: AppColors.mediumGray,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildProfileCard(dynamic user) {
    final name = user?.username ?? 'Guest';
    final email = user?.email ?? 'No email provided';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return AnimatedElement(
      delay: const Duration(milliseconds: 50),
      child: Container(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: ResponsiveUI.value(context, 28),
              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 20),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            SizedBox(width: ResponsiveUI.spacing(context, 16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 18),
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGray,
                    ),
                  ),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 13),
                      color: AppColors.shadowGray,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios_rounded, size: ResponsiveUI.iconSize(context, 16)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceCard() {
    return AnimatedElement(
      delay: const Duration(milliseconds: 100),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            SwitchListTile(
              secondary: Icon(Icons.dark_mode_rounded, color: Colors.indigo),
              title: Text(
                'الوضع الليلي'.tr(),
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 15),
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text('تغيير مظهر التطبيق'.tr(), style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 12))),
              value: _isDarkMode,
              activeColor: AppColors.primaryBlue,
              onChanged: (v) {
                setState(() => _isDarkMode = v);
                CustomSnackbar.showInfo(context, 'سيتم تفعيل هذه الميزة قريباً'.tr());
              },
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: Icon(Icons.palette_rounded, color: Colors.amber[700]),
              title: Text(
                'لون السمة'.tr(),
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 15),
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
              ),
              onTap: () => CustomSnackbar.showInfo(context, 'سيتم تفعيل هذه الميزة قريباً'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return AnimatedElement(
      delay: const Duration(milliseconds: 150),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            SwitchListTile(
              secondary: Icon(Icons.notifications_active_rounded, color: Colors.blue),
              title: Text(
                'إشعارات النظام'.tr(),
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 15),
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text('تلقي تنبيهات العمليات والتقارير'.tr(), style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 12))),
              value: _notificationsEnabled,
              activeColor: AppColors.primaryBlue,
              onChanged: (v) {
                setState(() => _notificationsEnabled = v);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard() {
    return AnimatedElement(
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: _languages.map((entry) => _buildLanguageOption(entry)).toList(),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(MapEntry<String, String> entry) {
    final isSelected = _selectedLanguageCode == entry.key;
    return InkWell(
      onTap: () {
        if (!isSelected) {
          _changeAppLanguage(entry.key);
          CustomSnackbar.showSuccess(context, '${LocaleKeys.language_changed.tr()} ${entry.value.tr()}');
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 4)),
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
        ),
        child: Row(
          children: [
            Text(
              entry.key == 'ar' ? '🇸🇦' : '🇬🇧',
              style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 20)),
            ),
            SizedBox(width: ResponsiveUI.spacing(context, 12)),
            Text(
              entry.value.tr(),
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 15),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primaryBlue : AppColors.darkGray,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue, size: ResponsiveUI.iconSize(context, 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutCard() {
    return AnimatedElement(
      delay: const Duration(milliseconds: 250),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          onTap: _showLogoutDialog,
          leading: Icon(Icons.logout_rounded, color: AppColors.red),
          title: Text(
            LocaleKeys.exit.tr(),
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 15),
              fontWeight: FontWeight.bold,
              color: AppColors.red,
            ),
          ),
          trailing: Icon(Icons.chevron_right_rounded, color: AppColors.red),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
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
