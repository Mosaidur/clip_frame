import 'package:clip_frame/core/services/api_services/content_service.dart';
import 'package:clip_frame/features/post/presenatation/Screen_2/schedule_post_screen.dart';
import 'package:clip_frame/features/schedule/data/model.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';

class SchedulingSuccessScreen extends StatefulWidget {
  final String? imageUrl;
  final String mediaPath;
  final List<String>? imagePaths;
  final bool isImage;
  final String? caption;
  final List<String>? hashtags;
  final DateTime scheduledDateTime;
  final String? contentId; // Added contentId for API calls

  const SchedulingSuccessScreen({
    super.key,
    required this.mediaPath,
    required this.scheduledDateTime,
    this.imageUrl,
    this.imagePaths,
    this.isImage = true,
    this.caption,
    this.hashtags,
    this.contentId,
  });

  @override
  State<SchedulingSuccessScreen> createState() =>
      _SchedulingSuccessScreenState();
}

class _SchedulingSuccessScreenState extends State<SchedulingSuccessScreen> {
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();

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
                          "${DateFormat('EEE, d MMM yyyy').format(widget.scheduledDateTime)}\n${DateFormat('hh:mm a').format(widget.scheduledDateTime)}",
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
                  widget.caption ??
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
                  widget.hashtags?.join(' ') ??
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
    // If there are multiple images, show carousel
    if (widget.imagePaths != null && widget.imagePaths!.length > 1) {
      return Column(
        children: [
          CarouselSlider(
            items: widget.imagePaths!.map((path) {
              return Container(
                width: double.infinity,
                color: Colors.black,
                child: Image.file(
                  File(path),
                  fit: BoxFit.contain, // Maintain original aspect ratio
                ),
              );
            }).toList(),
            carouselController: _controller,
            options: CarouselOptions(
              height: 300.h, // Increased height for better visibility
              viewportFraction: 1.0,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              },
            ),
          ),
          if (widget.imagePaths!.length > 1)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.imagePaths!.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => _controller.animateToPage(entry.key),
                    child: Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black)
                                .withOpacity(_current == entry.key ? 0.9 : 0.2),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      );
    }

    bool isVideoFile = !widget.isImage;
    if (widget.mediaPath.isNotEmpty) {
      if (_isVideoUrl(widget.mediaPath)) isVideoFile = true;
    }
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      if (_isVideoUrl(widget.imageUrl!)) isVideoFile = true;
    }

    // 1. If imageUrl is available and it looks like a URL
    if (widget.imageUrl != null && widget.imageUrl!.startsWith('http')) {
      if (isVideoFile) {
        return _buildVideoThumbnail(widget.imageUrl!);
      }
      return Container(
        height: 300.h,
        width: double.infinity,
        color: Colors.black,
        child: Image.network(
          widget.imageUrl!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildErrorIcon(),
        ),
      );
    }

    // 2. Otherwise try to use local file if path is not empty
    if (widget.mediaPath.isNotEmpty && !widget.mediaPath.startsWith('http')) {
      try {
        final file = File(widget.mediaPath);
        if (file.existsSync()) {
          if (isVideoFile) {
            return _buildVideoThumbnail(widget.mediaPath);
          }
          return Container(
            height: 300.h,
            width: double.infinity,
            color: Colors.black,
            child: Image.file(
              file,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => _buildErrorIcon(),
            ),
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
    final lowercase = url.toLowerCase();
    return lowercase.endsWith('.mp4') ||
        lowercase.endsWith('.mov') ||
        lowercase.endsWith('.avi') ||
        lowercase.endsWith('.mkv');
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
          widget.isImage
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
          onTap: _handleEdit,
        ),
        SizedBox(width: 10.w),
        _buildActionButton(
          Icons.copy_rounded,
          "Duplicate",
          const Color(0xFF916BFF),
          onTap: () {
            // Placeholder for duplicate logic
            Get.snackbar("Notice", "Duplicate feature coming soon");
          },
        ),
        SizedBox(width: 10.w),
        _buildActionButton(
          Icons.delete_outline_rounded,
          "Delete",
          const Color(0xFFFF3B30),
          onTap: _confirmDelete,
        ),
      ],
    );
  }

  void _handleEdit() {
    // If we have contentId, we can pass it as postToEdit
    // We create a dummy SchedulePost object since that's what the screen expects
    if (widget.contentId != null) {
      final postToEdit = SchedulePost(
        id: widget.contentId!,
        imageUrl: widget.imageUrl ?? widget.mediaPath,
        thumbnailUrl: widget.imageUrl ?? widget.mediaPath,
        title: widget.caption ?? "",
        tags: widget.hashtags ?? [],
        scheduleTime: DateFormat('hh:mm a').format(widget.scheduledDateTime),
        rawScheduleTime: widget.scheduledDateTime.toIso8601String(),
        status: 'scheduled',
        contentType: widget.isImage ? 'post' : 'reel',
        createdAt: DateTime.now(),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SchedulePostScreen(
            mediaPath: widget.mediaPath,
            imagePaths: widget.imagePaths,
            isImage: widget.isImage,
            postToEdit: postToEdit,
          ),
        ),
      );
    } else {
      // If no ID, just go back to the previous screen (which is likely the schedule screen)
      Navigator.pop(context);
    }
  }

  void _confirmDelete() {
    if (widget.contentId == null) {
      Get.snackbar("Error", "Content ID not found. Cannot delete.");
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Schedule"),
        content: const Text(
          "Are you sure you want to delete this scheduled post?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSchedule();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSchedule() async {
    try {
      final response = await ContentService.deleteContent(widget.contentId!);
      if (response.isSuccess) {
        Get.snackbar(
          "Success",
          "Schedule deleted successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Go back to dashboard
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        Get.snackbar(
          "Error",
          response.errorMessage ?? "Failed to delete schedule",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
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
