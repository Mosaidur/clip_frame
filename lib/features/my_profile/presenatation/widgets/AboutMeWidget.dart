import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screen/MyProfileController.dart';

class AboutMeWidget extends StatelessWidget {
  const AboutMeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final MyProfileController controller = Get.find<MyProfileController>();

    return Obx(() {
      final user = controller.userModel.value;
      if (user == null) {
        return const Center(child: Text("No user data available"));
      }
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0x33F4DEC0),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          children: [
            _infoRow("Membership", user.membership.isNotEmpty ? user.membership : "N/A", valueColor: const Color(0xFFFF277F)),
            _infoRow("Business Name", user.businessType.isNotEmpty ? user.businessType : "N/A"),
            _dropdownRow("Business Category", user.businessType.isNotEmpty ? user.businessType : "General"),
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text("Platforms",
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
                  Row(
                    children: user.platforms.map((platform) {
                      String iconPath = "assets/images/facebook.png"; // Default
                      if (platform.toLowerCase().contains("instagram")) iconPath = "assets/images/instagram.png";
                      if (platform.toLowerCase().contains("tiktok")) iconPath = "assets/images/tiktok.png";
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Image.asset(iconPath, height: 22, errorBuilder: (ctx, err, stack) => const Icon(Icons.public, size: 22, color: Colors.blue)),
                      );
                    }).toList(),
                  )
                ],
              ),
            ),
            
            _dropdownRow("Preferred Language", user.preferredLanguages.isNotEmpty ? user.preferredLanguages.first : "English"),
            _dropdownRow("Timezone", user.timezone.isNotEmpty ? user.timezone : "UTC"),
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Password",
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
                  GestureDetector(
                    onTap: () {},
                    child: Text("Change Password",
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF007CFE))),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                // TODO: Implement Logout logic (AuthService.clearData + Navigate to Welcome)
                Get.find<MyProfileController>().logout();
              },
              child: Center(
                child: Text(
                  "LOG OUT",
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: const Color(0xFFFF277F)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }

  Widget _infoRow(String title, String value, {Color valueColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(title,
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(value,
                textAlign: TextAlign.right,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor)),
          ),
        ],
      ),
    );
  }

  Widget _dropdownRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(title,
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
          ),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
            items: [value]
                .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e,
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87))))
                .toList(),
            onChanged: (val) {},
          )
        ],
      ),
    );
  }
}