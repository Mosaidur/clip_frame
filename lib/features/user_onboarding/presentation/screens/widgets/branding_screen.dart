import 'package:clip_frame/Shared/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../controllers/user_onboarding_page_controller.dart';

class BrandingScreen extends GetView<UserOnboardingPageController> {
  const BrandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Business Branding and logo",
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
            
            // Add Colours Section
            Text(
              "Add Colours",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            // Primary Colour
            _buildColorPicker(
              label: "Primary Colour",
              color: controller.primaryColor,
              onTap: () => _showColorPicker(context, true),
            ),
            
            const SizedBox(height: 16),
            
            // Secondary Colour
            _buildColorPicker(
              label: "Secondary Colour",
              color: controller.secondaryColor,
              onTap: () => _showColorPicker(context, false),
            ),
            
            const SizedBox(height: 20),
            
            // Add Colour Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Could add more colors if needed
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF277F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "+ Add colour",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Add Logo Section
            Text(
              "Add Logo",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            // Logo Upload Area
            Obx(() => GestureDetector(
              onTap: controller.pickLogo,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: controller.logoPath.value.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 50,
                            color: const Color(0xFFFF277F),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Upload Logo",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "(PNG, JPG, SVG, PDF)",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          controller.logoFile!,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            )),
            
            const SizedBox(height: 40),
            
            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  controller.submitOnboarding();
                  // No immediate dialog here, let controller handle success/fail or 
                  // show dialog after success? The user wants login page.
                  // Let's show the success dialog and THEN go to login.
                  _showCompleteProfileDialog(context);
                },
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
                onPressed: () {
                  controller.submitOnboarding();
                  _showCompleteProfileDialog(context);
                },
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

  Widget _buildColorPicker({
    required String label,
    required Rx<Color> color,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Obx(() => Text(
            "#${color.value.value.toRadixString(16).substring(2).toUpperCase()}",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          )),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onTap,
            child: Obx(() => Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.value,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(
                Icons.edit,
                size: 16,
                color: Colors.white,
              ),
            )),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context, bool isPrimary) {
    Color pickerColor = isPrimary 
        ? controller.primaryColor.value 
        : controller.secondaryColor.value;
    
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
                "Pick ${isPrimary ? 'Primary' : 'Secondary'} Color",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: (color) {
                  pickerColor = color;
                },
                pickerAreaHeightPercent: 0.8,
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
                        if (isPrimary) {
                          controller.primaryColor.value = pickerColor;
                        } else {
                          controller.secondaryColor.value = pickerColor;
                        }
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF277F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Select",
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

  void _showCompleteProfileDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF277F),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Complete Profile",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Your can complete your profile anytime later from your app settings screen.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    // Navigate to Login instead of Home
                    Get.offAllNamed(AppRoutes.login);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1877F2),
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
        ),
      ),
      barrierDismissible: false,
    );
  }
}
