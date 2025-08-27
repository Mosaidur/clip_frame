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
    locale.value = code == 'es' ? const Locale('es', 'ES') : const Locale('en', 'US');
    Get.updateLocale(locale.value);
  }

  void changeLanguage(Locale newLocale) async {
    locale.value = newLocale;
    Get.updateLocale(newLocale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, newLocale.languageCode);
  }
}
