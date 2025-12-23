import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/generated/locale_keys.g.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Use language codes as values instead of translated strings
  static const Map<String, String> _languageMap = {
    'en': LocaleKeys.english,
    'ar': LocaleKeys.arabic,
  };

  String? _selectedLanguageCode;
  final List<MapEntry<String, String>> _languages = _languageMap.entries.toList();

  @override
  void initState() {
    super.initState();
    // Initialize with current locale
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _selectedLanguageCode = context.locale.languageCode;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure selected language is updated if locale changes elsewhere
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
    return Scaffold(
      appBar: appBarWithActions(
        context,
        title: LocaleKeys.settings.tr(),
        showActions: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ResponsiveUI.spacing(context, 14)),

            _buildLanguageSection(),

            SizedBox(height: ResponsiveUI.spacing(context, 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection() {
    return AnimatedElement(
      delay: const Duration(milliseconds: 200),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.language,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
                SizedBox(width: ResponsiveUI.spacing(context, 10)),
                Text(
                  LocaleKeys.language.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            SizedBox(height: ResponsiveUI.spacing(context, 10)),

            Text(
              LocaleKeys.select_language.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: ResponsiveUI.spacing(context, 10)),

            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLanguageCode,
                  isExpanded: true,
                  icon: Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  items: _languages.map((MapEntry<String, String> entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key, // Use language code as value
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          entry.value.tr(), // Translate the display text
                          style: Theme.of(context).textTheme.bodyLarge,
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

            SizedBox(height: ResponsiveUI.spacing(context, 10)),
          ],
        ),
      ),
    );
  }

  void _showLanguageChangeSnackbar(String languageCode) {
    final languageName = _languageMap[languageCode]?.tr() ?? languageCode;
    CustomSnackbar.showSuccess(
      context, 
      '${LocaleKeys.language_changed.tr()} $languageName'
    );
  }
}