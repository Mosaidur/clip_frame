import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/user_onboarding_page_controller.dart';
import 'widgets/business_type_screen.dart';
import 'widgets/business_description_screen.dart';
import 'widgets/audience_language_screen.dart';

class UserOnboardingWrapper extends GetView<UserOnboardingPageController> {
  const UserOnboardingWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFF0F5),
              Color(0xFFE6E6FA),
            ], // Light pink to lavender
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        if (controller.currentPage.value > 0) {
                          controller.previousPage();
                        } else {
                          Get.back();
                        }
                      },
                    ),
                    Obx(
                      () => Text(
                        "Step ${controller.currentPage.value + 1}/5",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance for back button
                  ],
                ),
              ),

              Expanded(
                child: PageView(
                  controller: controller.pageController,
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable swipe
                  children: const [
                    BusinessTypeScreen(),
                    BusinessDescriptionScreen(),
                    AudienceLanguageScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
