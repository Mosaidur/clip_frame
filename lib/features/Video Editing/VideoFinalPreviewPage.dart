import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class VideoFinalPreviewPage extends StatefulWidget {
  final File videoFile;
  final String caption;
  final List<String> hashtags;

  const VideoFinalPreviewPage({
    super.key,
    required this.videoFile,
    required this.caption,
    required this.hashtags,
  });

  @override
  State<VideoFinalPreviewPage> createState() => _VideoFinalPreviewPageState();
}

class _VideoFinalPreviewPageState extends State<VideoFinalPreviewPage> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _showControls = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      // Small delay to allow previous screen's player to fully release hardware resources
      await Future.delayed(const Duration(milliseconds: 500));
      
      debugPrint("Initializing Video Player with: ${widget.videoFile.path}");
      
      if (!await widget.videoFile.exists()) {
        setState(() {
          _errorMessage = "File not found at: ${widget.videoFile.path}";
        });
        return;
      }

      _controller = VideoPlayerController.file(widget.videoFile);
      
      await _controller.initialize();
      
      if (mounted) {
        setState(() {
          _initialized = true;
        });
        await _controller.setLooping(true);
        await _controller.play();
        _controller.addListener(() {
          if (mounted) setState(() {});
        });
      }
    } catch (e) {
      debugPrint("Video initialization error: $e");
      if (mounted) {
        setState(() {
          _errorMessage = "Playback Error: $e";
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Full Screen Video
            GestureDetector(
              onTap: () {
                setState(() {
                  _showControls = !_showControls;
                });
              },
              child: Center(
                child: _initialized
                    ? SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controller.value.size.width,
                            height: _controller.value.size.height,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                      )
                    : _errorMessage != null
                        ? Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, color: Colors.red, size: 50.r),
                                SizedBox(height: 10.h),
                                Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                                ),
                              ],
                            ),
                          )
                        : const CircularProgressIndicator(color: Colors.white),
              ),
            ),

            // Back Button
            Positioned(
              top: MediaQuery.of(context).padding.top + 10.h,
              left: 20.w,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded, size: 20.r, color: Colors.white),
                ),
              ),
            ),

            // Top Overlays (Caption & Hashtags)
            Positioned(
              top: MediaQuery.of(context).padding.top + 80.h,
              left: 20.w,
              right: 20.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Caption Card
                  Container(
                    padding: EdgeInsets.all(15.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15.r),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Text(
                      widget.caption,
                      style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Hashtags Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: widget.hashtags.map((tag) {
                        return Container(
                          margin: EdgeInsets.only(right: 8.w),
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Center Play/Seek Controls
            if (_showControls && _initialized)
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildControlButton(Icons.replay_10_rounded, () {
                      _controller.seekTo(_controller.value.position - const Duration(seconds: 10));
                    }),
                    SizedBox(width: 30.w),
                    _buildControlButton(
                      _controller.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      () {
                        setState(() {
                          _controller.value.isPlaying ? _controller.pause() : _controller.play();
                        });
                      },
                      isLarge: true,
                    ),
                    SizedBox(width: 30.w),
                    _buildControlButton(Icons.forward_10_rounded, () {
                      _controller.seekTo(_controller.value.position + const Duration(seconds: 10));
                    }),
                  ],
                ),
              ),

            // Bottom Seek Bar & Progress
            Positioned(
              bottom: 100.h,
              left: 20.w,
              right: 20.w,
              child: _initialized
                  ? Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(_controller.value.position), style: TextStyle(color: Colors.white, fontSize: 12.sp)),
                            Text(_formatDuration(_controller.value.duration), style: TextStyle(color: Colors.white, fontSize: 12.sp)),
                          ],
                        ),
                        VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            playedColor: Colors.white,
                            bufferedColor: Colors.white24,
                            backgroundColor: Colors.white10,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ),

            // Bottom Done Button
            Positioned(
              bottom: 30.h,
              left: 20.w,
              right: 20.w,
              child: SizedBox(
                width: double.infinity,
                height: 55.h,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to Home or specific completion page
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0080FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                    elevation: 0,
                  ),
                  child: Text(
                    "Done",
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onTap, {bool isLarge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isLarge ? 15.r : 10.r),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: isLarge ? 40.sp : 30.sp),
      ),
    );
  }
}
