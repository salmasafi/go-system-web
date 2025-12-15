
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LanguageManager extends ChangeNotifier {
  static LanguageManager? _instance;
  
  Locale? _currentLocale;
  Locale? get currentLocale => _currentLocale;
  
  bool get isArabic => _currentLocale?.languageCode == 'ar';
  
  LanguageManager._internal();
  
  factory LanguageManager() {
    return _instance ??= LanguageManager._internal();
  }
  
  void checkSystemLanguage(BuildContext context) {
    final systemLocale = WidgetsBinding.instance.window.locale;
    final appLocale = context.locale;
    
    if (systemLocale.languageCode != appLocale.languageCode) {
      _currentLocale = systemLocale.languageCode == 'ar' 
          ? Locale('ar') 
          : Locale('en');
      
      context.setLocale(_currentLocale!);
      notifyListeners();
    }
  }
  
  void setLanguage(BuildContext context, String languageCode) {
    _currentLocale = languageCode == 'ar' ? Locale('ar') : Locale('en');
    context.setLocale(_currentLocale!);
    notifyListeners();
  }
}