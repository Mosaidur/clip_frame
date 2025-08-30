import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Shared/routes/routes.dart';
import '../../../Shared/widgets/language_toggle_button.dart';
import '../../../splashScreen/controllers/language_controller.dart';
import '../../controllers/RegistrationProcessController.dart';
import '../widgets/BusinessTypeSelection.dart';

class RegistrationProcessPage extends StatelessWidget {
  final RegistrationProcessController controller = Get.find<RegistrationProcessController>();

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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Header of the auth feature
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    GestureDetector(
                      onTap: () {
                        if (controller.currentPage.value == 0) {
                          Get.back();
                        } else {
                          controller.previousPage();
                        }
                      },
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
                        currentLanguage: controller.languageController.locale.value.languageCode == 'es' ? 'Es' : 'En',
                        onLanguageChanged: (lang) {
                          controller.languageController.changeLanguage(
                            lang == 'Es' ? const Locale('es', 'ES') : const Locale('en', 'US'),
                          );
                        },
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 10),
                // PageView for navigation
                Expanded(
                  child: PageView(
                    controller: controller.pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) => controller.currentPage.value = index,
                    children: controller.pages,
                  ),
                ),
                const SizedBox(height: 25),
                // Page Indicator and Buttons
                Column(
                  children: [
                    // Page Indicator
                    Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(controller.pages.length, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: controller.currentPage.value == index
                                ? const Color(0xFF007CFE)
                                : Colors.white.withOpacity(0.5),
                          ),
                        );
                      }),
                    )),
                    const SizedBox(height: 10),
                    // Continue Button
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
                        onPressed: () {
                          if (controller.currentPage.value == 0) {
                            // Validate BusinessTypeSelectionPage
                            if (controller.businessTypeController.selectedBusinessTypes.isEmpty) {
                              Get.snackbar(
                                'Selection Required',
                                'Please select at least one business type.',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }
                          }
                          if (controller.currentPage.value < controller.pages.length - 1) {
                            controller.nextPage();
                          } else {
                            Get.toNamed(AppRoutes.login);
                          }
                        },
                        child: const Text("Continue", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Skip Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          if (controller.currentPage.value < controller.pages.length - 1) {
                            controller.nextPage();
                          } else {
                            Get.toNamed(AppRoutes.login);
                          }
                        },
                        child: const Text("SKIP", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
