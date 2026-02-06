import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:clip_frame/features/post/presenatation/controller/content_creation_controller.dart';
import 'package:clip_frame/features/post/presenatation/Screen_2/schedule_post_screen.dart';
import 'package:clip_frame/features/schedule/presenatation/controller/schedule_controller.dart';
import 'package:clip_frame/features/schedule/presenatation/widgets/schedulePostContent.dart';
import 'package:clip_frame/features/schedule/presenatation/widgets/ScheduledPostPreviewScreen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/model.dart';

class SchedulePostWidget extends StatelessWidget {
  final SchedulePost post;
  const SchedulePostWidget({super.key, required this.post});

  bool _isVideo(SchedulePost post) {
    if (post.imageUrl.isEmpty) return false;

    // Check content type first
    final type = post.contentType.toLowerCase();
    if (type == 'reel' || type == 'story') return true;

    // Fallback to URL check
    try {
      final uri = Uri.parse(post.imageUrl);
      final path = uri.path.toLowerCase();
      final lowercase = post.imageUrl.toLowerCase();

      return path.endsWith('.mp4') ||
          path.endsWith('.mov') ||
          path.endsWith('.avi') ||
          path.endsWith('.mkv') ||
          lowercase.contains('video') ||
          path.contains('video');
    } catch (e) {
      final lowercase = post.imageUrl.toLowerCase();
      return lowercase.endsWith('.mp4') ||
          lowercase.endsWith('.mov') ||
          lowercase.endsWith('.avi') ||
          lowercase.endsWith('.mkv') ||
          lowercase.contains('video');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ScheduleController>();

    return Container(
      margin: EdgeInsets.only(bottom: 25.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section with Overlays
          Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(
                    () => ScheduledPostPreviewScreen(post: post),
                    transition: Transition.fadeIn,
                    duration: const Duration(milliseconds: 300),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28.r),
                  ),
                  child: _buildMediaContent(),
                ),
              ),

              // Play Button Icon (Center) - Larger and more transparent
              if (_isVideo(post))
                Container(
                  width: 65.r,
                  height: 65.r,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 45.r,
                  ),
                ),

              // Status Badge (Top Left) - Smaller
              Positioned(
                top: 15.h,
                left: 15.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 5.r,
                        height: 5.r,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        post.status == "draft" ? "Draft" : "Scheduled",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Actions (Top Right)
              Positioned(
                top: 15.h,
                right: 15.w,
                child: Column(
                  children: [
                    _buildCircledAction(
                      Icons.edit_outlined,
                      onTap: () async {
                        if (post.id.isNotEmpty) {
                          // Ensure ContentCreationController is registered
                          if (!Get.isRegistered<ContentCreationController>()) {
                            Get.put(ContentCreationController());
                          }

                          // Navigate to SchedulePostScreen in edit mode
                          await Get.to(
                            () => SchedulePostScreen(
                              postToEdit: post,
                              isImage: !_isVideo(
                                post,
                              ), // Determine based on post
                            ),
                          );

                          // If successfully updated (result would typically be true or handled by success screen)
                          // We trigger a refresh to show the updated content
                          controller.fetchSchedules("scheduled");
                          controller.fetchSchedules("draft");
                        }
                      },
                    ),
                    SizedBox(height: 8.h),
                    _buildCircledAction(
                      Icons.delete_outline_rounded,
                      onTap: () {
                        if (post.id.isNotEmpty) {
                          controller.deletePost(post.id);
                        } else {
                          Get.snackbar(
                            "Error",
                            "Cannot delete: Post ID is missing",
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Social Icons (Bottom Left)
              Positioned(
                bottom: 15.h,
                left: 15.w,
                child: Row(
                  children: [
                    _buildSocialIcon(Icons.facebook, const Color(0xFF1877F2)),
                    SizedBox(width: 8.w),
                    _buildInstagramIcon(),
                  ],
                ),
              ),
            ],
          ),

          // Content Section
          SchedulePostContentWidget(post: post),
        ],
      ),
    );
  }

  Widget _buildMediaContent() {
    // 1. Try to show server-provided thumbnail first (Best Quality/Correct Cover)
    if (post.thumbnailUrl != null && post.thumbnailUrl!.isNotEmpty) {
      return Image.network(
        post.thumbnailUrl!,
        width: double.infinity,
        height: 230.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackMedia(),
      );
    }

    // 2. If no thumbnail, check if main URL is video and generate locally
    if (_isVideo(post)) {
      return FutureBuilder<Uint8List?>(
        future: VideoThumbnail.thumbnailData(
          video: post.imageUrl,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 400,
          quality: 50,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              width: double.infinity,
              height: 230.h,
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            return Image.memory(
              snapshot.data!,
              width: double.infinity,
              height: 230.h,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPlaceholder(),
            );
          }
          return _buildPlaceholder();
        },
      );
    }

    // 3. Last resort: Try treating imageUrl as an image
    if (post.imageUrl.isNotEmpty) {
      return Image.network(
        post.imageUrl,
        width: double.infinity,
        height: 230.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }

  // Wrapper for fallback logic to avoid infinite loop or deep nesting
  Widget _buildFallbackMedia() {
    if (_isVideo(post)) {
      // Retry generation if the provided thumbnail failed
      return FutureBuilder<Uint8List?>(
        future: VideoThumbnail.thumbnailData(
          video: post.imageUrl,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 400,
          quality: 50,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              height: 230.h,
              width: double.infinity,
            );
          }
          return _buildPlaceholder();
        },
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 230.h,
      color: const Color(0xFFF1F5F9),
      child: Icon(
        Icons.image_outlined,
        size: 50.r,
        color: const Color(0xFFCBD5E1),
      ),
    );
  }

  Widget _buildCircledAction(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28.r,
        height: 28.r,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(icon, color: Colors.white, size: 16.r),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      width: 24.r,
      height: 24.r,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(icon, color: color, size: 22.r),
      ),
    );
  }

  Widget _buildInstagramIcon() {
    return Container(
      width: 24.r,
      height: 24.r,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Image.network(
          "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Instagram_icon.png/600px-Instagram_icon.png",
          width: 18.r,
          height: 18.r,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
