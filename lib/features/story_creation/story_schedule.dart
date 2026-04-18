import 'dart:io';
import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:clip_frame/core/widgets/custom_back_button.dart';
import 'package:clip_frame/core/utils/scheduling_utils.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:clip_frame/core/services/api_services/content_service.dart';
import 'package:clip_frame/core/services/api_services/content_template_service.dart';
import 'package:clip_frame/Shared/routes/routes.dart';

class StorySchedulePage extends StatefulWidget {
  final List<File> files;

  const StorySchedulePage({super.key, required this.files});

  @override
  State<StorySchedulePage> createState() => _StorySchedulePageState();
}

class _StorySchedulePageState extends State<StorySchedulePage> {
  int _selectedPlatformIndex = 1; // 0: FB, 1: IG
  int _selectedStoryIndex = 0;
  bool _remindMe = true;
  bool _showSuggestedDialog = true;
  bool _scheduledSuccess = false;
  bool _showCongratulation = false;
  bool _isApiLoading = false;
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  String _selectedTimeMode = "Time";
  int _selectedHour = 5;
  int _selectedMinute = 0;
  String _period = "PM";
  String _storyTemplateId = ""; // Fetched from API on init

  final List<String> _platforms = ["Facebook", "Instagram"];
  final List<dynamic> _platformIcons = [
    Icons.facebook_rounded,
    'assets/images/instagram.png',
  ];

  @override
  void initState() {
    super.initState();
    _fetchStoryTemplateId();
  }

  Future<void> _fetchStoryTemplateId() async {
    try {
      final templates = await ContentTemplateService.fetchTemplatesByType('story');
      if (templates.isNotEmpty && mounted) {
        setState(() => _storyTemplateId = templates.first.id ?? "");
        debugPrint("✅ [StorySchedule] Got story templateId: $_storyTemplateId");
      } else {
        debugPrint("⚠️ [StorySchedule] No story templates found from API");
      }
    } catch (e) {
      debugPrint("⛔ [StorySchedule] Failed to fetch story template: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_scheduledSuccess) return _buildSuccessView();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFFF7F3EB)),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPlatformTabs(),
                          SizedBox(height: 20.h),
                          _buildStoryTabs(),
                          SizedBox(height: 20.h),
                          _buildCalendarSection(),
                          SizedBox(height: 25.h),
                          _buildTimePickerSection(),
                          SizedBox(height: 20.h),
                          _buildRemindMeToggle(),
                          SizedBox(height: 30.h),
                          _buildScheduleButton(),
                          SizedBox(height: 30.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showSuggestedDialog) _buildSuggestedDialog(),
          if (_showCongratulation) _buildCongratsDialog(),
        ],
      ),
    );
  }

  bool _isVideoFile(File file) {
    final path = file.path.toLowerCase();
    return path.endsWith('.mp4') || path.endsWith('.mov') || path.endsWith('.avi');
  }

  Widget _buildSuccessView() {
    final String formattedTime = "${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')} $_period";
    final bool isVideo = _isVideoFile(widget.files[0]);
    final String selectedPlatform = _platforms[_selectedPlatformIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFE8EAF6),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(22.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(14.r),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEEF2FF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check_circle_rounded, color: Colors.indigo, size: 36.r),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        "Successfully Scheduled!",
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: Colors.indigo),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        "You have successfully scheduled ${widget.files.length} ${widget.files.length > 1 ? 'stories' : 'story'} content.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                      ),
                      SizedBox(height: 18.h),
                      _successDetailRow("Platform:", Icons.devices_rounded, selectedPlatform),
                      SizedBox(height: 10.h),
                      _successDetailRow(
                        "Scheduled for:",
                        Icons.calendar_today_rounded,
                        "${DateFormat('EEE, MMM d').format(_selectedDate)}\n$formattedTime",
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _actionBtnVertical(Icons.edit_rounded, "Edit", Colors.orange),
                          _actionBtnVertical(Icons.copy_rounded, "Duplicate", Colors.indigo),
                          _actionBtnVertical(Icons.delete_outline_rounded, "Delete", Colors.pink),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: () => Get.offAllNamed(AppRoutes.HOME),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                            elevation: 0,
                          ),
                          child: Text(
                            "Back to Dashboard",
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
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


  Widget _successDetailRow(String label, IconData icon, String val) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.black45,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Icon(icon, size: 14.r, color: Colors.blue),
        SizedBox(width: 6.w),
        Text(
          val,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _actionBtnVertical(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20.r),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCongratsDialog() {
    return Container(
      color: Colors.black54,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Container(
          width: 300.w,
          padding: EdgeInsets.all(30.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120.r,
                height: 120.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4FB),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.celebration_rounded,
                    color: const Color(0xFFFF4081),
                    size: 60.r,
                  ),
                ),
              ),
              SizedBox(height: 25.h),
              Text(
                "Congratulations!",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                "Your content are successfully created and scheduled.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 30.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () => setState(() {
                    _showCongratulation = false;
                    _scheduledSuccess = true;
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestedDialog() {
    // Determine the next 3 upcoming dates dynamically
    final now = DateTime.now();
    final DateTime suggestedTimeToday = DateTime(now.year, now.month, now.day, 17, 0); // 5:00 PM today

    DateTime startDate;
    if (suggestedTimeToday.isBefore(now)) {
      startDate = now.add(const Duration(days: 1));
    } else {
      startDate = now;
    }

    final upcomingDates = List.generate(widget.files.length, (i) => startDate.add(Duration(days: i)));
    final suggestedTime = "05:00 PM";

    return Container(
      color: Colors.black54,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Container(
          width: 300.w,
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBF1),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Icon(
                  Icons.info_rounded,
                  color: const Color(0xFFE91E63),
                  size: 30.r,
                ),
              ),
              SizedBox(height: 15.h),
              Text(
                "Suggested Scheduling Option",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                "After going through content our AI suggest the best time to post your content.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 20.h),
              ...List.generate(widget.files.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: _suggestionItem(
                    "Story ${index + 1}",
                    SchedulingUtils.formatRecommendedDate(upcomingDates[index]),
                    suggestedTime,
                  ),
                );
              }),
              SizedBox(height: 17.h),
              Row(
                children: [
                  Expanded(
                    child: _dialogBtn("Schedule", const Color(0xFFE91E63), () {
                      setState(() {
                        // Apply first suggested date to the overall selection
                        _selectedDate = upcomingDates[0];
                        _showSuggestedDialog = false;
                      });
                    }),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _dialogBtn(
                      "Choose different date",
                      const Color(0xFF2196F3),
                      () => setState(() => _showSuggestedDialog = false),
                      isOutlined: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _suggestionItem(String story, String day, String time) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            story,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                day,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dialogBtn(String label, Color color, VoidCallback onTap, {bool isOutlined = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: isOutlined ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(14.r),
          border: isOutlined ? Border.all(color: color, width: 2.w) : null,
          boxShadow: isOutlined ? null : [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: isOutlined ? color : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CustomBackButton(),
          Text(
            "Schedule Your Story",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          TextButton(
            onPressed: () {
              if (_scheduledSuccess) {
                Get.offAllNamed(AppRoutes.HOME);
              } else {
                Navigator.pop(context);
              }
            },
            child: Text(
              "DONE",
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFE91E63),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformTabs() {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        children: List.generate(_platforms.length, (index) {
          bool isSelected = _selectedPlatformIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPlatformIndex = index),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE3F2FD)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(25.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _platformIcons[index] is IconData
                        ? Icon(
                            _platformIcons[index],
                            size: 16.r,
                            color: isSelected ? Colors.blue : Colors.black45,
                          )
                        : Image.asset(
                            _platformIcons[index],
                            width: 16.r,
                            height: 16.r,
                            color: isSelected ? null : Colors.black45,
                          ),
                    SizedBox(width: 6.w),
                    Text(
                      _platforms[index],
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: isSelected
                            ? FontWeight.w900
                            : FontWeight.w500,
                        color: isSelected ? Colors.blue : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStoryTabs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "All Stories",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 350.h, // Increased height for better visibility
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.files.length,
            itemBuilder: (context, index) {
              bool isSelected = _selectedStoryIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedStoryIndex = index),
                child: Container(
                  width: 250.w, // Dynamic width for story preview
                  margin: EdgeInsets.only(right: 15.w),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFF4081)
                          : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18.r),
                    child: _isVideoFile(widget.files[index])
                        ? FutureBuilder<Uint8List?>(
                            future: VideoThumbnail.thumbnailData(
                              video: widget.files[index].path,
                              imageFormat: ImageFormat.JPEG,
                              maxWidth: 500,
                              quality: 75,
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.memory(
                                      snapshot.data!,
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(8.r),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40.r),
                                    ),
                                  ],
                                );
                              }
                              return const Center(child: CircularProgressIndicator(color: Colors.pink));
                            },
                          )
                        : Image.file(
                            widget.files[index],
                            fit: BoxFit.contain, // Show exact size without cropping
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarSection() {
    final daysInMonth = DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final firstDayOffset = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday - 1; // 0-based

    return Container(
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(_focusedMonth),
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() {
                      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                    }),
                    icon: Icon(Icons.chevron_left_rounded, size: 24.r, color: Colors.blueAccent),
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                    }),
                    icon: Icon(Icons.chevron_right_rounded, size: 24.r, color: Colors.blueAccent),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                .map((d) => SizedBox(
                      width: 35.w,
                      child: Center(
                        child: Text(
                          d,
                          style: TextStyle(fontSize: 11.sp, color: Colors.black38, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ))
                .toList(),
          ),
          SizedBox(height: 10.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
            ),
            itemCount: daysInMonth + firstDayOffset,
            itemBuilder: (context, index) {
              if (index < firstDayOffset) return const SizedBox.shrink();
              
              int day = index - firstDayOffset + 1;
              DateTime date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
              bool isSelected = DateUtils.isSameDay(_selectedDate, date);
              bool isToday = DateUtils.isSameDay(DateTime.now(), date);

              return GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.pink : (isToday ? Colors.pink.withOpacity(0.1) : Colors.transparent),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      "$day",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : (isToday ? Colors.pink : Colors.black87),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Time",
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EAF6),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            children: ["Any Time", "Time", "Range"].map((mode) {
              bool isSelected = _selectedTimeMode == mode;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTimeMode = mode),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: Center(
                      child: Text(
                        mode,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected ? Colors.indigo : Colors.black45,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (_selectedTimeMode == "Time") ...[
          SizedBox(height: 20.h),
          _buildAnalogTimePicker(),
        ],
      ],
    );
  }

  Widget _buildAnalogTimePicker() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _timeBox("00", true),
              Text(
                " : ",
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              ),
              _timeBox("00", false),
              SizedBox(width: 20.w),
              Column(
                children: [
                  _amPmBox("AM", _period == "AM"),
                  SizedBox(height: 4.h),
                  _amPmBox("PM", _period == "PM"),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeBox(String val, bool isHour) {
    int displayVal = isHour ? _selectedHour : _selectedMinute;
    String textVal = displayVal.toString().padLeft(2, '0');

    return GestureDetector(
      onTap: () async {
        TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
            hour: _period == "PM" && _selectedHour != 12 
                ? _selectedHour + 12 
                : (_period == "AM" && _selectedHour == 12 ? 0 : _selectedHour),
            minute: _selectedMinute,
          ),
        );
        if (picked != null && mounted) {
           setState(() {
             _selectedHour = picked.hour > 12 ? picked.hour - 12 : (picked.hour == 0 ? 12 : picked.hour);
             _selectedMinute = picked.minute;
             _period = picked.period == DayPeriod.pm ? "PM" : "AM";
           });
        }
      },
      child: Container(
        width: 60.r,
        height: 45.r,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: Text(
            textVal,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }

  Widget _amPmBox(String val, bool selected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _period = val;
        });
      },
      child: Container(
        width: 35.w,
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: selected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          border: selected ? null : Border.all(color: Colors.black12),
        ),
        child: Center(
          child: Text(
            val,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : Colors.black38,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRemindMeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Remind me",
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
        ),
        Switch(
          value: _remindMe,
          onChanged: (val) => setState(() => _remindMe = val),
          activeColor: Colors.blue,
        ),
      ],
    );
  }

  Future<void> _handleSchedulePost() async {
    setState(() => _isApiLoading = true);

    try {
      int hour24;
      int processMinute;

      if (_selectedTimeMode == "Any Time") {
        final now = DateTime.now();
        hour24 = now.hour;
        processMinute = now.minute;
      } else {
        hour24 = _selectedHour;
        processMinute = _selectedMinute;
        if (_period == "PM" && hour24 < 12) hour24 += 12;
        if (_period == "AM" && hour24 == 12) hour24 = 0;
      }

      final DateTime scheduledDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        hour24,
        processMinute,
      );

      final String formattedDate =
          "${scheduledDateTime.year}-${scheduledDateTime.month.toString().padLeft(2, '0')}-${scheduledDateTime.day.toString().padLeft(2, '0')}";
      final String formattedTime =
          "${scheduledDateTime.hour.toString().padLeft(2, '0')}:${scheduledDateTime.minute.toString().padLeft(2, '0')}";

      final Map<String, dynamic> scheduledAt = {
        "type": "single",
        "date": formattedDate,
        "time": formattedTime,
      };

      final List<String> selectedPlatformsList = [_platforms[_selectedPlatformIndex].toLowerCase()];

      // Get a valid story template ID
      final String templateId = _storyTemplateId;

      if (templateId.isEmpty) {
        Get.snackbar(
          "Error",
          "No story template found. Please try again later.",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Call API for Story creation
      final response = await ContentService.createContent(
        templateId: templateId,
        caption: "Story ${DateFormat('MMM dd, hh:mm a').format(DateTime.now())}",
        files: widget.files,
        contentType: "story",
        scheduledAt: scheduledAt,
        remindMe: _remindMe,
        platform: selectedPlatformsList,
        tags: [],
        preferredLanguages: ["en"],
      );

      if (response.isSuccess) {
        if (mounted) {
          setState(() {
            _showCongratulation = true;
          });
        }
      } else {
        Get.snackbar(
          "Export Failed",
          response.errorMessage ?? "Failed to upload story",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isApiLoading = false);
      }
    }
  }

  Widget _buildScheduleButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: _isApiLoading ? null : _handleSchedulePost,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0080FF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
        ),
        child: _isApiLoading
            ? SizedBox(
                width: 24.r,
                height: 24.r,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                "Schedule Post",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
