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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Target Audience & Language",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          
          Text(
            "Who are you trying to reach?",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Obx(() => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: controller.audienceOptions.map((audience) {
              final isSelected = controller.selectedAudiences.contains(audience);
              return ChoiceChip(
                label: Text(audience),
                labelStyle: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
                selected: isSelected,
                selectedColor: Colors.deepPurple,
                backgroundColor: Colors.white,
                onSelected: (_) => controller.toggleAudience(audience),
              );
            }).toList(),
          )),
          
          const SizedBox(height: 30),
          
          Text(
            "Preferred Content Language",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Obx(() => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: controller.languageOptions.map((language) {
              final isSelected = controller.selectedLanguage.value == language;
              return ChoiceChip(
                label: Text(language),
                labelStyle: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
                selected: isSelected,
                selectedColor: Colors.deepPurple,
                backgroundColor: Colors.white,
                onSelected: (selected) {
                  if (selected) controller.selectLanguage(language);
                },
              );
            }).toList(),
          )),
          
          const SizedBox(height: 30),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Auto-translate captions?",
                    style: GoogleFonts.poppins(fontSize: 15),
                  ),
                ),
                Obx(() => Switch(
                  value: controller.autoTranslateCaptions.value,
                  onChanged: (val) => controller.autoTranslateCaptions.value = val,
                  activeColor: Colors.deepPurple,
                )),
              ],
            ),
          ),

          const Spacer(),

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
