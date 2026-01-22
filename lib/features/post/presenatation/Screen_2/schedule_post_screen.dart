import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'scheduling_success_screen.dart';

class SchedulePostScreen extends StatefulWidget {
  final String mediaPath;
  final String? caption;
  final List<String>? hashtags;
  final bool isImage;

  const SchedulePostScreen({
    super.key,
    required this.mediaPath,
    this.caption,
    this.hashtags,
    this.isImage = true,
  });

  @override
  State<SchedulePostScreen> createState() => _SchedulePostScreenState();
}

class _SchedulePostScreenState extends State<SchedulePostScreen> {
  String selectedPlatform = "Facebook";
  String selectedTimeMode = "Time";
  bool remindMe = true;
  int selectedHour = 5;
  int selectedMinute = 0;
  String period = "PM";
  int selectedDateIndex = 11;

  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;

  final List<String> platforms = ["Facebook", "Instagram", "Tiktok"];
  final List<String> timeModes = ["Any Time", "Time", "Range"];

  @override
  void initState() {
    super.initState();
    hourController = FixedExtentScrollController(initialItem: selectedHour == 12 ? 0 : selectedHour);
    minuteController = FixedExtentScrollController(initialItem: selectedMinute);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSuggestedDialog();
    });
  }

  @override
  void dispose() {
    hourController.dispose();
    minuteController.dispose();
    super.dispose();
  }

  void _showSuggestedDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF2D78),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.info_outline_rounded, color: Colors.white, size: 30.sp),
              ),
              SizedBox(height: 20.h),
              Text(
                "Suggested Scheduling Option",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.h),
              Text(
                "After going through content our Ai suggest the best time to post your content.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.sp, color: Colors.black54),
              ),
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F1FF),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tuesday",
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF007AFF)),
                    ),
                    Text(
                      "05:00 PM",
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF2D78),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        elevation: 0,
                      ),
                      child: Text("Schedule", style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  SizedBox(width: 12.w),
                  
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        elevation: 0,
                      ),
                      child: Text("Choose different date", style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
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

  @override
  Widget build(BuildContext context){
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEFE2C2), // Soft tan/yellow top
              Color(0xFFF7F7F7), // Neutral middle
              Color(0xFFE5DDF9), // Light purple bottom
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
        
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 10.h),
                _buildAppBar(),
                SizedBox(height: 30.h),
                Text(
                  "Schedule Your Post",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                SizedBox(height: 10.h),
                Text(
                  "Select platform ad pick the best time to\npublish.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.sp, color: Colors.black45, height: 1.4),
                ),
                SizedBox(height: 30.h),
                _buildPlatformChips(),
                SizedBox(height: 30.h),
                _buildCalendarSection(),
                SizedBox(height: 30.h),
                _buildTimeModeSelector(),
                SizedBox(height: 20.h),
                _buildTimePicker(),
                SizedBox(height: 20.h),
                _buildReminderSection(),
                SizedBox(height: 30.h),
                _buildScheduleButton(),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20.sp),
        ),
      ),
    );
  }

  Widget _buildPlatformChips() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12.w,
      runSpacing: 12.h,
      children: [
        _buildPlatformChip("Facebook", Icons.facebook, const Color(0xFF1877F2)),
        _buildPlatformChip("Instagram", Icons.camera_alt, const Color(0xFFE4405F)),
        _buildPlatformChip("Tiktok", Icons.music_note, Colors.black),
      ],
    );
  }

  Widget _buildPlatformChip(String name, IconData icon, Color color) {
    bool isSelected = selectedPlatform == name;
    return GestureDetector(
      onTap: () => setState(() => selectedPlatform = name),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.r),
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              name,
              style: TextStyle(
                fontSize: 14.sp,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10.r)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Schedule date", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].map((d) => Text(d, style: TextStyle(fontSize: 10.sp, color: Colors.black38))).toList(),
          ),
          SizedBox(height: 10.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
            itemCount: 35,
            itemBuilder: (context, index) {
               // Roughly matching design june 2025 start sun
              int dayNum = index - 4; // adjusted to match design roughly
              if (index < 5) dayNum = 31 - (4 - index);
              if (index > 34) dayNum = index - 34;
              
              bool isSelected = index == selectedDateIndex;
              bool isDimmed = index < 5 || dayNum > 30;
              if (dayNum < 1) dayNum = 31 + dayNum;
               if (dayNum > 30) dayNum = dayNum - 30;

              return GestureDetector(
                onTap: () => setState(() => selectedDateIndex = index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFF2D78) : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        dayNum.toString(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isSelected ? Colors.white : (isDimmed ? Colors.black26 : const Color(0xFF636D91)),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (!isSelected && !isDimmed) ...[
                      SizedBox(height: 2.h),
                      _buildDateDots(index),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateDots(int index) {
    // Semi-mocked dots to match screenshot
    List<Color> dotColors = [];
    if (index % 3 == 0) dotColors = [const Color(0xFF007AFF)];
    if (index % 5 == 0) dotColors = [const Color(0xFFFF2D78), const Color(0xFF007AFF)];
    if (index % 7 == 0) dotColors = [const Color(0xFF007AFF), const Color(0xFFFF2D78), Colors.black];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: dotColors.map((c) => Container(
        margin: EdgeInsets.symmetric(horizontal: 1.w),
        width: 3.r,
        height: 3.r,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      )).toList(),
    );
  }

  Widget _buildTimeModeSelector() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: Row(
        children: timeModes.map((mode) {
          bool isSelected = selectedTimeMode == mode;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTimeMode = mode),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  gradient: isSelected ? const LinearGradient(
                    colors: [Color(0xFFFF52D9), Color(0xFFB53CFF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ) : null,
                ),
                child: Text(
                  mode,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.sp, color: isSelected ? Colors.white : Colors.black45, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimePicker() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 15.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10.r)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTimeWheel(12, true),
          Text("  :  ", style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
          _buildTimeWheel(60, false),
          SizedBox(width: 20.w),
          Column(
            children: [
              _buildPeriodToggle("AM"),
              SizedBox(height: 4.h),
              _buildPeriodToggle("PM"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeWheel(int max, bool isHour) {
    return Container(
      height: 60.h,
      width: 70.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.black12),
      ),
      child: ListWheelScrollView.useDelegate(
        controller: isHour ? hourController : minuteController,
        itemExtent: 40.h,
        diameterRatio: 1.2,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          setState(() {
            if (isHour) {
              selectedHour = (index % 12) == 0 ? 12 : (index % 12);
            } else {
              selectedMinute = index % 60;
            }
          });
        },
        childDelegate: ListWheelChildLoopingListDelegate(
          children: List.generate(max, (index) {
            int displayVal = isHour ? (index == 0 ? 12 : index) : index;
            String text = displayVal.toString().padLeft(2, '0');
            bool isSelected = isHour ? selectedHour == displayVal : selectedMinute == displayVal;
            return Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFF007AFF) : Colors.blueGrey[700],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPeriodToggle(String p) {
    bool isSelected = period == p;
    return GestureDetector(
      onTap: () => setState(() => period = p),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF007AFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.black12),
        ),
        child: Text(p, style: TextStyle(fontSize: 10.sp, color: isSelected ? Colors.white : Colors.black45, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildReminderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Remind me", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
        Switch(
          value: remindMe,
          onChanged: (v) => setState(() => remindMe = v),
          activeColor: const Color(0xFF007AFF),
        ),
      ],
    );
  }

  Widget _buildScheduleButton() {
    return SizedBox(
      width: double.infinity,
      height: 55.h,
      child: ElevatedButton(
        onPressed: () {
          _showCongratulationsOverlay();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
          elevation: 0,
        ),
        child: Text("Schedule Post", style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showCongratulationsOverlay() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                   Image.asset(
                    'assets/images/image.png',
                    width: 100.w,
                    height: 100.h,
                    fit: BoxFit.contain,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(2.r),
                      decoration: const BoxDecoration(color: Color(0xFF007AFF), shape: BoxShape.circle),
                      child: Icon(Icons.check, color: Colors.white, size: 12.sp),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Text(
                "Congratulations!",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.h),
              Text(
                "Your content are successfully created and scheduled.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.sp, color: Colors.black54),
              ),
              SizedBox(height: 25.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SchedulingSuccessScreen(
                          mediaPath: widget.mediaPath,
                          isImage: widget.isImage,
                          caption: widget.caption,
                          hashtags: widget.hashtags,
                          scheduledTime: "${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')} $period",
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text("Continue", style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
