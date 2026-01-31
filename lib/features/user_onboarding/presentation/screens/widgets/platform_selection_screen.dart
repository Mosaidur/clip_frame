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
      child: SingleChildScrollView(
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
              "Choose one or more social media platforms",
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
            
            // Platform Selection Icons
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: controller.socialPlatformOptions.map((platform) {
                final isSelected = controller.selectedPlatform.value == platform['key'];
                return GestureDetector(
                  onTap: () => controller.selectPlatform(platform['key']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 80,
                    height: 60,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? _getPlatformColor(platform['key']) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? _getPlatformColor(platform['key']) : Colors.grey.shade200,
                        width: 1,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: _getPlatformColor(platform['key']).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/${platform['key']}.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
            
            const SizedBox(height: 30),

            // Connect Form Section
            Obx(() {
              if (controller.selectedPlatform.value.isEmpty) {
                return const SizedBox();
              }
              
              final platformName = controller.socialPlatformOptions.firstWhere(
                (element) => element['key'] == controller.selectedPlatform.value
              )['name'];

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      "Connect $platformName",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Username/Email Field
                    TextField(
                      controller: controller.handleController,
                      decoration: InputDecoration(
                        hintText: "Enter your username or email",
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Password Field
                    TextField(
                      controller: controller.passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Continue Button (Pink)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          // Validate credentials here if needed
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF277F),
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
                  ],
                ),
              );
            }),

            const SizedBox(height: 30),
            
            // Bottom Continue Button (Blue)
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
            const SizedBox(height: 16),
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

  Color _getPlatformColor(String platform) {
    switch (platform) {
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'tiktok':
        return Colors.black;
      default:
        return const Color(0xFF1877F2);
    }
  }
}
