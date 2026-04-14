import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../splashScreen/controllers/language_controller.dart';
import 'language_toggle_button.dart';
import 'package:clip_frame/core/widgets/custom_back_button.dart';

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
          CustomBackButton(
            onPressed: () => Get.back(),
            iconColor: Colors.white,
          ),

          // Language Toggle
          Obx(() {
            return LanguageToggleButton(
              currentLanguage: controller.locale.value.languageCode == 'es' ? 'Es' : 'En',
              onLanguageChanged: (lang) {
                controller.changeLocale(
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


