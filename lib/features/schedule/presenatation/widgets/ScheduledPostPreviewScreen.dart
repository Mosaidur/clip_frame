import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:clip_frame/features/post/presenatation/widget2/MediaDisplayWidget.dart';
import 'package:clip_frame/features/schedule/data/model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clip_frame/core/widgets/custom_back_button.dart';

class ScheduledPostPreviewScreen extends StatefulWidget {
  final SchedulePost post;

  const ScheduledPostPreviewScreen({super.key, required this.post});

  @override
  State<ScheduledPostPreviewScreen> createState() =>
      _ScheduledPostPreviewScreenState();
}

class _ScheduledPostPreviewScreenState
    extends State<ScheduledPostPreviewScreen> {
  int _current = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final List<String> mediaUrls = widget.post.mediaUrls.isNotEmpty
        ? widget.post.mediaUrls
        : (widget.post.imageUrl.isNotEmpty ? [widget.post.imageUrl] : []);

    final bool isVideo = mediaUrls.isNotEmpty && _isVideoUrl(mediaUrls[0]);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Media Content
          mediaUrls.isEmpty
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFEFE2C2), Color(0xFFF1F5F9), Color(0xFFE5DDF9)],
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
                          color: Colors.black.withOpacity(0.05),
                          size: 80.r,
                        ),
                        SizedBox(height: 15.h),
                        Text(
                          "Media is being prepared...",
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.15),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox.expand(
                  child: mediaUrls.length > 1
                      ? _buildCarousel(mediaUrls)
                      : isVideo
                      ? MediaDisplayWidget(
                          videoUrl: mediaUrls[0],
                          autoPlay: true,
                          fit: BoxFit.cover,
                          isMinimal: widget.post.contentType.toLowerCase() == 'story',
                        )
                      : _buildSingleImage(mediaUrls[0]),
                ),

          // Top Bar (Back Button)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CustomBackButton(
                      backgroundColor: Colors.black38,
                      iconColor: Colors.white,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        mediaUrls.length > 1
                            ? "CAROUSEL"
                            : widget.post.contentType.toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Indicators for Carousel (moved slightly lower)
          if (mediaUrls.length > 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 70.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: mediaUrls.asMap().entries.map((entry) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _current == entry.key ? 20.w : 6.w,
                    height: 6.w,
                    margin: const EdgeInsets.symmetric(horizontal: 3.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: Colors.white.withOpacity(
                        _current == entry.key ? 1.0 : 0.4,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          // Bottom Info (Caption & Tags)
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 20.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0.0, 0.4, 1.0],
                  colors: [
                    Colors.black.withOpacity(0.9),
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: _isExpanded ? null : 3,
                            overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                          ),
                          if (_isExpanded && widget.post.tags.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: widget.post.tags
                                  .map(
                                    (tag) => Text(
                                      '#${tag.replaceAll('#', '')}',
                                      style: const TextStyle(
                                        color: Color(0xFF007AFF),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                          if (widget.post.title.length > 60 || widget.post.tags.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Text(
                                _isExpanded ? "See Less" : "See More",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFFF277F),
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, color: Colors.white70, size: 12.sp),
                              SizedBox(width: 8.w),
                              Text(
                                widget.post.scheduleTime,
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: _getStatusColor(widget.post.status).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: _getStatusColor(widget.post.status).withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            widget.post.status.toUpperCase(),
                            style: GoogleFonts.poppins(
                              color: _getStatusColor(widget.post.status),
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildSingleImage(String url) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Blurred background
          Positioned.fill(
            child: _buildImageWithCache(url, BoxFit.cover),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          ),
          // Main image
          Center(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: _buildImageWithCache(url, BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel(List<String> urls) {
    final screenWidth = MediaQuery.of(context).size.width;
    return CarouselSlider(
      items: urls.map((url) => _buildSingleImage(url)).toList(),
      carouselController: _carouselController,
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height, 
        viewportFraction: 1.0,
        clipBehavior: Clip.hardEdge, // Prevent bleeding of adjacent images
        enableInfiniteScroll: false,
        scrollPhysics: const BouncingScrollPhysics(),
        onPageChanged: (index, reason) {
          setState(() {
            _current = index;
          });
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return Colors.green;
      case 'scheduled':
        return Colors.blue;
      case 'failed':
        return Colors.red;
      case 'draft':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  Widget _buildImageWithCache(String url, BoxFit fit) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.black26,
        highlightColor: Colors.black12,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
        ),
      ),
      errorWidget: (context, url, error) => const Center(
        child: Icon(Icons.broken_image, color: Colors.white, size: 50),
      ),
    );
  }

  bool _isVideoUrl(String url) {
    final lowercase = url.toLowerCase();
    return lowercase.endsWith('.mp4') ||
        lowercase.endsWith('.mov') ||
        lowercase.endsWith('.avi') ||
        lowercase.endsWith('.mkv');
  }
}
