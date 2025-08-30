import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dashboard/presenatation/screen/dashBoard.dart';

class HomeController extends GetxController with GetSingleTickerProviderStateMixin {
  // Reactive selected index
  var selectedIndex = 0.obs;

  // FAB expanded state
  var isExpanded = false.obs;

  // Animation controller for floating buttons
  late AnimationController controller;
  late Animation<double> animation;

  // Pages for navigation
  final List<Widget> pages = [
    DashBoardPage(),
    const Center(child: Text("Posts Page")),
    const Center(child: Text("Schedules Page")),
    const Center(child: Text("Profile Page")),
  ];

  @override
  void onInit() {
    super.onInit();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    animation = CurvedAnimation(parent: controller, curve: Curves.easeInOut);
  }

  // Toggle FAB expand/collapse
  void toggleExpand() {
    debugPrint('Toggling FAB: ${isExpanded.value} -> ${!isExpanded.value}');
    if (isExpanded.value) {
      controller.reverse();
    } else {
      controller.forward();
    }
    isExpanded.value = !isExpanded.value;
  }

  // Change bottom nav page
  void changePage(int index) {
    debugPrint('Changing page to index: $index');
    selectedIndex.value = index;
  }

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }
}