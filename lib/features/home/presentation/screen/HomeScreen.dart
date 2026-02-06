import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controller/homeController.dart';

class HomePage extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());
  
  // Floating button widget for the menu items
  Widget floatingButton(String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 65.r,
          height: 65.r,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE4405F), Color(0xFF6A5AEF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24.r),
              SizedBox(height: 2.h),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  decoration: TextDecoration.none, // Remove underlining "dag"
                ),
              ),
            ],
          ),
        ),
      ],
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
      child: Stack(
        children: [
          Scaffold(
            extendBody: true,
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            body: Obx(() {
              debugPrint('Building page: ${controller.selectedIndex.value}');
              return controller.pages[controller.selectedIndex.value];
            }),
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
          
          // Floating Menu Items (Positioned based on image layout)
          Obx(() => IgnorePointer(
            ignoring: !controller.isExpanded.value,
            child: AnimatedBuilder(
              animation: controller.controller,
              builder: (context, child) {
                // Arrangement: POST (West), REEL (North), STORY (East)
                // Reduced radius to bring items closer
                double radius = 85.h;
                
                return Stack(
                  children: [
                    // REEL (Top/North)
                    Positioned(
                      bottom: 85.h + (controller.animation.value * radius),
                      left: 0.5.sw - 32.5.r,
                      child: Opacity(
                        opacity: controller.animation.value,
                        child: GestureDetector(
                          onTap: () {
                            debugPrint("REEL tapped");
                            controller.navigateToReels();
                          },
                          child: floatingButton("REEL", Icons.movie_outlined),
                        ),
                      ),
                    ),
                    // POST (Left/West)
                    Positioned(
                      bottom: 45.h + (controller.animation.value * radius * 0.4),
                      left: 0.5.sw - 32.5.r - (controller.animation.value * radius * 0.7),
                      child: Opacity(
                        opacity: controller.animation.value,
                        child: GestureDetector(
                          onTap: () {
                            debugPrint("POST tapped");
                            controller.navigateToPosts();
                          },
                          child: floatingButton("POST", Icons.dashboard_customize_outlined),
                        ),
                      ),
                    ),
                    // STORY (Right/East)
                    Positioned(
                      bottom: 45.h + (controller.animation.value * radius * 0.4),
                      left: 0.5.sw - 32.5.r + (controller.animation.value * radius * 0.7),
                      child: Opacity(
                        opacity: controller.animation.value,
                        child: GestureDetector(
                          onTap: () {
                            debugPrint("STORY tapped");
                            controller.navigateToStories();
                          },
                          child: floatingButton("STORY", Icons.amp_stories_outlined),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          )),
        ],
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
