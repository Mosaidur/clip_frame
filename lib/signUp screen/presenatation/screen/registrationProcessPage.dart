import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Shared/routes/routes.dart';
import '../../../Shared/widgets/customText.dart';
import '../../../Shared/widgets/language_toggle_button.dart';
import '../../../splashScreen/controllers/language_controller.dart';
import '../../controllers/SignUpControllerPage.dart';
import '../widgets/BusinessTypeSelection.dart';

class RegistrationProcessPage extends StatelessWidget {
  final LanguageController langController = Get.put(LanguageController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFB49EF4), Color(0xFFEBC894)],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                // Header of the auth feature
                Row(
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
                        currentLanguage: langController.locale.value.languageCode == 'es' ? 'Es' : 'En',
                        onLanguageChanged: (lang) {
                          langController.changeLanguage(
                            lang == 'Es' ? const Locale('es', 'ES') : const Locale('en', 'US'),
                          );
                        },
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 30),
                BusinessTypeSelectionPage(),
                const SizedBox(height: 25),
                // Continue Button

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007CFE),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {},
                          child: const Text(
                            "Continue",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Skip Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black54,
                            side: const BorderSide(color: Colors.black54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {},
                          child: const Text(
                            "SKIP",
                            style: TextStyle(color: Colors.black54, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}