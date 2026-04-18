import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:clip_frame/core/widgets/custom_back_button.dart';
import 'package:clip_frame/features/post/presenatation/widget2/MediaDisplayWidget.dart';
import 'package:clip_frame/features/story_creation/story_schedule.dart';
import 'package:get/get.dart';

class StoryFinalPreviewPage extends StatefulWidget {
  final List<File> files;

  const StoryFinalPreviewPage({super.key, required this.files});

  @override
  State<StoryFinalPreviewPage> createState() => _StoryFinalPreviewPageState();
}

class _StoryFinalPreviewPageState extends State<StoryFinalPreviewPage> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Final Media Render Preview
          PageView.builder(
            controller: _pageController,
            itemCount: widget.files.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final file = widget.files[index];
              return Center(
                child: MediaDisplayWidget(
                  videoUrl: file.path, 
                  autoPlay: true,
                ),
              );
            },
          ),

          // 2. Custom Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CustomBackButton(backgroundColor: Colors.black38, iconColor: Colors.white),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        "Final Preview",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40), // Balance
                  ],
                ),
              ),
            ),
          ),

          // 3. Multi-item indicator (if more than 1)
          if (widget.files.length > 1)
            Positioned(
              top: 100.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.files.asMap().entries.map((entry) {
                  return Container(
                    width: 8.r,
                    height: 8.r,
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == entry.key ? Colors.white : Colors.white38,
                    ),
                  );
                }).toList(),
              ),
            ),

          // 4. Bottom Action
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Review your finalized story with logo & music.",
                      style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: double.infinity,
                      height: 55.h,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.to(() => StorySchedulePage(files: widget.files));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91E63),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                        ),
                        child: Text(
                          "CONTINUE TO SCHEDULE",
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
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
    );
  }
}
