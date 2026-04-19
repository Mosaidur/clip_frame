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
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:intl/date_symbol_data_local.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("Native called background task: $task");
    // You can perform periodic sync here if needed
    return Future.value(true);
  });
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint("🚀 App Starting: Flutter bindings initialized");

    // Initialize localization data
    try {
      await initializeDateFormatting();
      debugPrint("✅ Services: intl initialized");
    } catch (e) {
      debugPrint("⚠️ Services: intl initialization failed: $e");
    }

    // Initialize Stripe
    try {
      Stripe.publishableKey =
          'pk_test_51RcvK8GdOsJASBMC9aDK1onP8kTVwAxve4385Mr09r2Edd1fxcbSWD1y5DCclahZ7MHa0hf1eBnsnq16bWavPRY400W2WfumAa';
      await Stripe.instance.applySettings();
      debugPrint("✅ Services: Stripe initialized");
    } catch (e) {
      debugPrint("⚠️ Services: Stripe initialization failed: $e");
    }

    // Initialize services
    try {
      await NotificationService.init();
      debugPrint("✅ Services: Notifications initialized");
    } catch (e) {
      debugPrint("⚠️ Services: Notifications initialization failed: $e");
    }

    try {
      await DatabaseService.database;
      debugPrint("✅ Services: Database initialized");
    } catch (e) {
      debugPrint("⚠️ Services: Database initialization failed: $e");
    }

    // Initialize Workmanager
    try {
      Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false, // Set to false in production
      );

      // Register a periodic task for syncing
      Workmanager().registerPeriodicTask(
        "1",
        "periodic-sync-task",
        frequency: const Duration(hours: 1), // Run every 1 hour
      );
      debugPrint("✅ Services: Workmanager initialized");
    } catch (e) {
      debugPrint("⚠️ Services: Workmanager initialization failed: $e");
    }

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
    debugPrint("✅ Services: LanguageController registered");

    debugPrint("🎬 Calling runApp(MyApp)");
    runApp(const MyApp());
  } catch (e, stack) {
    debugPrint("❌ CRITICAL ERROR during main initialization: $e");
    debugPrint(stack.toString());
    // Fallback if something really bad happens before root build
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text("Startup Error:\n$e", textAlign: TextAlign.center),
          ),
        ),
      ),
    ));
  }
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
          // Safety check: ensure controller is available to avoid Obx crash
          if (!Get.isRegistered<LanguageController>()) {
            return const MaterialApp(
              home: Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }

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
