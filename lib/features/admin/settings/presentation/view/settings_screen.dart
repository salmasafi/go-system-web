import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/core/widgets/animation/animated_element.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _selectedLanguageCode = context.locale.languageCode;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedLanguageCode != context.locale.languageCode) {
      _selectedLanguageCode = context.locale.languageCode;
    }
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
    // Scale down for web
    Widget screenContent = Scaffold(
      backgroundColor: AppColors.shadowGray[50],
      appBar: _buildCustomAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            child: Column(
              children: [
                _buildProfileSection(),
                SizedBox(height: ResponsiveUI.spacing(context, 24)),
                _buildSettingsSection(),
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

  PreferredSizeWidget _buildCustomAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.shadowGray[50],
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: Text(
        LocaleKeys.settings.tr(),
        style: TextStyle(
          fontSize: ResponsiveUI.fontSize(context, 24),
          fontWeight: FontWeight.w700,
          color: AppColors.darkGray,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProfileSection() {
    return AnimatedElement(
      delay: const Duration(milliseconds: 100),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryBlue,
              AppColors.primaryBlue.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: ResponsiveUI.value(context, 80),
              height: ResponsiveUI.value(context, 80),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.person,
                size: ResponsiveUI.iconSize(context, 40),
                color: AppColors.primaryBlue,
              ),
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 16)),
            Text(
              'Admin User',
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 20),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 4)),
            Text(
              'admin@gosystem.com',
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 14),
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      children: [
        _buildLanguageCard(),
        SizedBox(height: ResponsiveUI.spacing(context, 16)),
        _buildAppearanceCard(),
        SizedBox(height: ResponsiveUI.spacing(context, 16)),
        _buildAboutCard(),
        SizedBox(height: ResponsiveUI.spacing(context, 16)),
        _buildLogoutCard(),
      ],
    );
  }

  Widget _buildLanguageCard() {
    return AnimatedElement(
      delay: const Duration(milliseconds: 200),
      child: _buildSettingsCard(
        icon: Icons.language_rounded,
        iconColor: AppColors.primaryBlue,
        title: LocaleKeys.language.tr(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.select_language.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.darkGray.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 12)),
            Container(
              decoration: BoxDecoration(
                color: AppColors.shadowGray[100],
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                border: Border.all(
                  color: AppColors.primaryBlue.withValues(alpha: 0.2),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLanguageCode,
                  isExpanded: true,
                  icon: Padding(
                    padding: EdgeInsets.only(right: ResponsiveUI.padding(context, 16)),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  items: _languages.map((MapEntry<String, String> entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 16)),
                        child: Row(
                          children: [
                            Text(
                              entry.key == 'ar' ? '🇸🇦' : '🇬🇧',
                              style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 20)),
                            ),
                            SizedBox(width: ResponsiveUI.spacing(context, 12)),
                            Text(
                              entry.value.tr(),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null && newValue != _selectedLanguageCode) {
                      _changeAppLanguage(newValue);
                      _showLanguageChangeSnackbar(newValue);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceCard() {
    return AnimatedElement(
      delay: const Duration(milliseconds: 300),
      child: _buildSettingsCard(
        icon: Icons.palette_rounded,
        iconColor: Colors.purple,
        title: 'Appearance',
        child: Column(
          children: [
            _buildSettingsTile(
              icon: Icons.dark_mode_rounded,
              title: 'Dark Mode',
              subtitle: 'Toggle dark theme',
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  // TODO: Implement dark mode
                },
                activeColor: AppColors.primaryBlue,
              ),
            ),
            Divider(height: 1, color: AppColors.lightGray),
            _buildSettingsTile(
              icon: Icons.text_fields_rounded,
              title: 'Font Size',
              subtitle: 'Adjust text size',
              trailing: Icon(Icons.chevron_right_rounded, color: AppColors.shadowGray),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return AnimatedElement(
      delay: const Duration(milliseconds: 400),
      child: _buildSettingsCard(
        icon: Icons.info_rounded,
        iconColor: AppColors.mediumBlue700,
        title: 'About',
        child: Column(
          children: [
            _buildSettingsTile(
              icon: Icons.info_rounded,
              title: 'App Version',
              subtitle: 'Version 1.0.0',
              trailing: null,
            ),
            Divider(height: 1, color: AppColors.lightGray),
            _buildSettingsTile(
              icon: Icons.privacy_tip_rounded,
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              trailing: Icon(Icons.chevron_right_rounded, color: AppColors.shadowGray),
            ),
            Divider(height: 1, color: AppColors.lightGray),
            _buildSettingsTile(
              icon: Icons.description_rounded,
              title: 'Terms of Service',
              subtitle: 'Read our terms',
              trailing: Icon(Icons.chevron_right_rounded, color: AppColors.shadowGray),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutCard() {
    return AnimatedElement(
      delay: const Duration(milliseconds: 500),
      child: Container(
        width: double.infinity,
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
          leading: Container(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
            ),
            child: Icon(
              Icons.logout_rounded,
              color: AppColors.red,
              size: ResponsiveUI.iconSize(context, 24),
            ),
          ),
          title: Text(
            LocaleKeys.exit.tr(),
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: AppColors.red,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: AppColors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: ResponsiveUI.iconSize(context, 24),
                  ),
                ),
                SizedBox(width: ResponsiveUI.spacing(context, 16)),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 18),
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGray,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: ResponsiveUI.padding(context, 16),
              right: ResponsiveUI.padding(context, 16),
              bottom: ResponsiveUI.padding(context, 16),
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 8)),
        decoration: BoxDecoration(
          color: AppColors.shadowGray[100],
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
        ),
        child: Icon(
          icon,
          color: AppColors.darkGray,
          size: ResponsiveUI.iconSize(context, 20),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveUI.fontSize(context, 14),
          fontWeight: FontWeight.w500,
          color: AppColors.darkGray,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: ResponsiveUI.fontSize(context, 12),
          color: AppColors.darkGray.withValues(alpha: 0.6),
        ),
      ),
      trailing: trailing,
    );
  }

  void _showLanguageChangeSnackbar(String languageCode) {
    final languageName = _languageMap[languageCode]?.tr() ?? languageCode;
    CustomSnackbar.showSuccess(
      context, 
      '${LocaleKeys.language_changed.tr()} $languageName'
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
        ),
        title: Row(
          children: [
            Icon(
              Icons.logout_rounded,
              color: AppColors.red,
              size: ResponsiveUI.iconSize(context, 24),
            ),
            SizedBox(width: ResponsiveUI.spacing(context, 12)),
            Text(
              LocaleKeys.exit.tr(),
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 18),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          LocaleKeys.exit_confirmation_message.tr(),
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 14),
            color: AppColors.darkGray.withValues(alpha: 0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement logout logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
              ),
            ),
            child: Text(
              LocaleKeys.exit.tr(),
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
