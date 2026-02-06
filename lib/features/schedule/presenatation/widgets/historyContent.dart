import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../data/model.dart';

class HistoryContentWidget extends StatelessWidget {
  final HistoryPost post;
  const HistoryContentWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final totalReach =
        post.facebookReach + post.instagramReach + post.tiktokReach;

    return Padding(
      padding: EdgeInsets.all(12.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: _buildMediaContent(),
          ),
          SizedBox(width: 15.w),

          // Stats Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: const Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),

                if (post.tags.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Wrap(
                      spacing: 4.w,
                      runSpacing: 2.h,
                      children: post.tags
                          .take(3)
                          .map((tag) => _buildTag(tag))
                          .toList(),
                    ),
                  ),

                Row(
                  children: [
                    Text(
                      "Audiences",
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    _buildGrowthBadge(),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  post.totalAudience.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6366F1),
                  ),
                ),
                SizedBox(height: 12.h),

                // Multi-platform Progress Bar
                _buildPlatformBars(totalReach),
                SizedBox(height: 10.h),

                // Platform Legends
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLegend("FB", const Color(0xFF1877F2)),
                    _buildLegend("IG", const Color(0xFFE4405F)),
                    _buildLegend("TT", const Color(0xFF000000)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isVideo(HistoryPost post) {
    if (post.imageUrl.isEmpty) return false;
    final type = post.contentType.toLowerCase();
    if (type == 'reel' || type == 'story') return true;
    final lowercase = post.imageUrl.toLowerCase();
    return lowercase.endsWith('.mp4') ||
        lowercase.endsWith('.mov') ||
        lowercase.endsWith('.avi') ||
        lowercase.endsWith('.mkv') ||
        lowercase.contains('video');
  }

  Widget _buildMediaContent() {
    if (_isVideo(post)) {
      return FutureBuilder<Uint8List?>(
        future: VideoThumbnail.thumbnailData(
          video: post.imageUrl,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 200,
          quality: 25,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Image.memory(
                  snapshot.data!,
                  width: 100.w,
                  height: 140.h,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(),
                ),
                Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 24.r,
                ),
              ],
            );
          }
          return _buildPlaceholder();
        },
      );
    }

    if (post.imageUrl.isNotEmpty) {
      return Image.network(
        post.imageUrl,
        width: 100.w,
        height: 140.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 100.w,
      height: 140.h,
      color: const Color(0xFFF1F5F9),
      child: Icon(
        Icons.image_outlined,
        size: 30.r,
        color: const Color(0xFFCBD5E1),
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Text(
      "#$tag",
      style: GoogleFonts.poppins(
        fontSize: 10.sp,
        color: const Color(0xFF94A3B8),
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildGrowthBadge() {
    bool isPositive = post.percentageGrowth >= 0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isPositive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            size: 12.r,
            color: isPositive
                ? const Color(0xFF166534)
                : const Color(0xFF991B1B),
          ),
          SizedBox(width: 4.w),
          Text(
            "${post.percentageGrowth.abs()}%",
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: isPositive
                  ? const Color(0xFF166534)
                  : const Color(0xFF991B1B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformBars(int total) {
    if (total == 0) {
      return Container(
        height: 6.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(3.r),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(3.r),
      child: SizedBox(
        height: 6.h,
        child: Row(
          children: [
            if (post.facebookReach > 0)
              Expanded(
                flex: post.facebookReach,
                child: Container(color: const Color(0xFF1877F2)),
              ),
            if (post.instagramReach > 0)
              Expanded(
                flex: post.instagramReach,
                child: Container(color: const Color(0xFFE4405F)),
              ),
            if (post.tiktokReach > 0)
              Expanded(
                flex: post.tiktokReach,
                child: Container(color: const Color(0xFF000000)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 6.r,
          height: 6.r,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 9.sp,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
