import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:clip_frame/core/services/api_services/schedule_service.dart';
import 'package:clip_frame/features/schedule/data/model.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  String selectedView = "Weekly";
  DateTime selectedDate = DateTime.now();
  List<DateTime> displayDates = [];
  String? imageUrl;
  List<SchedulePost> scheduledPosts = [];
  Map<int, List<SchedulePost>> postsByHour = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _updateDisplayDates();
    _loadScheduledPosts();
  }

  void _updateDisplayDates() {
    final now = DateTime.now();
    if (selectedView == "Weekly") {
      // Find current week (Sunday to Saturday)
      DateTime firstDayOfWeek = now.subtract(Duration(days: now.weekday % 7));
      displayDates = List.generate(
        7,
        (i) => firstDayOfWeek.add(Duration(days: i)),
      );
    } else {
      // Find all days in the current month
      int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
      displayDates = List.generate(
        daysInMonth,
        (i) => firstDayOfMonth.add(Duration(days: i)),
      );
    }
  }

  Future<void> _loadScheduledPosts() async {
    final posts = await ScheduleService.fetchScheduledPosts();
    setState(() {
      scheduledPosts = posts;
      postsByHour = _groupPostsByHour(posts);
      isLoading = false;
    });
  }

  Map<int, List<SchedulePost>> _groupPostsByHour(List<SchedulePost> posts) {
    Map<int, List<SchedulePost>> grouped = {};

    for (var post in posts) {
      try {
        final dateTime = ScheduleService.extractDate(post);

        // Only include posts for the selected date
        if (dateTime.year == selectedDate.year &&
            dateTime.month == selectedDate.month &&
            dateTime.day == selectedDate.day) {
          final hour = dateTime.hour;
          grouped.putIfAbsent(hour, () => []).add(post);
        }
      } catch (e) {
        debugPrint("Error grouping post by hour: $e for post ${post.title}");
      }
    }

    return grouped;
  }

  Set<String> _getTypesOnDate(DateTime date) {
    return scheduledPosts
        .where((post) {
          final postDate = ScheduleService.extractDate(post);
          return postDate.year == date.year &&
              postDate.month == date.month &&
              postDate.day == date.day;
        })
        .map((p) => p.contentType.toLowerCase())
        .toSet();
  }

  // ✅ Weekday list (Sun → Sat, only first letters)
  final List<String> weekDays = ["S", "M", "T", "W", "T", "F", "S"];

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEBC894), Color(0xFFFFFFFF)],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFF007CFE)),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEBC894), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),
                        Text(
                          DateFormat('MMMM d, yyyy').format(selectedDate),
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          selectedDate.day == DateTime.now().day &&
                                  selectedDate.month == DateTime.now().month &&
                                  selectedDate.year == DateTime.now().year
                              ? "Today"
                              : DateFormat('EEEE').format(selectedDate),
                          style: TextStyle(
                            fontSize: 24.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    Container(
                      width: 50.r,
                      height: 50.r,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                      child: imageUrl == null || imageUrl!.isEmpty
                          ? Icon(Icons.person, size: 35.r, color: Colors.white)
                          : ClipOval(
                              child: Image.network(
                                imageUrl!,
                                fit: BoxFit.cover,
                                width: 50.r,
                                height: 50.r,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              // Top header with view selector
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Calendar View",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedView = selectedView == "Weekly"
                              ? "Monthly"
                              : "Weekly";
                          _updateDisplayDates();
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month,
                              color: Colors.purple,
                              size: 18.r,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              selectedView,
                              style: TextStyle(
                                color: Colors.purple,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.purple,
                              size: 20.r,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                color: Colors.white,
                child: SizedBox(
                  height: 85.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: displayDates.length,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    itemBuilder: (_, i) {
                      DateTime date = displayDates[i];
                      bool isSelected =
                          selectedDate.year == date.year &&
                          selectedDate.month == date.month &&
                          selectedDate.day == date.day;
                      return GestureDetector(
                        onTap: () => setState(() {
                          selectedDate = date;
                          postsByHour = _groupPostsByHour(scheduledPosts);
                        }),
                        child: Container(
                          width: 55.w,
                          margin: EdgeInsets.symmetric(
                            vertical: 8.h,
                            horizontal: 4.w,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF007CFE)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                weekDays[date.weekday % 7],
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black45,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                date.day.toString(),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              if (!isSelected)
                                Padding(
                                  padding: EdgeInsets.only(top: 4.h),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_getTypesOnDate(
                                        date,
                                      ).contains('post'))
                                        _buildSmallDot(const Color(0xFF007CFE)),
                                      if (_getTypesOnDate(
                                        date,
                                      ).contains('reel'))
                                        _buildSmallDot(Colors.orange),
                                      if (_getTypesOnDate(
                                        date,
                                      ).contains('story'))
                                        _buildSmallDot(const Color(0xFFFF277F)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              Container(height: 10, color: Colors.white),

              // Timeline
              Expanded(
                child: ListView.builder(
                  itemCount: 24,
                  itemBuilder: (_, hour) {
                    String timeLabel =
                        "${hour.toString().padLeft(2, '0')}:00"; // 00:00 → 23:00
                    List<SchedulePost> posts = postsByHour[hour] ?? [];

                    return Container(
                      color: Colors.white,
                      child: Stack(
                        children: [
                          // Divider in background (full width line)
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Divider(
                                color: Colors.grey.shade300,
                                thickness: 1,
                                height: 1,
                              ),
                            ),
                          ),

                          // Foreground row (time + posts)
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Time label
                                Container(
                                  width: 70.w,
                                  color: Colors.purple.shade50,
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 20.h,
                                      horizontal: 8.w,
                                    ),
                                    child: Text(
                                      timeLabel,
                                      style: TextStyle(
                                        color: Colors.purple,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),

                                // Posts section
                                Expanded(
                                  child: posts.isEmpty
                                      ? const SizedBox.shrink()
                                      : SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: posts
                                                .map(
                                                  (post) =>
                                                      _buildPostCard(post),
                                                )
                                                .toList(),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(SchedulePost post) {
    return Container(
      width: 220.w,
      margin: EdgeInsets.all(10.r),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF6FF),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title row
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // ✅ stretch to same height
              children: [
                // Blue rectangle line
                Container(
                  width: 3.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF007CFE),
                    borderRadius: BorderRadius.circular(2).r,
                  ),
                ),
                SizedBox(width: 8.w), // spacing between line & text
                // Title
                Expanded(
                  child: Text(
                    post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Tags
          if (post.tags.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    post.tags.take(2).join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(15.r),
            child: post.imageUrl.isNotEmpty
                ? Image.network(
                    post.thumbnailUrl ?? post.imageUrl,
                    height: 80.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 80.h,
                      color: Colors.grey[100],
                      child: Icon(
                        Icons.image,
                        color: Colors.grey[400],
                        size: 30.r,
                      ),
                    ),
                  )
                : Container(
                    height: 80.h,
                    color: Colors.grey[100],
                    child: Icon(
                      Icons.image,
                      color: Colors.grey[400],
                      size: 30.r,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallDot(Color color) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 1.w),
      width: 4.r,
      height: 4.r,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
