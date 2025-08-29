import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Shared/routes/routes.dart';
import '../../../Shared/widgets/language_toggle_button.dart';
import '../../controllers/language_controller.dart';

class WelcomeScreen extends GetView<LanguageController> {
  WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEBC794), Color(0xFFB38FFC)],
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Obx(() {
                      return LanguageToggleButton(
                        currentLanguage: controller.locale.value.languageCode == 'es' ? 'Es' : 'En',
                        onLanguageChanged: (lang) {
                          controller.changeLanguage(
                            lang == 'Es' ? const Locale('es', 'ES') : const Locale('en', 'US'),
                          );
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 120),
                  Center(
                    child: Image.asset(
                      'assets/images/splashScreen_image.png',
                      width: size.width * 0.85,
                      height: size.height * 0.28,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'welcomeTitle'.tr,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      height: 1.21,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'welcomeSubtitle'.tr,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      height: 1.21,
                      color: Color(0xFF6D6D73),
                    ),
                  ),
                  SizedBox(height: size.height * 0.15),
                  Center(
                    child: SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Get.toNamed(AppRoutes.login),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF262626),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'getStarted'.tr,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'disclaimer'.tr,
                      textAlign: TextAlign.start,

                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 9,
                        height: 1.21,
                        color: Color(0xFF6D6D73),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
