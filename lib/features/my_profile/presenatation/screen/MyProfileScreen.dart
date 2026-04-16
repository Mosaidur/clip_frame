import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:clip_frame/features/my_profile/presenatation/screen/EditProfileScreen.dart';
import 'package:clip_frame/features/my_profile/presenatation/widgets/AboutMeWidget.dart';
import 'package:clip_frame/features/my_profile/presenatation/widgets/MyCreationsWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:clip_frame/splashScreen/controllers/language_controller.dart';
import 'package:clip_frame/Shared/widgets/language_toggle_button.dart';
import 'package:clip_frame/features/my_profile/presenatation/screen/MyProfileController.dart';

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyProfileController>();
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF3E7E9), // Light peach/pink
            Color(0xFFE3EEFF), // Light blue/purple
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.getUserProfile();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Top Row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() {
                        final langController = Get.find<LanguageController>();
                        return LanguageToggleButton(
                          currentLanguage: langController.locale.value.languageCode == 'es' ? 'Es' : 'En',
                          onLanguageChanged: (lang) {
                            langController.changeLocale(
                              lang == 'Es' ? const Locale('es', 'ES') : const Locale('en', 'US'),
                            );
                            // Also update the backend preferred language implicitly if needed, or stick to app-wide change
                          },
                        );
                      }),
                      Text(
                        "profile".tr,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ),
                      _roundIcon(Icons.edit, () {
                        Get.to(() => const EditProfileScreen());
                      }),
                    ],
                  ),
                ),

                // Profile Section
                Obx(() {
                  if (controller.isLoading.value) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (controller.errorMessage.value.isNotEmpty) {
                    return Container(
                      height: 200,
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              controller.errorMessage.value,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: controller.getUserProfile,
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return Obx(() {
                    final user = controller.userModel.value;
                    if (user == null || controller.isLoading.value) {
                      return _buildHeaderShimmer();
                    }
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            if (controller.isUpdating.value) return;
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (image != null) {
                              controller.selectedImage.value = File(image.path);
                              await controller.updateProfile(
                                name: user.name,
                                phone: user.phone,
                              );
                            }
                          },
                          child: Stack(
                            children: [
                              Container(
                                height: 140,
                                width: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: ClipOval(
                                      child:
                                          controller.selectedImage.value != null
                                          ? Image.file(
                                              controller.selectedImage.value!,
                                              fit: BoxFit.cover,
                                            )
                                          : (user.image != null &&
                                                user.image!.isNotEmpty)
                                          ? Image.network(
                                              user.image!,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Container(
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                      Icons.person,
                                                      size: 80,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                            )
                                          : Container(
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.person,
                                                size: 80,
                                                color: Colors.grey,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  // Keep existing camera icon but position per mockup if needed
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.name,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          user.email,
                          style: GoogleFonts.poppins(
                            color: Colors.black54,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    );
                  });
                }),

                const SizedBox(height: 20),

                // Tabs + Content
                Container(
                  width: width,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // Tabs
                      Obx(() {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white.withOpacity(0.5),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => controller.selectedTab.value = 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient:
                                          controller.selectedTab.value == 0
                                          ? const LinearGradient(
                                              colors: [
                                                Color(0xFFFF277F),
                                                Color(0xFF2870F3),
                                              ],
                                            )
                                          : null,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "about_me".tr,
                                        style: GoogleFonts.poppins(
                                          color:
                                              controller.selectedTab.value == 0
                                              ? Colors.white
                                              : Colors.black38,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    controller.selectedTab.value = 1;
                                    controller.fetchMyCreations();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient:
                                          controller.selectedTab.value == 1
                                          ? const LinearGradient(
                                              colors: [
                                                Color(0xFFFF277F),
                                                Color(0xFF2870F3),
                                              ],
                                            )
                                          : null,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "my_creations".tr,
                                        style: GoogleFonts.poppins(
                                          color:
                                              controller.selectedTab.value == 1
                                              ? Colors.white
                                              : Colors.black38,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 20),

                      // Tab Content
                      Obx(() {
                        return controller.selectedTab.value == 0
                            ? const AboutMeWidget()
                            : const MyCreationsWidget();
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(
            height: 140,
            width: 140,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 24, width: 150, color: Colors.white),
          const SizedBox(height: 8),
          Container(height: 16, width: 200, color: Colors.white),
        ],
      ),
    );
  }

  Widget _roundIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.1),
        ),
        child: Icon(icon, color: Colors.black),
      ),
    );
  }
}
