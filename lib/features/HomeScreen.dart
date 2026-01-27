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
      Color activeColor = const Color(0xFF007CFE);
      Color inactiveColor = const Color(0xFFC4C4C4);
      
      return GestureDetector(
        onTap: () {
          debugPrint('Nav item $label tapped, index: $index');
          controller.changePage(index);
        },
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected ? activeColor : inactiveColor,
                size: 26.r,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  color: selected ? activeColor : inactiveColor,
                  fontSize: 11.sp,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB49EF4), Color(0xFFEBC894)],
        ),
      ),
      child: Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
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
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              PhysicalShape(
                color: Colors.white,
                elevation: 15,
                clipper: CustomNotchClipper(),
                child: Container(
                  height: 70.h,
                  padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            navItem(Icons.grid_view_rounded, 0, "Dashboard"),
                            navItem(Icons.video_library_rounded, 1, "Posts"),
                          ],
                        ),
                      ),
                      SizedBox(width: 80.w), // Space for FAB
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            navItem(Icons.access_time_filled_rounded, 2, "Schedules"),
                            navItem(Icons.person_rounded, 3, "Profile"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: EdgeInsets.only(top: 5.h),
          child: GestureDetector(
            onTap: () {
              debugPrint('FAB tapped, isExpanded: ${controller.isExpanded.value}');
              controller.toggleExpand();
            },
            child: Obx(() {
              return Container(
                width: 70.r,
                height: 70.r,
                decoration: BoxDecoration(
                  gradient: controller.isExpanded.value
                      ? const LinearGradient(
                          colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [Color(0xFFE4405F), Color(0xFF6A5AEF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  shape: BoxShape.circle,
                  // boxShadow: [
                  //   BoxShadow(color: Colors.black12, blurRadius: 15.r, offset: Offset(0, 8.h)),
                  // ],
                  // border: Border.all(color: Colors.white, width: 4.w),
                ),
                child: controller.isExpanded.value
                    ? ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFE4405F), Color(0xFF6A5AEF)],
                        ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                        child: Icon(
                          Icons.add,
                          size: 35.r,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        Icons.add,
                        size: 35.r,
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

class CustomNotchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double notchWidth = 100.w; // Slightly wider for a smoother feel
    double notchHeight = 40.h;
    double centerX = size.width / 2;
    double cornerRadius = 20.r;

    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    // Line to notch start
    path.lineTo(centerX - notchWidth / 2 - 20.w, 0);

    // Smooth curve into the notch
    path.cubicTo(
      centerX - notchWidth / 2, 0,
      centerX - notchWidth / 4, notchHeight,
      centerX, notchHeight,
    );

    // Smooth curve out of the notch
    path.cubicTo(
      centerX + notchWidth / 4, notchHeight,
      centerX + notchWidth / 2, 0,
      centerX + notchWidth / 2 + 20.w, 0,
    );

    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
