import 'package:clip_frame/features/post/presenatation/screen/postCreationPage.dart';
import 'package:clip_frame/features/post/presenatation/screen/postScrollPage.dart';
import 'package:clip_frame/features/post/presenatation/screen/reelsScrollPage.dart';
import 'package:clip_frame/features/post/presenatation/screen/storyScrollPage.dart';
import 'package:clip_frame/features/post/presenatation/Screen_2/photo_preview_screen.dart';
import 'package:clip_frame/features/Video%20Editing/VideoEditing.dart';
import 'package:clip_frame/features/story_creation/story_Edit.dart';
import 'package:clip_frame/features/schedule/presenatation/screen/schedule.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'dashboard/presenatation/screen/dashBoard.dart';
import 'dashboard/presenatation/controller/dashboard_controller.dart';
import 'schedule/presenatation/controller/schedule_controller.dart';
import 'dashboard/presenatation/widgets/schedule_list.dart';
import 'my_profile/presenatation/screen/MyProfileController.dart';
import 'post/presenatation/widget2/customTabBar.dart' as tab_bar;

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Reactive selected index
  var selectedIndex = 0.obs;

  // FAB expanded state
  var isExpanded = false.obs;

  // Track the tab in PostCreationPage (0: Reels, 1: Posts, 2: Stories)
  var postTabIndex = 0.obs;

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
    // Initialize ScheduleController early so it's ready for refresh requests
    Get.put(ScheduleController());
    Get.put(DashboardController());

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

    // Trigger data refresh if navigating to Schedules tab
    if (index == 2) {
      if (Get.isRegistered<ScheduleController>()) {
        Get.find<ScheduleController>().loadAllData();
      }
    }
  }

  // Set Post Tab and Navigate
  void navigateToPostTab(int tabIndex) {
    postTabIndex.value = tabIndex;
    selectedIndex.value = 1; // 1 is PostCreationPage
    if (isExpanded.value) {
      toggleExpand();
    }
  }

  // Direct Navigation to Scroll Pages
  void navigateToReels({String? initialId}) {
    if (isExpanded.value) toggleExpand();
    tab_bar.selectedTab = "Reels"; // Sync TabBar state
    Get.to(() => Reelsscrollpage(initialId: initialId));
  }

  void navigateToStories({String? initialId}) {
    if (isExpanded.value) toggleExpand();
    tab_bar.selectedTab = "Stories"; // Sync TabBar state
    Get.to(() => StoryScrollPage(initialId: initialId));
  }

  void navigateToPosts({String? initialId}) {
    if (isExpanded.value) toggleExpand();
    tab_bar.selectedTab = "Posts"; // Sync TabBar state
    Get.to(() => PostScrollPage(initialId: initialId));
  }

  // --- Creator Flow / Filter Navigation ---

  final ImagePicker _picker = ImagePicker();

  Future<void> navigateToPostFilter() async {
    if (isExpanded.value) toggleExpand();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      Get.to(() => PhotoPreviewScreen(imagePath: image.path));
    }
  }

  Future<void> navigateToReelFilter() async {
    if (isExpanded.value) toggleExpand();
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      Get.to(() => AdvancedVideoEditorPage(videos: [File(video.path)]));
    }
  }

  Future<void> navigateToStoryFilter() async {
    if (isExpanded.value) toggleExpand();
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      Get.to(
        () => StoryEditPage(files: images.map((x) => File(x.path)).toList()),
      );
    }
  }

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }
}
