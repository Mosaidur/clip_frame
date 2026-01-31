import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/user_onboarding_page_controller.dart';

class BusinessDescriptionScreen extends GetView<UserOnboardingPageController> {
  const BusinessDescriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Business Description",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Describe your business in one sentence",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            
            // Text Area with Character Counter
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: controller.businessDescriptionController,
                    maxLines: 5,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: "Tell us what makes your business unique.",
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                      counterText: '', // Hide default counter
                    ),
                    onChanged: (value) => controller.updateDescriptionCount(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16, bottom: 12),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Obx(() => Text(
                        "${controller.descriptionCharCount.value}/500",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      )),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Suggestions Section
            Text(
              "Suggestions:",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            
            // Suggestions list - removed Expanded to fit in scrollable view
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: controller.descriptionSuggestions.map((suggestion) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    "• $suggestion",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1877F2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
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
            
            const SizedBox(height: 12),
            
            // Skip Button
            Center(
              child: TextButton(
                onPressed: controller.nextPage,
                child: Text(
                  "SKIP",
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
