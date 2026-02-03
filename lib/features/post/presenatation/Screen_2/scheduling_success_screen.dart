import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';

class SchedulingSuccessScreen extends StatelessWidget {
  final String? imageUrl;
  final String mediaPath;
  final bool isImage;
  final String? caption;
  final List<String>? hashtags;
  final DateTime scheduledDateTime;

  const SchedulingSuccessScreen({
    super.key,
    required this.mediaPath,
    required this.scheduledDateTime,
    this.imageUrl,
    this.isImage = true,
    this.caption,
    this.hashtags,
  });

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
            colors: [Color(0xFFF3E5D8), Color(0xFFFFFFFF), Color(0xFFDCD4F2)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 30.h),
                Text(
                  "Successfully Scheduled!",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  "Your content has been successfully\nscheduled.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.sp, color: Colors.black54),
                ),
                SizedBox(height: 30.h),
                _buildScheduledPostCard(),
                SizedBox(height: 30.h),
                _buildActionButtons(),
                SizedBox(height: 20.h),
                _buildBackToDashboardButton(context),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduledPostCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.r),
              topRight: Radius.circular(25.r),
            ),
            child: _buildMediaPreview(),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Platform:",
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.black45,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.facebook,
                              color: const Color(0xFF1877F2),
                              size: 18.sp,
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.camera_alt,
                              color: const Color(0xFFE4405F),
                              size: 18.sp,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Scheduled for:",
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.black45,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "${DateFormat('EEE, d MMM yyyy').format(scheduledDateTime)}\n${DateFormat('hh:mm a').format(scheduledDateTime)}",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Text(
                  "Caption:",
                  style: TextStyle(fontSize: 10.sp, color: Colors.black45),
                ),
                SizedBox(height: 4.h),
                Text(
                  caption ??
                      "“Check out our sizzling lunch specials! 🍕🍕 Come hungry, leave happy. #FoodieLove“",
                  style: TextStyle(fontSize: 12.sp, color: Colors.black87),
                ),
                SizedBox(height: 20.h),
                Text(
                  "Tags:",
                  style: TextStyle(fontSize: 10.sp, color: Colors.black45),
                ),
                SizedBox(height: 4.h),
                Text(
                  hashtags?.join(' ') ??
                      "#FoodieLove #FoodieLove #FoodieLove #FoodieLove",
                  style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview() {
    bool isVideoFile = !isImage;
    if (mediaPath.isNotEmpty) {
      if (_isVideoUrl(mediaPath)) isVideoFile = true;
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (_isVideoUrl(imageUrl!)) isVideoFile = true;
    }

    // 1. If imageUrl is available and it looks like a URL
    if (imageUrl != null && imageUrl!.startsWith('http')) {
      if (isVideoFile) {
        return _buildVideoThumbnail(imageUrl!);
      }
      return Image.network(
        imageUrl!,
        height: 250.h,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorIcon(),
      );
    }

    // 2. Otherwise try to use local file if path is not empty
    if (mediaPath.isNotEmpty && !mediaPath.startsWith('http')) {
      try {
        final file = File(mediaPath);
        if (file.existsSync()) {
          if (isVideoFile) {
            return _buildVideoThumbnail(mediaPath);
          }
          return Image.file(
            file,
            height: 250.h,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildErrorIcon(),
          );
        }
      } catch (e) {
        debugPrint("Error loading local file: $e");
      }
    }

    // Default placeholder
    return _buildErrorIcon();
  }

  bool _isVideoUrl(String url) {
    if (url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      final path = uri.path.toLowerCase();
      return path.endsWith('.mp4') ||
          path.endsWith('.mov') ||
          path.endsWith('.avi') ||
          path.endsWith('.mkv');
    } catch (e) {
      final lowercase = url.toLowerCase();
      return lowercase.endsWith('.mp4') ||
          lowercase.endsWith('.mov') ||
          lowercase.endsWith('.avi') ||
          lowercase.endsWith('.mkv');
    }
  }

  Widget _buildVideoThumbnail(String pathOrUrl) {
    return FutureBuilder<Uint8List?>(
      future: VideoThumbnail.thumbnailData(
        video: pathOrUrl,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 400,
        quality: 50,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 250.h,
            width: double.infinity,
            color: Colors.black12,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                height: 250.h,
                width: double.infinity,
                errorBuilder: (_, __, ___) => _buildErrorIcon(),
              ),
              Center(
                child: Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 50.r,
                ),
              ),
            ],
          );
        }
        return _buildErrorIcon();
      },
    );
  }

  Widget _buildErrorIcon() {
    return Container(
      height: 250.h,
      width: double.infinity,
      color: Colors.black12,
      child: Center(
        child: Icon(
          isImage
              ? Icons.image_not_supported_outlined
              : Icons.videocam_off_outlined,
          color: Colors.black26,
          size: 50.r,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildActionButton(
          Icons.edit_outlined,
          "Edit",
          const Color(0xFFFFC107),
        ),
        SizedBox(width: 10.w),
        _buildActionButton(
          Icons.copy_rounded,
          "Duplicate",
          const Color(0xFF916BFF),
        ),
        SizedBox(width: 10.w),
        _buildActionButton(
          Icons.delete_outline_rounded,
          "Delete",
          const Color(0xFFFF3B30),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16.sp),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackToDashboardButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55.h,
      child: ElevatedButton(
        onPressed: () {
          // Navigate to some main screen if needed or pop until root
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          elevation: 0,
        ),
        child: Text(
          "Back to Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
