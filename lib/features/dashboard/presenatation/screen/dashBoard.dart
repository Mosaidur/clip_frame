import 'package:clip_frame/core/model/content_template_model.dart';
import 'package:clip_frame/features/dashboard/presenatation/controller/dashboard_controller.dart';
import 'package:clip_frame/features/homeController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:clip_frame/core/services/api_services/schedule_service.dart';
import 'package:clip_frame/features/schedule/data/model.dart';
import 'package:intl/intl.dart';

import 'package:clip_frame/features/schedule/presenatation/controller/schedule_controller.dart';
import '../widgets/schedule_list.dart';

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({super.key});

  @override
  State<DashBoardPage> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
  final TextEditingController customTypeController = TextEditingController();
  String date = '';
  String day = '';
  final String? imageUrl = null;
  List<SchedulePost> scheduledPosts = [];
  bool isLoading =
      true; // Still used for initial local init if needed, but mostly redundant now
  final int total = 11;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final now = DateTime.now();
    date = DateFormat('MMMM d, y').format(now);

    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (now.difference(today).inDays == 0) {
      day = "Today";
    } else if (now.difference(tomorrow).inDays == 0) {
      day = "Tomorrow";
    } else {
      day = DateFormat('EEEE').format(now);
    }

    // UI local initialization
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      child: RefreshIndicator(
        onRefresh: () async {
          await Get.find<ScheduleController>().loadAllData();
          await Get.find<DashboardController>().fetchDashboardData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: 15.h),
              Obx(() {
                if (!Get.isRegistered<ScheduleController>()) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final controller = Get.find<ScheduleController>();
                return _buildSummaryGrid(controller);
              }),
              _buildActionButtons(context),
              _buildSection(
                title: "Most Recent",
                onSeeAll: () => Get.find<HomeController>().navigateToPosts(),
              ),
              Obx(() {
                final controller = Get.find<DashboardController>();
                if (controller.isLoading.value &&
                    controller.recentTemplates.isEmpty) {
                  return SizedBox(
                    height: 200.h,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                return _buildHorizontalPostList(controller.recentTemplates);
              }),
              SizedBox(height: 20.h),
              _buildPromotionBanner(),
              _buildSection(
                title: "For you",
                onSeeAll: () => Get.find<HomeController>().navigateToPosts(),
              ),
              Obx(() {
                final controller = Get.find<DashboardController>();
                if (controller.isLoading.value &&
                    controller.forYouTemplates.isEmpty) {
                  return SizedBox(
                    height: 200.h,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                return _buildHorizontalPostList(controller.forYouTemplates);
              }),
              SizedBox(height: 100.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 5.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5.h),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      day,
                      style: TextStyle(
                        fontSize: 22.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                _buildProfileAvatar(),
              ],
            ),
          ),
          _buildCalendarStrip(),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 50.r,
      height: 50.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: imageUrl == null || imageUrl!.isEmpty
          ? Icon(Icons.person, size: 30.r, color: Colors.white)
          : ClipOval(
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.person, size: 30.r, color: Colors.white),
              ),
            ),
    );
  }

  Widget _buildCalendarStrip() {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    final weekdays = ["S", "M", "T", "W", "T", "F", "S"];

    return SizedBox(
      height: 75.h,
      child: Obx(() {
        final controller = Get.find<ScheduleController>();
        // Access length to ensure Obx tracks this RxList,
        // as itemBuilder is lazy and might not touch it during initial builder execution.
        final _ = controller.scheduledPosts.length;
        final posts = controller.scheduledPosts;

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          itemCount: daysInMonth,
          itemBuilder: (context, index) {
            final date = DateTime(now.year, now.month, index + 1);
            // Count posts for this date using unified extraction logic
            final dayPosts = posts.where((p) {
              final d = ScheduleService.extractDate(p);
              return d.year == date.year &&
                  d.month == date.month &&
                  d.day == date.day;
            }).toList();

            final types = dayPosts
                .map((p) => p.contentType.toLowerCase())
                .toSet();

            final weekdayIndex = date.weekday % 7;
            final isToday =
                date.day == now.day &&
                date.month == now.month &&
                date.year == now.year;

            return Container(
              width: 50.w,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekdays[weekdayIndex],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: isToday
                        ? BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          )
                        : null,
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(
                        color: isToday ? Colors.blue : Colors.grey,
                        fontSize: 14.sp,
                        fontWeight: isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  _buildDotsIndicator(types),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildDotsIndicator(Set<String> types) {
    return SizedBox(
      height: 6.h,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (types.contains('post')) _buildDot(Colors.blue),
          if (types.contains('reel')) _buildDot(Colors.orange),
          if (types.contains('story')) _buildDot(Colors.pink),
        ],
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 1.w),
      width: 5.r,
      height: 5.r,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildSummaryGrid(ScheduleController scheduleController) {
    try {
      final homeController = Get.find<HomeController>();
      // final scheduleController = Get.find<ScheduleController>(); // Removed as it is now passed as parameter

      // Calculate dynamic values
      final publishedPosts = scheduleController.historyPosts
          .where((p) => p.contentType == 'post')
          .length;
      final publishedReels = scheduleController.historyPosts
          .where((p) => p.contentType == 'reel')
          .length;
      final createdStories = scheduleController.historyPosts
          .where((p) => p.contentType == 'story')
          .length;

      int totalViews = 0;
      double totalGrowth = 0;
      for (var post in scheduleController.historyPosts) {
        totalViews += post.totalAudience;
        totalGrowth += post.percentageGrowth;
      }

      final avgEngagement = scheduleController.historyPosts.isEmpty
          ? 0.0
          : (totalGrowth / scheduleController.historyPosts.length);

      final displayEngagement =
          (avgEngagement.isNaN || avgEngagement.isInfinite)
          ? 0.0
          : avgEngagement;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => homeController.navigateToPosts(),
                    child: _SummaryCard(
                      label: "Post\nPublished",
                      value: publishedPosts.toString(),
                      icon: Icons.article_outlined,
                      color: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () => homeController.navigateToReels(),
                    child: _SummaryCard(
                      label: "Reels\nPublished",
                      value: publishedReels.toString(),
                      icon: Icons.movie_outlined,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => homeController.navigateToStories(),
                    child: _SummaryCard(
                      label: "Story\nCreated",
                      value: createdStories.toString(),
                      icon: Icons.history_edu_outlined,
                      color: Colors.pink,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _SummaryCard(
                    label: "Weekly\nViews",
                    value: totalViews.toString(),
                    icon: Icons.remove_red_eye_outlined,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _SummaryCard(
              label: "Average Engagement",
              value: "${displayEngagement.toStringAsFixed(1)}%",
              icon: Icons.query_stats,
              color: Colors.purple,
              isWide: true,
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint("⛔ Dashboard Grid Error: $e");
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            children: [
              Text(
                "Error loading stats: $e",
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              TextButton(
                onPressed: () => scheduleController.loadAllData(),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: _ActionButton(
              label: "Create Weekly Content",
              icon: Icons.add_box_rounded,
              color: const Color(0xFF007CFE),
              onTap: () {},
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 4,
            child: _ActionButton(
              label: "Calendar",
              icon: Icons.calendar_month,
              color: const Color(0xFFFF277F),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SchedulePage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required VoidCallback onSeeAll,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(15.w, 10.h, 15.w, 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: const Color(0xFF2D2D2F),
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: Row(
              children: [
                Text(
                  "See All",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.blue, size: 18.sp),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalPostList(List<ContentTemplateModel> templates) {
    if (templates.isEmpty) {
      return SizedBox(
        height: 200.h,
        child: const Center(
          child: Text(
            "No templates available",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return SizedBox(
      height: 200.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: templates.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final template = templates[index];
          return GestureDetector(
            onTap: () {
              final homeController = Get.find<HomeController>();
              final type = (template.type ?? '').toLowerCase();

              if (type == 'reel') {
                homeController.navigateToReels(initialId: template.id);
              } else if (type == 'story') {
                homeController.navigateToStories(initialId: template.id);
              } else {
                homeController.navigateToPosts(initialId: template.id);
              }
            },
            child: _PostCard(template: template),
          );
        },
      ),
    );
  }

  Widget _buildPromotionBanner() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Image.asset(
          "assets/images/edit_photo.png",
          fit: BoxFit.cover,
          height: 140.h,
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isWide;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: isWide
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 22.r),
          ),
          SizedBox(width: 12.w),
          if (isWide) ...[
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                color: Colors.black,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ] else
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    label.replaceAll("\n", " "),
                    style: TextStyle(color: Colors.grey[600], fontSize: 11.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(50.r),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18.r),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final ContentTemplateModel template;

  const _PostCard({required this.template});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: Colors.grey[200],
        image: template.thumbnail != null && template.thumbnail!.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(template.thumbnail!),
                fit: BoxFit.cover,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          _buildGradientOverlay(),
          Positioned(top: 10.h, left: 10.w, child: _buildProfileTag()),
          Positioned(
            bottom: 10.h,
            left: 10.w,
            right: 10.w,
            child: _buildStatsTag(),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.2),
            Colors.transparent,
            Colors.black.withOpacity(0.4),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTag() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 10.r,
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.person, size: 10.r, color: Colors.white),
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              template.createdBy?.name ?? "Admin",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTag() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            icon: Icons.repeat,
            count: (template.stats?.reuseCount ?? 0).toString(),
          ),
          VerticalDivider(color: Colors.white24, width: 1.w, thickness: 1),
          _StatItem(
            icon: Icons.favorite,
            count: (template.stats?.loveCount ?? 0).toString(),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String count;

  const _StatItem({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 12.r),
        SizedBox(width: 4.w),
        Text(
          count,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
