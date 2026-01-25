import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'story_review_shots.dart';

class StoryPreviewPage extends StatelessWidget {
  final File file;
  final bool isVideo;
  final bool isAddingMore;

  const StoryPreviewPage({
    super.key, 
    required this.file, 
    required this.isVideo,
    this.isAddingMore = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Media Preview
          Center(
            child: isVideo
                ? const Icon(Icons.play_circle_fill, color: Colors.white, size: 80) // Placeholder for video player
                : Image.file(file, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
          ),

          // 2. Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                        child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.r),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text("Preview", style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    SizedBox(width: 48.w), // Spacer to balance
                  ],
                ),
              ),
            ),
          ),

          // 3. Bottom Actions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
                child: Row(
                  children: [
                    // Retake Button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 50.r,
                        height: 50.r,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.refresh_rounded, color: Colors.blueAccent, size: 30.r),
                      ),
                    ),
                    SizedBox(width: 20.w),
                    // Continue Button
                    Expanded(
                      child: SizedBox(
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: () {
                            if (isAddingMore) {
                              Navigator.pop(context, file);
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StoryReviewShotsPage(initialFiles: [file]),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0080FF),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          child: Text("Continue", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
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
