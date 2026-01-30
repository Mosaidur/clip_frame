import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
            // _infoRow("Description", "About some things"), // Description not in model yet
            _dropdownRow("Business Category", user.businessType.isNotEmpty ? user.businessType : "General"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Platforms",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                Row(
                  children: user.platforms.map((platform) {
                    String iconPath = "assets/images/facebook.png"; // Default
                    if (platform.toLowerCase().contains("instagram")) iconPath = "assets/images/instagram.png";
                    if (platform.toLowerCase().contains("tiktok")) iconPath = "assets/images/tiktok.png";
                     // Add more mappings as needed
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Image.asset(iconPath, height: 20, errorBuilder: (ctx, err, stack) => const Icon(Icons.public, size: 20)),
                    );
                  }).toList(),
                )
              ],
            ),
            const SizedBox(height: 12),
            _dropdownRow("Preferred Language", user.preferredLanguages.isNotEmpty ? user.preferredLanguages.first : "English"),
            _dropdownRow("Timezone", user.timezone.isNotEmpty ? user.timezone : "UTC"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Password",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                GestureDetector(
                  onTap: () {},
                  child: const Text("Change Password",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF007CFE))),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "LOG OUT",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF277F)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
    });
  }

  Widget _infoRow(String title, String value, {Color valueColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor)),
        ],
      ),
    );
  }

  Widget _dropdownRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            items: [value].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
            onChanged: (val) {},
          )
        ],
      ),
    );
  }
}