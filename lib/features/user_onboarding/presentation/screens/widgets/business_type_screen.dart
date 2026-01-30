import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/user_onboarding_page_controller.dart';

class BusinessTypeScreen extends GetView<UserOnboardingPageController> {
  const BusinessTypeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What type of business do you run?",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Select the specialized area that best describes your business.",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 30),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: controller.businessTypes.map((type) {
                      final isSelected = controller.selectedBusinessType.value == type;
                      return ChoiceChip(
                        label: Text(type),
                        labelStyle: GoogleFonts.poppins(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        selected: isSelected,
                        selectedColor: Colors.deepPurple,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? Colors.transparent : Colors.grey.shade300,
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            controller.selectedBusinessType.value = type;
                            controller.customBusinessTypeController.clear();
                          }
                        },
                      );
                    }).toList(),
                  )),
                  
                  const SizedBox(height: 30),
                  Text(
                    "Or enter your own:",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: controller.customBusinessTypeController,
                    decoration: InputDecoration(
                      hintText: "E.g., Vintage bookstore...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onChanged: (val) {
                      if (val.isNotEmpty) {
                        controller.selectedBusinessType.value = '';
                      }
                    },
                  ),
                ],
              ),
            ),
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
