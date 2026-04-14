import 'package:carousel_slider/carousel_slider.dart';
import 'package:clip_frame/features/post/presenatation/widget2/MediaDisplayWidget.dart';
import 'package:clip_frame/features/schedule/data/model.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final bool isVideo =
        _isVideoUrl(widget.post.imageUrl) ||
        widget.post.contentType.toLowerCase() == 'reel' ||
        widget.post.contentType.toLowerCase() == 'story';

    final List<String> mediaUrls = widget.post.mediaUrls.isNotEmpty
        ? widget.post.mediaUrls
        : (widget.post.imageUrl.isNotEmpty ? [widget.post.imageUrl] : []);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Media Content
          mediaUrls.isEmpty
              ? const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 50,
                  ),
                )
              : Center(
                  child: mediaUrls.length > 1
                      ? _buildCarousel(mediaUrls)
                      : isVideo
                      ? MediaDisplayWidget(
                          videoUrl: mediaUrls[0],
                          autoPlay: true,
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Indicators for Carousel
          if (mediaUrls.length > 1)
            Positioned(
              top: 100, // Below top bar
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: mediaUrls.asMap().entries.map((entry) {
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(
                        _current == entry.key ? 0.9 : 0.3,
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (widget.post.tags.isNotEmpty) ...[
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
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.post.scheduleTime,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              widget.post.status,
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: _getStatusColor(widget.post.status),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            widget.post.status.toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(widget.post.status),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
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
    return Center(
      child: InteractiveViewer(
        minScale: 1.0,
        maxScale: 4.0,
        child: Image.network(
          url,
          fit: BoxFit.contain, // Maintain original aspect ratio
          alignment: Alignment.center,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          },
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.broken_image, color: Colors.white, size: 50),
          ),
        ),
      ),
    );
  }

  Widget _buildCarousel(List<String> urls) {
    final screenWidth = MediaQuery.of(context).size.width;
    return CarouselSlider(
      items: urls.map((url) => _buildSingleImage(url)).toList(),
      carouselController: _carouselController,
      options: CarouselOptions(
        height: screenWidth, // Force a square container
        viewportFraction: 1.0,
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

  bool _isVideoUrl(String url) {
    final lowercase = url.toLowerCase();
    return lowercase.endsWith('.mp4') ||
        lowercase.endsWith('.mov') ||
        lowercase.endsWith('.avi') ||
        lowercase.endsWith('.mkv');
  }
}
