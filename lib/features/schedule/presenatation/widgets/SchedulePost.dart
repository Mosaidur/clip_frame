import 'dart:typed_data';
import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
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
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/model.dart';

class SchedulePostWidget extends StatelessWidget {
  final SchedulePost post;
  
  // Static cache to store generated thumbnails and avoid re-processing
  static final Map<String, Uint8List> _thumbnailCache = {};

  const SchedulePostWidget({super.key, required this.post});

  bool _isVideo(SchedulePost post) {
    if (post.imageUrl.isEmpty) return false;

    // Check content type first
    final type = post.contentType.toLowerCase();
    if (type == 'reel') return true;

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
                  child: SizedBox(
                    height: 250.h,
                    width: double.infinity,
                    child: _buildMediaContent(),
                  ),
                ),
              ),

              // Play Button Icon (Center) - Only show if video and media is present
              if (_isVideo(post) && (post.imageUrl.isNotEmpty || post.mediaUrls.isNotEmpty))
                Container(
                  width: 50.r,
                  height: 50.r,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 35.r,
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
    final List<String> mediaUrls = post.mediaUrls.isNotEmpty
        ? post.mediaUrls
        : (post.imageUrl.isNotEmpty ? [post.imageUrl] : []);

    if (mediaUrls.length > 1) {
      return Stack(
        children: [
          CarouselSlider(
            items: mediaUrls.map((url) => _buildImage(url)).toList(),
            options: CarouselOptions(
              height: 300.h, // Consistent height for the list view
              viewportFraction: 1.0,
              enableInfiniteScroll: false,
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                "1/${mediaUrls.length}",
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      );
    }

    // 1. Try to show server-provided thumbnail first
    if (post.thumbnailUrl != null && post.thumbnailUrl!.isNotEmpty) {
      return _buildImage(post.thumbnailUrl!);
    }

    // 2. If no thumbnail, check if main URL is video and generate locally (with caching)
    if (_isVideo(post)) {
      // Check cache first
      if (_thumbnailCache.containsKey(post.imageUrl)) {
        return _buildThumbnailStack(_thumbnailCache[post.imageUrl]!);
      }

      return FutureBuilder<Uint8List?>(
        future: VideoThumbnail.thumbnailData(
          video: post.imageUrl,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 400,
          quality: 50,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[200]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: double.infinity,
                height: 300.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28.r),
                  ),
                ),
              ),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            // Save to cache for next time
            _thumbnailCache[post.imageUrl] = snapshot.data!;
            return _buildThumbnailStack(snapshot.data!);
          }
          return _buildPlaceholder();
        },
      );
    }

    // 3. Last resort: Try treating imageUrl as an image
    if (post.imageUrl.isNotEmpty) {
      return _buildImage(post.imageUrl);
    }

    return _buildPlaceholder();
  }

  Widget _buildThumbnailStack(Uint8List data) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.memory(
          data,
          width: double.infinity,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        ),
        Icon(
          Icons.play_circle_outline,
          color: Colors.white,
          size: 40.r,
        ),
      ],
    );
  }

  Widget _buildImage(String url) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildPlaceholder(),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
        ),
        Center(
          child: CachedNetworkImage(
            imageUrl: url,
            width: double.infinity,
            height: 300.h,
            fit: BoxFit.contain,
            placeholder: (context, url) => _buildPlaceholder(),
            errorWidget: (context, url, error) => _buildPlaceholder(),
          ),
        ),
      ],
    );
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
              height: 300.h,
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
      height: 300.h,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE5DDF9), Color(0xFFF1F5F9), Color(0xFFEFE2C2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_outlined,
              size: 40.r,
              color: Colors.black.withOpacity(0.1),
            ),
            SizedBox(height: 8.h),
            Text(
              "Media Processing...",
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.black.withOpacity(0.2),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
          "https://cdn-icons-png.flaticon.com/512/174/174855.png",
          width: 18.r,
          height: 18.r,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.camera_alt, size: 14, color: Colors.pink),
        ),
      ),
    );
  }
}
