import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'homeController.dart';

class HomePage extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());
  
  // Floating button widget
  Widget floatingButton(String label, IconData icon) {
    return Container(
      width: 60.r,
      height: 60.r,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF277F), Color(0xFF007CFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8.r, offset: Offset(0, 4.h)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 24.r),
        onPressed: () {
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
              size: 24.r,
            ),
            Text(
              label,
              style: TextStyle(
                color: selected ? const Color(0xFF007CFE) : Colors.grey,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Obx(() {
              debugPrint('Building page: ${controller.selectedIndex.value}');
              return controller.pages[controller.selectedIndex.value];
            }),
            AnimatedBuilder(
              animation: controller.controller,
              builder: (context, child) {
                double radius = 70.h;
                double angleStep = 90;
                List<IconData> icons = [Icons.post_add, Icons.movie, Icons.history_edu];
                List<String> labels = ["Post", "Reels", "Story"];

                return Stack(
                  children: List.generate(icons.length, (index) {
                    double angle = (angleStep * index - 0) * (3.14159 / 180);
                    return Positioned(
                      bottom: 40.h + controller.animation.value * radius * sin(angle),
                      left: 0.5.sw - 30.r + controller.animation.value * radius * cos(angle),
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
        bottomNavigationBar: Container(
          height: 75.h,
          margin: EdgeInsets.only(bottom: 15.h, left: 15.w, right: 15.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25.r),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10.r, spreadRadius: 2.r)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              navItem(Icons.dashboard, 0, "Dashboard"),
              navItem(Icons.note, 1, "Posts"),
              SizedBox(width: 50.w), // Space for central FAB
              navItem(Icons.schedule, 2, "Schedules"),
              navItem(Icons.person, 3, "Profile"),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: EdgeInsets.only(top: 25.h),
          child: GestureDetector(
            onTap: () {
              debugPrint('FAB tapped, isExpanded: ${controller.isExpanded.value}');
              controller.toggleExpand();
            },
            child: Obx(() {
              return Container(
                width: 65.r,
                height: 65.r,
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
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 10.r, offset: Offset(0, 4.h)),
                  ],
                  border: Border.all(color: Colors.white, width: 2.w),
                ),
                child: controller.isExpanded.value
                    ? ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFFF277F), Color(0xFF007CFE)],
                        ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                        child: Icon(
                          Icons.add,
                          size: 40.r,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        Icons.add,
                        size: 40.r,
                        color: Colors.white,
                      ),
              );
            }),
          ),
        ),
      ),
    );
  }
}