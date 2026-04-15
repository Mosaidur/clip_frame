import 'package:clip_frame/core/widgets/custom_back_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:clip_frame/core/services/api_services/schedule_service.dart';
import 'package:clip_frame/features/schedule/data/model.dart';
import 'package:clip_frame/features/schedule/presenatation/widgets/ScheduledPostPreviewScreen.dart';
import 'package:get/get.dart';
import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';

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
      // Find all days in the current month with padding for correct alignment
      DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
      int daysInMonth = DateTime(now.year, now.month + 1, 0).day;

      // Calculate how many days to pad from previous month to align with weekday
      int firstWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0

      // Total items in grid to show full month with correct alignment
      displayDates = List.generate(daysInMonth + firstWeekday, (i) {
        if (i < firstWeekday) {
          // Placeholder date for previous month (will handle in UI)
          return firstDayOfMonth.subtract(Duration(days: firstWeekday - i));
        }
        return firstDayOfMonth.add(Duration(days: i - firstWeekday));
      });
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
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Header Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomBackButton(
                        backgroundColor: Colors.black12,
                        iconColor: Colors.black87,
                      ),
                      SizedBox(height: 15.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('MMMM d, yyyy').format(selectedDate),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                selectedDate.day == DateTime.now().day &&
                                        selectedDate.month ==
                                            DateTime.now().month &&
                                        selectedDate.year == DateTime.now().year
                                    ? "Today"
                                    : DateFormat('EEEE').format(selectedDate),
                                style: TextStyle(
                                  fontSize: 28.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          _buildProfileAvatar(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Calendar View & Calendar Content
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35.r),
                      topRight: Radius.circular(35.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildViewSelectorHeader(),
                      selectedView == "Weekly"
                          ? _buildWeeklyCalendar()
                          : _buildMonthlyCalendar(),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),

              // 3. Timeline Title
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 15.h,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        "Schedule Timeline",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Timeline SliverList
              SliverList(
                delegate: SliverChildBuilderDelegate((context, hour) {
                  String timeLabel = "${hour.toString().padLeft(2, '0')}:00";
                  List<SchedulePost> posts = postsByHour[hour] ?? [];

                  return Container(
                    color: Colors.white,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Divider(
                              color: Colors.grey.shade100,
                              thickness: 1,
                              height: 1,
                            ),
                          ),
                        ),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                width: 75.w,
                                color: Colors.purple.withOpacity(0.03),
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(vertical: 25.h),
                                child: Text(
                                  timeLabel,
                                  style: TextStyle(
                                    color: Colors.purple.shade400,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: posts.isEmpty
                                    ? const SizedBox.shrink()
                                    : SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        physics: const BouncingScrollPhysics(),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                        ),
                                        child: Row(
                                          children: posts
                                              .map((p) => _buildPostCard(p))
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
                }, childCount: 24),
              ),
              // Bottom padding
              SliverToBoxAdapter(
                child: Container(height: 50.h, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 55.r,
      height: 55.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: imageUrl == null || imageUrl!.isEmpty
          ? Icon(Icons.person, size: 35.r, color: Colors.white)
          : ClipOval(child: Image.network(imageUrl!, fit: BoxFit.cover)),
    );
  }

  Widget _buildViewSelectorHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 25.h, 20.w, 15.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Calendar View",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                selectedView = selectedView == "Weekly" ? "Monthly" : "Weekly";
                _updateDisplayDates();
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(color: Colors.purple.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month, color: Colors.purple, size: 18.r),
                  SizedBox(width: 8.w),
                  Text(
                    selectedView,
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.purple, size: 20.r),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyCalendar() {
    return SizedBox(
      height: 90.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayDates.length,
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        physics: const BouncingScrollPhysics(),
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58.w,
              margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 5.w),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF007CFE) : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF007CFE)
                      : Colors.grey.shade200,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF007CFE).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekDays[date.weekday % 7],
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black45,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  if (!isSelected)
                    Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_getTypesOnDate(date).contains('post'))
                            _buildSmallDot(const Color(0xFF007CFE)),
                          if (_getTypesOnDate(date).contains('reel'))
                            _buildSmallDot(Colors.orange),
                          if (_getTypesOnDate(date).contains('story'))
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
    );
  }

  Widget _buildPostCard(SchedulePost post) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => ScheduledPostPreviewScreen(post: post),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 300),
        );
      },
      child: Container(
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
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(15.r),
              child: _buildMediaContent(post),
            ),
          ],
        ),
      ),
    );
  }

  bool _isVideo(SchedulePost post) {
    if (post.imageUrl.isEmpty) return false;
    final type = post.contentType.toLowerCase();
    if (type == 'reel' || type == 'story') return true;
    final lowercase = post.imageUrl.toLowerCase();
    return lowercase.endsWith('.mp4') ||
        lowercase.endsWith('.mov') ||
        lowercase.endsWith('.avi') ||
        lowercase.endsWith('.mkv') ||
        lowercase.contains('video');
  }

  Widget _buildMediaContent(SchedulePost post) {
    bool isCarousel = post.mediaUrls.length > 1;
    bool isVideo = _isVideo(post);

    String? displayUrl;
    if (post.thumbnailUrl != null && post.thumbnailUrl!.isNotEmpty) {
      displayUrl = post.thumbnailUrl;
    } else if (post.imageUrl.isNotEmpty) {
      displayUrl = post.imageUrl;
    }

    Widget content;
    if (isVideo && (post.thumbnailUrl == null || post.thumbnailUrl!.isEmpty)) {
      content = FutureBuilder<Uint8List?>(
        future: VideoThumbnail.thumbnailData(
          video: post.imageUrl,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 200,
          quality: 25,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Image.memory(
              snapshot.data!,
              height: 80.h,
              width: double.infinity,
              fit: BoxFit.contain,
            );
          }
          return _buildPlaceholder();
        },
      );
    } else if (displayUrl != null) {
      content = Image.network(
        displayUrl,
        height: 80.h,
        width: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else {
      content = _buildPlaceholder();
    }

    return Container(
      height: 80.h,
      width: double.infinity,
      color: Colors.black,
      child: Stack(
        children: [
          // Blurred background for premium look
          if (displayUrl != null)
            Positioned.fill(
              child: Image.network(
                displayUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.black),
              ),
            ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),
          
          // Main content
          Center(child: content),

          // Multiple Image Indicator
          if (isCarousel)
            Positioned(
              top: 5.r,
              right: 5.r,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.collections_rounded, color: Colors.white, size: 10.r),
                    SizedBox(width: 4.w),
                    Text(
                      "${post.mediaUrls.length}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Play Icon for Videos
          if (isVideo)
            Center(
              child: Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 20.r,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 80.h,
      width: double.infinity,
      color: const Color(0xFFF1F5F9),
      child: Icon(Icons.image_outlined, color: const Color(0xFFCBD5E1), size: 30.r),
    );
  }

  Widget _buildMonthlyCalendar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: Column(
        children: [
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 10.h),
          // Grid of days
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            itemCount: displayDates.length,
            itemBuilder: (context, index) {
              DateTime date = displayDates[index];
              bool isCurrentMonth = date.month == DateTime.now().month;

              if (!isCurrentMonth) {
                return const SizedBox.shrink(); // Hide dates from other months
              }

              bool isSelected =
                  selectedDate.year == date.year &&
                  selectedDate.month == date.month &&
                  selectedDate.day == date.day;
              bool isToday =
                  date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  date.day == DateTime.now().day;

              return GestureDetector(
                onTap: () => setState(() {
                  selectedDate = date;
                  postsByHour = _groupPostsByHour(scheduledPosts);
                }),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF007CFE)
                        : isToday
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10.r),
                    border: isToday && !isSelected
                        ? Border.all(color: const Color(0xFF007CFE), width: 1)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_getTypesOnDate(date).contains('post'))
                            _buildSmallDot(
                              isSelected
                                  ? Colors.white
                                  : const Color(0xFF007CFE),
                            ),
                          if (_getTypesOnDate(date).contains('reel'))
                            _buildSmallDot(
                              isSelected ? Colors.white : Colors.orange,
                            ),
                          if (_getTypesOnDate(date).contains('story'))
                            _buildSmallDot(
                              isSelected
                                  ? Colors.white
                                  : const Color(0xFFFF277F),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
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
