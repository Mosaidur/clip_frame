import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'homeController.dart';

class HomePage extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());
  Shader linearGradient = const LinearGradient(
    colors: <Color>[Color(0xFF4983F6), Color(0xFFC175F5), Color(0xFFFBACB7)],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 50.0, 20.0));

  // Floating button widget
  Widget floatingButton(String label, IconData icon) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF277F), Color(0xFF007CFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),

        onPressed: () {
          // Show a snackbar instead of print for visible feedback
          Get.snackbar(
            label,
            '$label button clicked!',
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.black54,
            colorText: Colors.white,
          );
        },
      ),
    );
  }

  // Bottom nav item
  Widget navItem(IconData icon, int index, String label) {
    return Obx(() {
      bool selected = controller.selectedIndex.value == index;
      return GestureDetector(
        onTap: () {
          debugPrint('Nav item $label tapped, index: $index');
          controller.changePage(index);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? const Color(0xFF007CFE) : Colors.grey,
            ),
            Text(
              label,
              style: TextStyle(
                color: selected ? const Color(0xFF007CFE) : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Add this line
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Obx(() {
              debugPrint('Building page: ${controller.selectedIndex.value}');
              return controller.pages[controller.selectedIndex.value];
            }),
            AnimatedBuilder(
              animation: controller.controller,
              builder: (context, child) {
                double radius =50;
                double angleStep = 90;
                List<IconData> icons = [Icons.post_add, Icons.movie, Icons.history_edu];
                List<String> labels = ["Post", "Reels", "Story"];
        
                return Stack(
                  children: List.generate(icons.length, (index) {
                    double angle = (angleStep * index - 0) * (3.14159 / 180);
                    return Positioned(
                      bottom: 30 + controller.animation.value * radius * sin(angle),
                      left: Get.width / 2 - 30 + controller.animation.value * radius * cos(angle),
                      child: Opacity(
                        opacity: controller.animation.value,
                        child: Column(
                          children: [
                            floatingButton(labels[index], icons[index]),
                          ],
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Added margin for better look
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              navItem(Icons.dashboard, 0, "Dashboard"),
              navItem(Icons.note, 1, "Posts"),
              const SizedBox(width: 60), // Space for central FAB
              navItem(Icons.schedule, 2, "Schedules"),
              navItem(Icons.person, 3, "Profile"),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTap: () {
          debugPrint('FAB tapped, isExpanded: ${controller.isExpanded.value}');
          controller.toggleExpand();
        },
        child: Obx(() {
          return Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: controller.isExpanded.value
                  ? const LinearGradient(
                colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : const LinearGradient(
                colors: [Color(0xFFFF277F), Color(0xFF007CFE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
              ],
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: controller.isExpanded.value
                ? ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFFFF277F), Color(0xFF007CFE)
                ],
              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
              child: const Icon(
                Icons.add,
                size: 50,
                color: Colors.white, // this is fine with srcIn
              ),
            )
                : const Icon(
              Icons.add,
              size: 50,
              color: Colors.white,
            ),
          );
        })
      ),
    );
  }
}