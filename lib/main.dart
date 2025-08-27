import 'package:clip_frame/splashScreen/controllers/language_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'L10/AppTranslations.dart';
import 'Shared/routes/routes.dart';
import 'Shared/theme/AppTheme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the language controller
  Get.put(LanguageController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<LanguageController>();

      return GetMaterialApp(
        title: 'ClipFrame',
        theme: AppTheme.lightTheme,
        locale: controller.locale.value,
        fallbackLocale: const Locale('en', 'US'),
        translations: AppTranslations(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('es', 'ES'),
        ],
        initialRoute: AppRoutes.WELCOME,
        getPages: AppRoutes.pages,
        debugShowCheckedModeBanner: false,
      );
    });
  }
}
