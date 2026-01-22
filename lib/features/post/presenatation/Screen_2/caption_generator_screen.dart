import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'schedule_post_screen.dart';

class CaptionGeneratorScreen extends StatefulWidget {
  final String imagePath;

  const CaptionGeneratorScreen({super.key, required this.imagePath});

  @override
  State<CaptionGeneratorScreen> createState() => _CaptionGeneratorScreenState();
}

class _CaptionGeneratorScreenState extends State<CaptionGeneratorScreen> {
  String selectedTone = "BOLD";
  bool logoOverlay = true;

  final List<String> tones = ["BOLD", "PROFESSIONAL", "FRIENDLY", "WITTY", "INSPIRATIONAL"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF3E5D8),
              Color(0xFFFFFFFF),
              Color(0xFFDCD4F2),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10.h),
                Align(
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
                ),
                SizedBox(height: 20.h),
                Text(
                  "Caption Generator",
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  "Let AI help you create your post description",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 30.h),
                _buildCardSection(),
                SizedBox(height: 20.h),
                _buildSuggestionSection("Emoji Suggestions", [
                  "🍕", "🧀", "🌮", "🥩"
                ], true),
                SizedBox(height: 15.h),
                _buildSuggestionSection("Hashtag Suggestions", [
                  "#Foodielover", "#Foodielover", "#Foodielover"
                ], true),
                SizedBox(height: 20.h),
                _buildToggleSection(),
                SizedBox(height: 30.h),
                _buildContinueButton(),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10.r, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Your Tone"),
          SizedBox(height: 8.h),
          _buildToneDropdown(),
          SizedBox(height: 20.h),
          _buildLabel("Caption Suggestions"),
          SizedBox(height: 8.h),
          _buildTextField(),
          SizedBox(height: 30.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLabel("Your Generated Caption"),
              Icon(Icons.refresh_rounded, color: const Color(0xFF007AFF), size: 20.sp),
            ],
          ),
          SizedBox(height: 10.h),
          _buildGeneratedCaptionBox(),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildToneDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedTone,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: tones.map((tone) {
            return DropdownMenuItem(
              value: tone,
              child: Row(
                children: [
                  // Text("👊 ", style: TextStyle(fontSize: 16.sp)),
                  Text(tone, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.blueGrey[700])),
                ],
              ),
            );
          }).toList(),
          onChanged: (v) => setState(() => selectedTone = v!),
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      height: 60.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.black12),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "What would you like to add to the caption",
          hintStyle: TextStyle(fontSize: 12.sp, color: Colors.black38),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildGeneratedCaptionBox() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        "“Check out our sizzling lunch specials! 🍕🍕 Come hungry, leave happy. #FoodieLove“",
        style: TextStyle(
          fontSize: 14.sp,
          color: Colors.black87,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildSuggestionSection(String label, List<String> items, bool showRefresh) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLabel(label),
            if (showRefresh) Icon(Icons.refresh_rounded, color: const Color(0xFF007AFF), size: 20.sp),
          ],
        ),
        SizedBox(height: 10.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: items.map((item) => _buildSuggestionItem(item)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionItem(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4.r)],
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildToggleSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLabel("Logo Overlay"),
        Switch(
          value: logoOverlay,
          onChanged: (v) => setState(() => logoOverlay = v),
          activeColor: const Color(0xFF007AFF),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 55.h,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SchedulePostScreen(mediaPath: widget.imagePath, isImage: true)),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          elevation: 0,
        ),
        child: Text(
          "Continue",
          style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
