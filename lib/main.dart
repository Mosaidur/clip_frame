import 'package:camera/camera.dart';
import 'package:clip_frame/splashScreen/controllers/language_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'L10/AppTranslations.dart';
import 'Shared/routes/routes.dart';
import 'Shared/theme/AppTheme.dart';

import 'package:flutter/services.dart';

import 'package:clip_frame/core/services/notification_service.dart';
import 'package:clip_frame/core/services/database_service.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("Native called background task: $task");
    // You can perform periodic sync here if needed
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await NotificationService.init();
  await DatabaseService.database;

  // Initialize Workmanager
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true, // Set to false in production
  );

  // Register a periodic task for syncing
  Workmanager().registerPeriodicTask(
    "1",
    "periodic-sync-task",
    frequency: const Duration(hours: 1), // Run every 1 hour
  );

  // Set status bar to transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          Brightness.dark, // Adjust based on your primary background
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Initialize the language controller
  Get.put(LanguageController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
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
              Locale('hi', 'IN')
            ],
            initialRoute: AppRoutes.SPLASH,
            getPages: AppRoutes.pages,
            debugShowCheckedModeBanner: false,
          );
        });
      },
    );
  }
}
