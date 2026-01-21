import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'CaptionGeneratorPage.dart';

class AiVideoEditPage extends StatefulWidget {
  final File videoFile;
  const AiVideoEditPage({super.key, required this.videoFile});

  @override
  State<AiVideoEditPage> createState() => _AiVideoEditPageState();
}

class _AiVideoEditPageState extends State<AiVideoEditPage> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState((){
          _initialized = true;
        });
        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFB49EF4), Color(0xFFEBC894)],
          ),
        ),
        child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            // Status bar spacer or just let background flow
            SizedBox(height: MediaQuery.of(context).padding.top),
            // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: const BoxDecoration(
                          color: Color(0xFFDCC8B0),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded, size: 20.r, color: Colors.black),
                      ),
                    ),
                    Text(
                      "Ai Video Edit",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: const BoxDecoration(
                        color: Color(0xFFACAAAA),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.grid_view_rounded, size: 20.r, color: Colors.black),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Video Preview Card
                      Container(
                        height: 350.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20.r),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _controller.value.isPlaying ? _controller.pause() : _controller.play();
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.black,
                                  child: _initialized
                                      ? Center(
                                          child: AspectRatio(
                                            aspectRatio: _controller.value.aspectRatio,
                                            child: VideoPlayer(_controller),
                                          ),
                                        )
                                      : const Center(child: CircularProgressIndicator(color: Colors.white)),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 15.h,
                              right: 15.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.auto_awesome, color: Colors.white, size: 14.sp),
                                    SizedBox(width: 4.w),
                                    Text(
                                      "Enhance",
                                      style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_initialized && !_controller.value.isPlaying)
                              const Center(
                                child: Icon(Icons.play_arrow, size: 60, color: Colors.white70),
                              ),
                          ],
                        ),
                      ),

                      SizedBox(height: 15.h),

                      // Thumbnails Row
                      Row(
                        children: List.generate(3, (index) {
                          return Container(
                            margin: EdgeInsets.only(right: 10.w),
                            width: 60.w,
                            height: 60.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              image: DecorationImage(
                                image: AssetImage("assets/images/${index + 1}.jpg"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }),
                      ),

                      SizedBox(height: 25.h),

                      // Large Enhancement Buttons
                      _buildLargeButton(
                        label: "Enhance video quality",
                        color: const Color(0xFFD44BFF),
                        onTap: () {},
                      ),
                      SizedBox(height: 12.h),
                      _buildLargeButton(
                        label: "Add voiceover suggestion",
                        color: const Color(0xFF2E76FF),
                        onTap: () {},
                      ),

                      SizedBox(height: 15.h),

                      // Small Action Buttons Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildSmallButton(
                              label: "Add logo overlay",
                              icon: Icons.add,
                              color: const Color(0xFFF1D5A7),
                              onTap: () {},
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildSmallButton(
                              label: "Add watermark",
                              icon: Icons.add,
                              color: const Color(0xFFCDC1F4),
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 25.h),

                      Text(
                        "Select Background music",
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height: 12.h),
                      
                      // Music Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildMusicChip("Calm Vibe (AI)", Icons.music_note, true),
                            SizedBox(width: 10.w),
                            _buildMusicChip("Uplifting Promo", Icons.music_note, false),
                            SizedBox(width: 10.w),
                            _buildMusicChip("Upload", Icons.cloud_upload_outlined, false),
                          ],
                        ),
                      ),

                      SizedBox(height: 30.h),

                      // Bottom Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_initialized) _controller.pause();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CaptionGeneratorPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0080FF),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            elevation: 0,
                          ),
                          child: Text(
                            "Save",
                            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
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

  Widget _buildLargeButton({required String label, required Color color, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          elevation: 0,
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSmallButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20.sp, color: Colors.white),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicChip(String label, IconData icon, bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.pink, size: 18.sp),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: Colors.black, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
