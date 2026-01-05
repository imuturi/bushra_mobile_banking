import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _languageCodeKey = 'language_code';

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  /// Load saved language on app start
  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageCodeKey) ?? 'en';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  /// Set language manually
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, locale.languageCode);
  }

  /// Toggle between EN and SO
  Future<void> toggleLanguage() async {
    final newLocale =
    _locale.languageCode == 'en' ? const Locale('so') : const Locale('en');

    await setLocale(newLocale);
  }
}
