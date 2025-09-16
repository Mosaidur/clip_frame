import 'package:clip_frame/features/post/presenatation/screen/postCreationPage.dart';
import 'package:clip_frame/features/schedule/presenatation/screen/schedule.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dashboard/presenatation/screen/dashBoard.dart';
import 'dashboard/presenatation/widgets/schedule_list.dart';
import 'my_profile/presenatation/screen/MyProfileController.dart';

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
    PostCreationPage(),
    ScheduleScreenPage(),
    MyProfilePage(),
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