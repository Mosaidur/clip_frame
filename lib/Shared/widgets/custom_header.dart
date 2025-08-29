import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../splashScreen/controllers/language_controller.dart';
import 'language_toggle_button.dart';

class HeaderWithBackAndLanguage extends StatelessWidget {
  // Controller for language (example GetX controller)
  final LanguageController controller = Get.put(LanguageController());

  HeaderWithBackAndLanguage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black12,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),

          // Language Toggle
          Obx(() {
            return LanguageToggleButton(
              currentLanguage: controller.locale.value.languageCode == 'es' ? 'Es' : 'En',
              onLanguageChanged: (lang) {
                controller.changeLanguage(
                  lang == 'Es' ? const Locale('es', 'ES') : const Locale('en', 'US'),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}


