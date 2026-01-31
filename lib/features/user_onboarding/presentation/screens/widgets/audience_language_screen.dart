import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/user_onboarding_page_controller.dart';

class AudienceLanguageScreen extends GetView<UserOnboardingPageController> {
  const AudienceLanguageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Audience & Language Preferences",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "We'll tailor content ideas based on this.",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 30),
            
            // Target Audience Section
            Text(
              "Target Audience:",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            
            Obx(() => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: controller.audienceOptions.map((audience) {
                final isSelected = controller.selectedAudiences.contains(audience);
                return GestureDetector(
                  onTap: () => controller.toggleAudience(audience),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFF277F).withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFFF277F) : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      audience,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isSelected ? const Color(0xFFFF277F) : Colors.black87,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
            
            const SizedBox(height: 30),
            
            // Content Language Section
            Text(
              "Content Language:",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            
            Obx(() => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: controller.languageOptions.map((language) {
                final isSelected = controller.selectedLanguage.value == language;
                return GestureDetector(
                  onTap: () => controller.selectLanguage(language),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF007CFE).withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF007CFE) : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      language,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isSelected ? const Color(0xFF007CFE) : Colors.black87,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
            
            const SizedBox(height: 16),
            
            // Add Language Button
            GestureDetector(
              onTap: () => _showAddLanguageDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF277F),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, color: Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      "Add",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Auto-translate Toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "AutoTranslate Captions:",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Obx(() => Switch(
                    value: controller.autoTranslateCaptions.value,
                    onChanged: (val) => controller.autoTranslateCaptions.value = val,
                    activeColor: const Color(0xFFFF277F),
                  )),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
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

  void _showAddLanguageDialog(BuildContext context) {
    final textController = TextEditingController();
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Add Language",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  hintText: "Enter language",
                  hintStyle: GoogleFonts.poppins(fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (textController.text.trim().isNotEmpty) {
                          Get.find<UserOnboardingPageController>()
                              .addCustomLanguage(textController.text.trim());
                          Get.back();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF277F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Add",
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
