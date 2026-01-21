import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/AboutMeWidget.dart';
import '../widgets/MyCreationsWidget.dart';

class MyProfileController extends GetxController {
  var selectedTab = 0.obs; // 0 = About Me, 1 = My Creations
}

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyProfileController());
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _roundIcon(Icons.settings, () {}),
                    const Text(
                      "Profile",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    _roundIcon(Icons.edit, () {}),
                  ],
                ),
              ),

              // Profile Section
              Column(
                children: [
                  Container(
                    height: 130,
                    width: 130,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: Image.network(
                        "https://example.com/profile.jpg",
                        height: 125,
                        width: 125,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            "assets/images/profile_image.png",
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Aimal Naseem",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  const Text(
                    "aimalnaseem@gmail.com",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),

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
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF277F), Color(0xFF007CFE)],
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => controller.selectedTab.value = 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: controller.selectedTab.value == 0
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(60),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "About me",
                                      style: TextStyle(
                                        color: controller.selectedTab.value == 0
                                            ? Colors.black
                                            : Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => controller.selectedTab.value = 1,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: controller.selectedTab.value == 1
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(60),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "My Creations",
                                      style: TextStyle(
                                        color: controller.selectedTab.value == 1
                                            ? Colors.black
                                            : Colors.white,
                                        fontWeight: FontWeight.w600,
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
            ],
          ),
        ),
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