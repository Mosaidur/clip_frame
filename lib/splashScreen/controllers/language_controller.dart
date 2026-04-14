import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  static const _langKey = 'selected_language';
  var locale = const Locale('en', 'US').obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  void _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_langKey) ?? 'en';
    locale.value = _getLocaleFromCode(code);
    Get.updateLocale(locale.value);
  }

  Locale _getLocaleFromCode(String code) {
    switch (code) {
      case 'es':
        return const Locale('es', 'ES');
      case 'hi':
        return const Locale('hi', 'IN');
      case 'en':
      default:
        return const Locale('en', 'US');
    }
  }

  void changeLanguage(String languageName) async {
    print(
      "🌍 LanguageController: Request to change language to: $languageName",
    );
    String code = 'en';
    String lang = languageName.toLowerCase().trim();
    if (lang == 'hindi' || lang == 'hi') {
      code = 'hi';
    } else if (lang == 'spanish' || lang == 'es') {
      code = 'es';
    } else {
      code = 'en';
    }

    Locale newLocale = _getLocaleFromCode(code);
    print(
      "🌍 LanguageController: Setting locale to: ${newLocale.languageCode}",
    );
    locale.value = newLocale;
    Get.updateLocale(newLocale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, code);
  }

  void changeLocale(Locale newLocale) async {
    locale.value = newLocale;
    Get.updateLocale(newLocale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, newLocale.languageCode);
  }
}
