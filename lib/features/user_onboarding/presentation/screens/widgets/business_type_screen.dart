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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Business Type Selection",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tell us what makes your business unique.",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: controller.businessTypeSearchController,
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: (value) => controller.filterBusinessTypes(value),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Business Type Chips
            Obx(() {
              final types = controller.filteredBusinessTypes.isEmpty
                  ? controller.predefinedBusinessTypes
                  : controller.filteredBusinessTypes;
              
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ...types.map((type) {
                    final isSelected = controller.selectedBusinessType.value == type;
                    return GestureDetector(
                      onTap: () => controller.selectBusinessType(type),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.deepPurple.withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          type,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: isSelected ? Colors.deepPurple : Colors.black87,
                            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  
                  // Add Custom Button
                  GestureDetector(
                    onTap: () => _showAddCustomDialog(context),
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
                ],
              );
            }),
            
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

  void _showAddCustomDialog(BuildContext context) {
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
                "Add Custom Business Type",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  hintText: "Enter business type",
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
                          controller.addCustomBusinessType(textController.text.trim());
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
