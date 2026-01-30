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
            "Connect your Social Profile",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Select the primary platform where you want to share content.",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 30),
          
          Expanded(
            child: Obx(() => ListView.builder(
              itemCount: controller.socialPlatformOptions.length,
              itemBuilder: (context, index) {
                final platform = controller.socialPlatformOptions[index];
                final String key = platform['key'];
                final bool isSelected = controller.selectedPlatform.value == key;

                return GestureDetector(
                  onTap: () => controller.selectPlatform(key),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.deepPurple.withOpacity(0.1) : Colors.white,
                      border: Border.all(
                        color: isSelected ? Colors.deepPurple : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          platform['icon'],
                          size: 28,
                          color: isSelected ? Colors.deepPurple : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            platform['name'],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.black87 : Colors.grey.shade700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: Colors.deepPurple),
                      ],
                    ),
                  ),
                );
              },
            )),
          ),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: controller.nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Next",
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
