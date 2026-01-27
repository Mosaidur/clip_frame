import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StorySchedulePage extends StatefulWidget {
  final List<File> files;

  const StorySchedulePage({super.key, required this.files});

  @override
  State<StorySchedulePage> createState() => _StorySchedulePageState();
}

class _StorySchedulePageState extends State<StorySchedulePage> {
  int _selectedPlatformIndex = 1; // 0: FB, 1: IG, 2: TikTok
  int _selectedStoryIndex = 0;
  bool _remindMe = true;
  bool _showSuggestedDialog = true;
  bool _scheduledSuccess = false;
  bool _showCongratulation = false;
  DateTime _selectedDate = DateTime.now();
  String _selectedTimeMode = "Time"; // "Any Time", "Time", "Range"

  final List<String> _platforms = ["Facebook", "Instagram", "Tiktok"];
  final List<IconData> _platformIcons = [
    Icons.facebook_rounded,
    Icons.camera_alt_rounded, // Placeholder for IG
    Icons.play_circle_fill_rounded, // Placeholder for TikTok
  ];

  @override
  Widget build(BuildContext context) {
    if (_scheduledSuccess) return _buildSuccessView();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF7F3EB),
            ),
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

  Widget _buildSuccessView() {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Color(0xFFE8EAF6)),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Center(
                  child: Container(
                    width: 320.w,
                    padding: EdgeInsets.all(24.r),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30.r)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Successfully Scheduled!", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: Colors.indigo)),
                        SizedBox(height: 8.h),
                        Text("You have successfully scheduled 3 stories content.", textAlign: TextAlign.center, style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
                        SizedBox(height: 25.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20.r),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.file(widget.files[0], height: 180.h, width: double.infinity, fit: BoxFit.cover),
                              Icon(Icons.play_circle_fill_rounded, color: Colors.white70, size: 40.r),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                        _successDetailRow("Platform:", Icons.facebook_rounded, "FB, IG"),
                        SizedBox(height: 12.h),
                        _successDetailRow("Scheduled for:", Icons.calendar_today_rounded, "Tue, Wed, Thu\n05:00 PM, 05:00 PM, 05:00 PM"),
                        SizedBox(height: 25.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _actionBtnVertical(Icons.edit_rounded, "Edit", Colors.orange),
                            _actionBtnVertical(Icons.copy_rounded, "Duplicate", Colors.indigo),
                            _actionBtnVertical(Icons.delete_outline_rounded, "Delete", Colors.pink),
                          ],
                        ),
                        SizedBox(height: 30.h),
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                              elevation: 0,
                            ),
                            child: Text("Back to Dashboard", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white)),
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
      ),
    );
  }

  Widget _successDetailRow(String label, IconData icon, String val) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.black45, fontWeight: FontWeight.w500)),
        const Spacer(),
        Icon(icon, size: 14.r, color: Colors.blue),
        SizedBox(width: 6.w),
        Text(val, textAlign: TextAlign.right, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  Widget _actionBtnVertical(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20.r),
        ),
        SizedBox(height: 6.h),
        Text(label, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: color)),
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
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30.r)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120.r,
                height: 120.r,
                decoration: BoxDecoration(color: const Color(0xFFF3F4FB), shape: BoxShape.circle),
                child: Center(child: Icon(Icons.celebration_rounded, color: const Color(0xFFFF4081), size: 60.r)),
              ),
              SizedBox(height: 25.h),
              Text("Congratulations!", style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: Colors.black)),
              SizedBox(height: 10.h),
              Text("Your content are successfully created and scheduled.", textAlign: TextAlign.center, style: TextStyle(fontSize: 12.sp, color: Colors.black54, fontWeight: FontWeight.w500)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                    elevation: 0,
                  ),
                  child: Text("Continue", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestedDialog() {
    return Container(
      color: Colors.black54,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Container(
          width: 300.w,
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25.r)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(color: const Color(0xFFFFEBF1), borderRadius: BorderRadius.circular(15.r)),
                child: Icon(Icons.info_rounded, color: const Color(0xFFE91E63), size: 30.r),
              ),
              SizedBox(height: 15.h),
              Text("Suggested Scheduling Option", textAlign: TextAlign.center, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: Colors.black)),
              SizedBox(height: 10.h),
              Text("After going through content our AI suggest the best time to post your content.", textAlign: TextAlign.center, style: TextStyle(fontSize: 11.sp, color: Colors.black54, fontWeight: FontWeight.w500)),
              SizedBox(height: 20.h),
              _suggestionItem("Story 1", "Tuesday", "05:00 PM"),
              SizedBox(height: 8.h),
              _suggestionItem("Story 2", "Wednesday", "05:00 PM"),
              SizedBox(height: 8.h),
              _suggestionItem("Story 3", "Thursday", "05:00 PM"),
              SizedBox(height: 25.h),
              Row(
                children: [
                  Expanded(child: _dialogBtn("Schedule", const Color(0xFFE91E63), () => setState(() => _showSuggestedDialog = false))),
                  SizedBox(width: 10.w),
                  Expanded(child: _dialogBtn("Choose different date", const Color(0xFF2196F3), () => setState(() => _showSuggestedDialog = false))),
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
      decoration: BoxDecoration(color: const Color(0xFFE3F2FD).withOpacity(0.5), borderRadius: BorderRadius.circular(12.r)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(story, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.indigo)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(day, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.blue)),
              Text(time, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dialogBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.h,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10.r)),
        child: Center(child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.white))),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(color: const Color(0xFFC4B69E).withOpacity(0.3), shape: BoxShape.circle),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 18.r),
            ),
          ),
          Text("Schedule Your Story", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: Colors.black)),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("DONE", style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900, color: const Color(0xFFE91E63))),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformTabs() {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30.r)),
      child: Row(
        children: List.generate(_platforms.length, (index) {
          bool isSelected = _selectedPlatformIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPlatformIndex = index),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE3F2FD) : Colors.transparent,
                  borderRadius: BorderRadius.circular(25.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_platformIcons[index], size: 16.r, color: isSelected ? Colors.blue : Colors.black45),
                    SizedBox(width: 6.w),
                    Text(_platforms[index], style: TextStyle(fontSize: 11.sp, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500, color: isSelected ? Colors.blue : Colors.black45)),
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
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(widget.files.length, (index) {
            bool isSelected = _selectedStoryIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedStoryIndex = index),
              child: Column(
                children: [
                  Text("Story ${index + 1}", style: TextStyle(fontSize: 12.sp, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? Colors.pink : Colors.black45)),
                  SizedBox(height: 4.h),
                  if (isSelected) Container(width: 40.w, height: 2.h, color: Colors.pink),
                ],
              ),
            );
          }),
        ),
        Divider(height: 1.h, color: Colors.black12),
      ],
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("January 2026", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Icon(Icons.chevron_left_rounded, size: 20.r, color: Colors.black45),
                  Icon(Icons.chevron_right_rounded, size: 20.r, color: Colors.black45),
                ],
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].map((d) => Text(d, style: TextStyle(fontSize: 10.sp, color: Colors.black38))).toList(),
          ),
          SizedBox(height: 15.h),
          // Simplified calendar grid for now
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 10, crossAxisSpacing: 10),
            itemCount: 31,
            itemBuilder: (context, index) {
              int day = index + 1;
              bool isSelected = day == 2; // Demo selection
              return Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.pink : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text("$day", style: TextStyle(fontSize: 12.sp, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.white : Colors.black87)),
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
        Text("Select Time", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(color: const Color(0xFFE8EAF6), borderRadius: BorderRadius.circular(20.r)),
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
                      child: Text(mode, style: TextStyle(fontSize: 11.sp, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? Colors.indigo : Colors.black45)),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _timeBox("00"),
              Text(" : ", style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
              _timeBox("00"),
              SizedBox(width: 20.w),
              Column(
                children: [
                  _amPmBox("AM", true),
                  SizedBox(height: 4.h),
                  _amPmBox("PM", false),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeBox(String val) {
    return Container(
      width: 60.r,
      height: 45.r,
      decoration: BoxDecoration(color: const Color(0xFFF1F1F1), borderRadius: BorderRadius.circular(10.r)),
      child: Center(child: Text(val, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900))),
    );
  }

  Widget _amPmBox(String val, bool selected) {
    return Container(
      width: 35.w,
      padding: EdgeInsets.symmetric(vertical: 2.h),
      decoration: BoxDecoration(
        color: selected ? Colors.blue : Colors.transparent,
        borderRadius: BorderRadius.circular(10.r),
        border: selected ? null : Border.all(color: Colors.black12),
      ),
      child: Center(child: Text(val, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: selected ? Colors.white : Colors.black38))),
    );
  }

  Widget _buildRemindMeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Remind me", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
        Switch(
          value: _remindMe,
          onChanged: (val) => setState(() => _remindMe = val),
          activeColor: Colors.blue,
        ),
      ],
    );
  }


  Widget _buildScheduleButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: () {
          setState(() => _showCongratulation = true);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0080FF),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        ),
        child: Text("Schedule Post", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: Colors.white)),
      ),
    );
  }
}
