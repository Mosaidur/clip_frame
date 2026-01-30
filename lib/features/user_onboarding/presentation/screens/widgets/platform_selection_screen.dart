import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/user_onboarding_page_controller.dart';

class PlatformSelectionScreen extends GetView<UserOnboardingPageController> {
  const PlatformSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Social Media Platforms Selection",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Choose one or more social media platforms", // Keeping text consistent with prompt
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 30),
          
          Text(
            "Choose Platforms:",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // Platform Selection
          Wrap(
            spacing: 20,
            children: controller.socialPlatformOptions.map((platform) {
              return Obx(() {
                final isSelected = controller.selectedPlatform.value == platform['key'];
                return GestureDetector(
                    onTap: () => controller.selectPlatform(platform['key']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.deepPurple.withOpacity(0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                          width: 2,
                        ),
                      ), // Use platform specific styling if needed, keeping simple for now
                      child: Center(
                        child: Icon(
                          platform['icon'],
                          color: isSelected ? Colors.deepPurple : Colors.grey,
                          size: 40,
                        ),
                      ),
                    ),
                  );
              });
            }).toList(),
          ),
          
          const Spacer(),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: controller.nextPage, 
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Continue",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
