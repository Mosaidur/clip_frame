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
            _infoRow(
              "Membership",
              user.membership.isNotEmpty ? user.membership : "N/A",
              valueColor: const Color(0xFFFF277F),
            ),
            _infoRow(
              "Business Name",
              user.businessType.isNotEmpty ? user.businessType : "N/A",
            ),
            _dropdownRow(
              "Business Category",
              user.businessType.isNotEmpty ? user.businessType : "General",
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: InkWell(
                onTap: () => _showPlatformSelectionSheet(context, controller),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Platforms",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Row(
                      children: [
                        ...user.platforms.map((platform) {
                          String iconPath =
                              "assets/images/facebook.png"; // Default
                          if (platform.toLowerCase().contains("instagram")) {
                            iconPath = "assets/images/instagram.png";
                          }
                          if (platform.toLowerCase().contains("tiktok")) {
                            iconPath = "assets/images/tiktok.png";
                          }
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Image.asset(
                              iconPath,
                              height: 22,
                              errorBuilder: (ctx, err, stack) => const Icon(
                                Icons.public,
                                size: 22,
                                color: Colors.blue,
                              ),
                            ),
                          );
                        }).toList(),
                        const Icon(Icons.arrow_right, color: Colors.black54),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            _dropdownRow(
              "Preferred Language",
              user.preferredLanguages.isNotEmpty
                  ? user.preferredLanguages.first
                  : "English",
            ),
            _dropdownRow(
              "Timezone",
              user.timezone.isNotEmpty ? user.timezone : "UTC",
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Password",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      "Change Password",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF007CFE),
                      ),
                    ),
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
                    color: const Color(0xFFFF277F),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }

  void _showPlatformSelectionSheet(
    BuildContext context,
    MyProfileController controller,
  ) {
    // Initialize temporary list with current platforms
    controller.tempSelectedPlatforms.assignAll(
      controller.userModel.value?.platforms ?? [],
    );

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Select Platforms",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Choose the platforms where you want to publish.",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Obx(
              () => Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: controller.socialPlatformOptions.map((platform) {
                      final key = platform['key'] as String;
                      final isSelected = controller.tempSelectedPlatforms
                          .contains(key);
                      final isFocused =
                          controller.selectedPlatformIndex.value ==
                          controller.socialPlatformOptions.indexOf(platform);
                      return GestureDetector(
                        onTap: () {
                          controller.selectedPlatformIndex.value = controller
                              .socialPlatformOptions
                              .indexOf(platform);
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 80,
                              height: 80,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                gradient: isFocused
                                    ? LinearGradient(
                                        colors: [
                                          _getPlatformColor(
                                            key,
                                          ).withOpacity(0.1),
                                          Colors.white,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                border: Border.all(
                                  color: isFocused
                                      ? _getPlatformColor(key)
                                      : (isSelected
                                            ? _getPlatformColor(
                                                key,
                                              ).withOpacity(0.4)
                                            : Colors.grey.shade200),
                                  width: isFocused ? 2.5 : 1.5,
                                ),
                                boxShadow: [
                                  if (isFocused)
                                    BoxShadow(
                                      color: _getPlatformColor(
                                        key,
                                      ).withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                      spreadRadius: 1,
                                    )
                                  else if (isSelected)
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                ],
                              ),
                              child: Center(
                                child: Opacity(
                                  opacity: isSelected ? 1.0 : 0.4,
                                  child: Image.asset(
                                    'assets/images/$key.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            // Selection Indicator (Checkmark)
                            Positioned(
                              top: -6,
                              right: -6,
                              child: GestureDetector(
                                onTap: () {
                                  if (isSelected) {
                                    controller.tempSelectedPlatforms.remove(
                                      key,
                                    );
                                  } else {
                                    controller.tempSelectedPlatforms.add(key);
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? _getPlatformColor(key)
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.transparent
                                          : Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: _getPlatformColor(
                                                key,
                                              ).withOpacity(0.3),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    size: 14,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  // --- Focused Platform Connection Buttons ---
                  const SizedBox(height: 32),
                  if (controller.socialPlatformOptions[controller
                              .selectedPlatformIndex
                              .value]['key'] ==
                          'facebook' ||
                      controller.socialPlatformOptions[controller
                              .selectedPlatformIndex
                              .value]['key'] ==
                          'instagram')
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F7FF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFD0E7FF),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.lightbulb_outline,
                                  size: 20,
                                  color: Color(0xFF007CFE),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Tip: If you want to switch accounts and it auto-suggests the old id, click 'Switch ID' and then logout from the browser window that appears.",
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: const Color(0xFF0056B3),
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            final focusedPlatform =
                                controller.socialPlatformOptions[controller
                                    .selectedPlatformIndex
                                    .value];
                            final key = focusedPlatform['key'] as String;
                            final isAlreadyConnected =
                                controller.userModel.value?.platforms.contains(
                                  key,
                                ) ??
                                false;

                            return Column(
                              children: [
                                if (isAlreadyConnected)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "Connected as ${key.capitalizeFirst}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ),
                                  ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 50,
                                        child: OutlinedButton.icon(
                                          onPressed: controller.isUpdating.value
                                              ? null
                                              : () => (key == 'facebook'
                                                    ? controller
                                                          .connectFacebook()
                                                    : controller
                                                          .connectInstagram()),
                                          icon: Image.asset(
                                            'assets/images/$key.png',
                                            height: 20,
                                          ),
                                          label: Text(
                                            isAlreadyConnected
                                                ? "Reconnect"
                                                : "Connect",
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: _getPlatformColor(key),
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                              color: _getPlatformColor(key),
                                              width: 1.5,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: SizedBox(
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed: controller.isUpdating.value
                                              ? null
                                              : () => (key == 'facebook'
                                                    ? controller
                                                          .connectFacebook(
                                                            switchAccount: true,
                                                          )
                                                    : controller
                                                          .connectInstagram(
                                                            switchAccount: true,
                                                          )),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF333333,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: Text(
                                            "Switch ID",
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isUpdating.value
                      ? null
                      : () async {
                          await controller.updatePlatforms(
                            controller.tempSelectedPlatforms,
                          );
                          Get.back();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007CFE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isUpdating.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Save Changes",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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

  Widget _infoRow(
    String title,
    String value, {
    Color valueColor = Colors.black,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
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
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
            items: [value]
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) {},
          ),
        ],
      ),
    );
  }
}
