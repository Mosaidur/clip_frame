import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/model.dart';
import '../controller/schedule_controller.dart';
import '../widgets/SchedulePost.dart';
import '../widgets/history.dart';
import '../../../homeController.dart';
import 'package:clip_frame/features/my_profile/presenatation/screen/MyProfileController.dart';

class ScheduleScreenPage extends StatelessWidget {
  const ScheduleScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ScheduleController controller = Get.find<ScheduleController>();
    final MyProfileController profileController = Get.put(
      MyProfileController(),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF9F3E8), // Match mockup background
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header from Mockup
            _buildHeader(profileController),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.r),
                    topRight: Radius.circular(40.r),
                  ),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      // Tab Switcher from Mockup
                      _buildTabBar(controller),

                      SizedBox(height: 20.h),

                      // Tab Content
                      Expanded(
                        child: Obx(() {
                          if (controller.isLoading.value) {
                            return _buildShimmerLoading();
                          }

                          if (controller.errorMessage.isNotEmpty) {
                            return _buildErrorState(controller);
                          }

                          if (controller.selectedTab.value == 0) {
                            return _buildScheduledTab(controller);
                          } else {
                            return _buildHistoryTab(controller);
                          }
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(MyProfileController profileController) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _roundIcon(Icons.menu_rounded, () {
            // Menu action
          }),
          Text(
            "Posts",
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          GestureDetector(
            onTap: () => Get.find<HomeController>().changePage(3),
            child: Container(
              padding: EdgeInsets.all(3.r),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFFF277F), Color(0xFF2870F3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  image: const DecorationImage(
                    image: NetworkImage(
                      "https://i.pravatar.cc/150?u=clipframe",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ScheduleController controller) {
    return Obx(() {
      return Container(
        height: 54.h,
        width: double.infinity,
        padding: EdgeInsets.all(5.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.r),
          color: const Color(0xFFF3F4F6),
        ),
        child: Row(
          children: [
            Expanded(child: _buildTabItem("Scheduled Posts", 0, controller)),
            Expanded(child: _buildTabItem("History", 1, controller)),
          ],
        ),
      );
    });
  }

  Widget _buildTabItem(String title, int index, ScheduleController controller) {
    bool isSelected = controller.selectedTab.value == index;
    return GestureDetector(
      onTap: () => controller.selectedTab.value = index,
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFF277F), Color(0xFF2870F3)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isSelected ? null : Colors.transparent,
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduledTab(ScheduleController controller) {
    if (controller.scheduledPosts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.calendar_today_outlined,
        title: "No Scheduled Posts",
        subtitle: "Your scheduled posts will appear here.",
      );
    }
    return RefreshIndicator(
      onRefresh: () => controller.loadAllData(),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: controller.scheduledPosts.length,
        itemBuilder: (context, index) =>
            SchedulePostWidget(post: controller.scheduledPosts[index]),
      ),
    );
  }

  Widget _buildHistoryTab(ScheduleController controller) {
    if (controller.historyPosts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history_rounded,
        title: "No Post History",
        subtitle: "Your published content will appear here.",
      );
    }
    return RefreshIndicator(
      onRefresh: () => controller.loadAllData(),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: controller.historyPosts.length,
        itemBuilder: (context, index) =>
            HistoryWidget(post: controller.historyPosts[index]),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 3,
        itemBuilder: (_, __) => Padding(
          padding: EdgeInsets.only(bottom: 15.h),
          child: Container(
            height: 250.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50.r, color: const Color(0xFF94A3B8)),
          SizedBox(height: 15.h),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ScheduleController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 40, color: Colors.grey),
          SizedBox(height: 10.h),
          Text(
            controller.errorMessage.value,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey),
          ),
          TextButton(
            onPressed: () => controller.loadAllData(),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _roundIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFE5E7EB),
        ),
        child: Icon(icon, color: Colors.black, size: 22.r),
      ),
    );
  }
}
