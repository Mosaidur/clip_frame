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
                          final key = platform.toLowerCase();
                          String? iconPath;
                          if (key.contains("facebook"))
                            iconPath = "assets/images/facebook.png";
                          else if (key.contains("instagram"))
                            iconPath = "assets/images/instagram.png";

                          if (iconPath == null) return const SizedBox.shrink();

                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Image.asset(
                              iconPath,
                              height: 20,
                              errorBuilder: (ctx, err, stack) => Icon(
                                key.contains('facebook')
                                    ? Icons.facebook
                                    : Icons.camera_alt,
                                size: 20,
                                color: _getPlatformColor(key),
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
                      final isConnected =
                          controller.userModel.value?.platforms.contains(key) ??
                          false;
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
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOutCubic,
                              width: 85,
                              height: 85,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                gradient: isFocused
                                    ? LinearGradient(
                                        colors: [
                                          _getPlatformColor(
                                            key,
                                          ).withOpacity(0.12),
                                          _getPlatformColor(
                                            key,
                                          ).withOpacity(0.02),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                border: Border.all(
                                  color: isFocused
                                      ? _getPlatformColor(key)
                                      : (isConnected
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
                                      ).withOpacity(0.15),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                      spreadRadius: 2,
                                    )
                                  else if (isConnected)
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                ],
                              ),
                              child: Center(
                                child: AnimatedScale(
                                  scale: isFocused ? 1.05 : 1.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Opacity(
                                    opacity: isConnected || isFocused
                                        ? 1.0
                                        : 0.4,
                                    child: Image.asset(
                                      'assets/images/$key.png',
                                      fit: BoxFit.contain,
                                      height: 36,
                                      errorBuilder: (ctx, err, stack) => Icon(
                                        key == 'facebook'
                                            ? Icons.facebook
                                            : Icons.camera_alt,
                                        size: 36,
                                        color: isConnected || isFocused
                                            ? _getPlatformColor(key)
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Connected Indicator (Visible only if account is linked)
                            if (isConnected)
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: _getPlatformColor(key),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getPlatformColor(
                                          key,
                                        ).withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
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
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F7FF),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFD0E7FF),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE0EFFF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.lightbulb_outline,
                                    size: 20,
                                    color: Color(0xFF007CFE),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    "Tip: If you want to switch accounts and it auto-suggests the old id, click 'Save Changes' after connecting and then try again.",
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.5,
                                      color: const Color(0xFF0056B3),
                                      fontWeight: FontWeight.w500,
                                      height: 1.5,
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
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: Colors.green.withOpacity(0.2),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.check_circle_rounded,
                                            size: 16,
                                            color: Colors.green,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Connected as ${key.capitalizeFirst}",
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.green[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 52,
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
                                            height: 22,
                                            errorBuilder: (ctx, err, stack) =>
                                                Icon(
                                                  key == 'facebook'
                                                      ? Icons.facebook
                                                      : (key == 'instagram'
                                                            ? Icons.camera_alt
                                                            : Icons.music_note),
                                                  size: 22,
                                                  color: _getPlatformColor(key),
                                                ),
                                          ),
                                          label: Text(
                                            isAlreadyConnected
                                                ? "Reconnect"
                                                : "Connect",
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: _getPlatformColor(key),
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            side: BorderSide(
                                              color: _getPlatformColor(
                                                key,
                                              ).withOpacity(0.5),
                                              width: 2,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            backgroundColor: isAlreadyConnected
                                                ? _getPlatformColor(
                                                    key,
                                                  ).withOpacity(0.02)
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (isAlreadyConnected) ...[
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: SizedBox(
                                          height: 52,
                                          child: ElevatedButton(
                                            onPressed:
                                                controller.isUpdating.value
                                                ? null
                                                : () => controller
                                                      .disconnectPlatform(key),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFFFF277F,
                                              ).withOpacity(0.1),
                                              foregroundColor: const Color(
                                                0xFFFF277F,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                side: const BorderSide(
                                                  color: Color(0xFFFF277F),
                                                  width: 1.5,
                                                ),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: Text(
                                              "Disconnect",
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
              height: 54,
              child: Obx(
                () => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      if (!controller.isUpdating.value)
                        BoxShadow(
                          color: const Color(0xFF007CFE).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                    ],
                    gradient: controller.isUpdating.value
                        ? null
                        : const LinearGradient(
                            colors: [Color(0xFF007CFE), Color(0xFF0056B3)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                  ),
                  child: ElevatedButton(
                    onPressed: controller.isUpdating.value
                        ? null
                        : () async {
                            // Extract currently connected platforms from user model
                            // to ensure only truly connected platforms are saved
                            final connectedPlatforms = controller
                                .socialPlatformOptions
                                .where(
                                  (opt) =>
                                      controller.userModel.value?.platforms
                                          .contains(opt['key']) ??
                                      false,
                                )
                                .map((opt) => opt['key'] as String)
                                .toList();

                            await controller.updatePlatforms(
                              connectedPlatforms,
                            );
                            Get.back();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: controller.isUpdating.value
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Save Changes",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
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
    if (platform.contains('facebook')) return const Color(0xFF1877F2);
    if (platform.contains('instagram')) return const Color(0xFFE4405F);
    return const Color(0xFF1877F2);
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
