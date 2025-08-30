import 'package:clip_frame/signUp%20screen/presenatation/widgets/selectedItem.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Controller for managing audience, languages, and auto-translate
class AudienceAndLanguageController extends GetxController {
  // Predefined lists
  final List<String> audienceList = [
    "General Audience",
    "Students",
    "Professionals",
    "Entrepreneurs",
    "Content Creators"
  ];
  final List<String> languageList = [
    "English",
    "Bangla",
    "Hindi",
    "Spanish",
    "French"
  ];

  // Selected values
  var selectedAudience = "".obs;
  var selectedLanguages = <String>[].obs;
  var autoTranslate = false.obs;

  void addLanguage(String lang) {
    if (!selectedLanguages.contains(lang)) selectedLanguages.add(lang);
  }

  void toggleAutoTranslate() {
    autoTranslate.value = !autoTranslate.value;
  }

  void setTargetAudience(String audience) {
    selectedAudience.value = audience;
  }

  void toggleLanguageSelection(String lang) {
    if (selectedLanguages.contains(lang)) {
      selectedLanguages.remove(lang);
    } else {
      selectedLanguages.add(lang);
    }
  }
}

class AudienceAndLanguagePage extends StatelessWidget {
  final AudienceAndLanguageController controller =
  Get.put(AudienceAndLanguageController());
  final TextEditingController customLanguageController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Audience & Language Preferences",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text(
            "We’ll tailor content ideas based on this.",
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
          const SizedBox(height: 20),

          // Target Audience Section

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white.withOpacity(0.4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Target Audience
                  const Text("Target Audience", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Obx(() => Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: controller.audienceList
                        .map((aud) => SelectableItem(
                      text: aud,
                      isSelected: controller.selectedAudience.value == aud,
                      onTap: () => controller.setTargetAudience(aud),
                    ))
                        .toList(),
                  )),

                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white.withOpacity(0.4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Content Languages
                  const Text("Content Languages", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Obx(() => Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: controller.languageList
                        .map((lang) => SelectableItem(
                      text: lang,
                      isSelected: controller.selectedLanguages.contains(lang),
                      onTap: () => controller.toggleLanguageSelection(lang),
                    ))
                        .toList(),
                  )),
                  const SizedBox(height: 10),

                  // Add custom language
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: customLanguageController,
                          decoration: InputDecoration(
                            hintText: "Add Language",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Colors.grey.shade200,
                            filled: true,
                            contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          final newLang = customLanguageController.text.trim();
                          if (newLang.isNotEmpty) {
                            controller.addLanguage(newLang);
                            customLanguageController.clear();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                        child: const Text("+ Add", style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Auto Translate Captions Toggle
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white.withOpacity(0.4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Auto Translate Captions",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Switch(
                    value: controller.autoTranslate.value,
                    onChanged: (_) => controller.toggleAutoTranslate(),
                    activeColor: Colors.pink,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey.shade300,
                  ),
                ],
              )),
            ),
          ),
        ],
      ),
    );
  }
}
