import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  LocalizationService._();

  static const String _prefLanguageCodeKey = 'app_language_code';

  static const Locale fallbackLocale = Locale('en');
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('gu'),
  ];

  static final Map<String, Map<String, String>> _translations = {};
  static late Locale _currentLocale;

  static Locale get currentLocale => _currentLocale;
  static Map<String, Map<String, String>> get translations => _translations;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode =
        prefs.getString(_prefLanguageCodeKey) ?? fallbackLocale.languageCode;
    _currentLocale = Locale(savedLanguageCode);

    await _loadLanguage('en');
    await _loadLanguage('hi');
    await _loadLanguage('gu');
  }

  static Future<void> changeLanguage(String languageCode) async {
    final locale = Locale(languageCode);
    _currentLocale = locale;
    Get.updateLocale(locale);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefLanguageCodeKey, languageCode);
  }

  static Future<void> _loadLanguage(String code) async {
    final raw = await rootBundle.loadString('assets/lang/$code.json');
    final map = jsonDecode(raw) as Map<String, dynamic>;
    _translations[code] = map.map(
      (key, value) => MapEntry(key, value.toString()),
    );
  }
}
