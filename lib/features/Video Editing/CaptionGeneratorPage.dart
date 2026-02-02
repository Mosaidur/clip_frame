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
  String selectedTone = "BOLD";
  final TextEditingController _suggestionController = TextEditingController();

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
            colors: [
              Color(0xFFF8E9D2),
              Color(0xFFB49EF4),
            ], // Adjusting to match the design (Peach to Purple)
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
                        "Caption Generator",
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Let AI help you create your post description",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                      SizedBox(height: 30.h),

                      // Input Card
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
                              "Your Tone",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 15.w),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedTone,
                                  isExpanded: true,
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  items:
                                      [
                                            "BOLD",
                                            "CASUAL",
                                            "FUNNY",
                                            "PROFESSIONAL",
                                          ]
                                          .map(
                                            (tone) => DropdownMenuItem(
                                              value: tone,
                                              child: Row(
                                                children: [
                                                  const Text("👊 "),
                                                  Text(
                                                    tone,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      selectedTone = val!;
                                    });
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              "Caption Suggestions",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            TextField(
                              controller: _suggestionController,
                              decoration: InputDecoration(
                                hintText:
                                    "What would you like to add to the caption",
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

                      // Generated Caption Section
                      _buildSectionHeader("Your Generated Caption"),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Text(
                          "“Check out our sizzling lunch specials! 🍕🍕 Come hungry, leave happy. #FoodieLove”",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black.withOpacity(0.8),
                            height: 1.5,
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Emoji Suggestions
                      _buildSectionHeader("Emoji Suggestions"),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(15.r),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFE8E1FF,
                          ), // Light purple back for emojis
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Row(
                          children: [
                            _buildEmojiTile("🍕"),
                            SizedBox(width: 10.w),
                            _buildEmojiTile("🧀"),
                            SizedBox(width: 10.w),
                            _buildEmojiTile("🌮"),
                            SizedBox(width: 10.w),
                            _buildEmojiTile("🥩"),
                          ],
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Hashtag Suggestions
                      _buildSectionHeader("Hashtag Suggestions"),
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
                            _buildHashtagTile("#Foodielover"),
                            _buildHashtagTile("#Foodielover"),
                            _buildHashtagTile("#Foodielover"),
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
                                "“Check out our sizzling lunch specials! 🍕🍕 Come hungry, leave happy. #FoodieLove”";
                            final List<String> currentHashtags = [
                              "#Foodielover",
                              "#Foodielover",
                              "#Foodielover",
                            ];

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

  Widget _buildSectionHeader(String title) {
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
          Icon(Icons.refresh, color: const Color(0xFF0080FF), size: 20.sp),
        ],
      ),
    );
  }

  Widget _buildEmojiTile(String emoji) {
    return Container(
      width: 45.r,
      height: 45.r,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: 20.sp)),
      ),
    );
  }

  Widget _buildHashtagTile(String tag) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        tag,
        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
      ),
    );
  }
}
