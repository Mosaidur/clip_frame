import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:clip_frame/shared/routes/routes.dart';
import 'package:clip_frame/core/model/user_model.dart';
import 'package:clip_frame/features/my_profile/presenatation/screen/MyProfileController.dart';

class AboutMeWidget extends StatelessWidget {
  const AboutMeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final MyProfileController controller = Get.find<MyProfileController>();

    return Obx(() {
      final user = controller.userModel.value;
      if (user == null || controller.isLoading.value) {
        return _buildShimmer();
      }
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFFEFAF6), // Light beige from mockup
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMockupRow(
              "Membership".tr,
              user.membership.tr,
              valueColor: const Color(0xFFFF277F),
            ),
            _buildDivider(),
            _buildMockupRow("Business Name".tr, user.businessName ?? "N/A".tr),
            _buildDivider(),
            _buildMockupRow(
              "Description".tr,
              user.businessDescription ?? "No description provided.".tr,
              isMultiline: true,
            ),
            _buildDivider(),
            _buildMockupRow(
              "Business Category".tr,
              user.businessCategory ?? "N/A".tr,
              hasArrow: true,
            ),
            _buildDivider(),
            // Individual Platform Connection Rows
            _buildPlatformConnectionRow(
              "Facebook".tr,
              "assets/images/facebook.png",
              user.platforms.contains("facebook"),
              onTap: () {
                if (user.platforms.contains("facebook")) {
                  controller.disconnectPlatform("facebook");
                } else {
                  controller.connectFacebook();
                }
              },
            ),
            _buildDivider(),
            _buildPlatformConnectionRow(
              "Instagram".tr,
              "assets/images/instagram.png",
              user.platforms.contains("instagram"),
              onTap: () {
                if (user.platforms.contains("instagram")) {
                  controller.disconnectPlatform("instagram");
                } else {
                  controller.connectInstagram();
                }
              },
            ),
            _buildDivider(),
            _buildMockupRow(
              "Preferred Language".tr,
              user.preferredLanguages.isNotEmpty
                  ? user.preferredLanguages.first.tr
                  : "English".tr,
              hasArrow: true,
            ),
            _buildDivider(),
            _buildMockupRow("Timezone".tr, user.timezone.tr, hasArrow: true),
            _buildDivider(),
            _buildMockupRow(
              "Password".tr,
              "Change Password".tr,
              valueColor: const Color(0xFF007CFE),
              onTap: () => Get.toNamed(AppRoutes.forgotPassword),
            ),
            const SizedBox(height: 40),
            Center(
              child: TextButton(
                onPressed: () => controller.logout(),
                child: Text(
                  "LOG OUT".tr,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFFF277F),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMockupRow(
    String label,
    String value, {
    Color? valueColor,
    bool hasArrow = false,
    bool isMultiline = false,
    VoidCallback? onTap,
  }) {
    if (isMultiline) {
      return InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                textAlign: TextAlign.justify,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: valueColor ?? Colors.black.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      value,
                      textAlign: TextAlign.end,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: valueColor ?? Colors.black.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasArrow) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: Colors.black54,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformConnectionRow(
    String label,
    String asset,
    bool isConnected, {
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                asset,
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.link, size: 24, color: Colors.grey[400]),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isConnected
                    ? Colors.green.withOpacity(0.1)
                    : const Color(0xFFFF277F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isConnected ? "Connected" : "Connect",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isConnected ? Colors.green : const Color(0xFFFF277F),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.black.withOpacity(0.05), height: 1);
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          children: List.generate(
            6,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 100, height: 16, color: Colors.white),
                  Container(width: 80, height: 16, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
