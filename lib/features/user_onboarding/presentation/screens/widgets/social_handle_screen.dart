import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/user_onboarding_page_controller.dart';

class SocialHandleScreen extends GetView<UserOnboardingPageController> {
  const SocialHandleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Text(
            "${controller.selectedPlatform.value.capitalizeFirst} Handle",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          )),
          const SizedBox(height: 10),
          Text(
            "Enter your username",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 30),
          
          TextField(
            controller: controller.handleController,
            decoration: InputDecoration(
              labelText: controller.handleLabel,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          
          const Spacer(),
          
          Obx(() => SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : Text(
                      "Continue",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          )),
        ],
      ),
    );
  }
}
