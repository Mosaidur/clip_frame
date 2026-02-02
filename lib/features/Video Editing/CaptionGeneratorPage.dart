import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'VideoFinalPreviewPage.dart';
import 'package:clip_frame/features/post/presenatation/controller/content_creation_controller.dart';

class CaptionGeneratorPage extends StatefulWidget {
  final File videoFile;
  const CaptionGeneratorPage({super.key, required this.videoFile});

  @override
  State<CaptionGeneratorPage> createState() => _CaptionGeneratorPageState();
}

class _CaptionGeneratorPageState extends State<CaptionGeneratorPage> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _hashtagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill from controller if exists
    if (Get.isRegistered<ContentCreationController>()) {
      final controller = Get.find<ContentCreationController>();
      _captionController.text = controller.caption.value;
      _hashtagController.text = controller.hashtags.join(' ');
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _hashtagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8E9D2), Color(0xFFB49EF4)],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          body: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 10.h,
                  left: 20.w,
                  right: 20.w,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: const BoxDecoration(
                          color: Color(0xFFDCC8B0),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20.r,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      Text(
                        "Add Post Details",
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Enter your caption and hashtags below",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                      SizedBox(height: 30.h),

                      // Caption Input Card
                      Container(
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Write Caption",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            TextField(
                              controller: _captionController,
                              maxLines: 5,
                              style: TextStyle(fontSize: 14.sp),
                              decoration: InputDecoration(
                                hintText: "Enter your caption here...",
                                hintStyle: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey,
                                ),
                                contentPadding: EdgeInsets.all(15.r),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Hashtags Input Card
                      Container(
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hashtags",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            TextField(
                              controller: _hashtagController,
                              style: TextStyle(fontSize: 14.sp),
                              decoration: InputDecoration(
                                hintText: "e.g. #trending #food #daily",
                                hintStyle: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey,
                                ),
                                contentPadding: EdgeInsets.all(15.r),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Emoji Quick Select
                      _buildSectionHeader("Quick Emoji", showRefresh: false),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(15.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8E1FF),
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Wrap(
                          spacing: 10.w,
                          runSpacing: 10.h,
                          children: [
                            _buildEmojiTile("🍕"),
                            _buildEmojiTile("🔥"),
                            _buildEmojiTile("❤️"),
                            _buildEmojiTile("🙌"),
                            _buildEmojiTile("✨"),
                            _buildEmojiTile("🎬"),
                            _buildEmojiTile("😎"),
                          ],
                        ),
                      ),

                      SizedBox(height: 40.h),

                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 55.h,
                        child: ElevatedButton(
                          onPressed: () {
                            final String currentCaption =
                                _captionController.text;
                            final List<String> currentHashtags =
                                _hashtagController.text
                                    .split(' ')
                                    .where((s) => s.isNotEmpty)
                                    .toList();

                            // Save to controller
                            if (Get.isRegistered<ContentCreationController>()) {
                              final controller =
                                  Get.find<ContentCreationController>();
                              controller.caption.value = currentCaption;
                              controller.hashtags.assignAll(currentHashtags);
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VideoFinalPreviewPage(
                                  videoFile: widget.videoFile,
                                  caption: currentCaption,
                                  hashtags: currentHashtags,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0080FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool showRefresh = true}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (showRefresh)
            Icon(Icons.refresh, color: const Color(0xFF0080FF), size: 20.sp),
        ],
      ),
    );
  }

  Widget _buildEmojiTile(String emoji) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _captionController.text += emoji;
        });
      },
      child: Container(
        width: 45.r,
        height: 45.r,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: Text(emoji, style: TextStyle(fontSize: 20.sp)),
        ),
      ),
    );
  }
}
