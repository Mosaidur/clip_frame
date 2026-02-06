import 'package:clip_frame/features/post/presenatation/widget2/MediaDisplayWidget.dart';
import 'package:clip_frame/features/schedule/data/model.dart';
import 'package:flutter/material.dart';

class ScheduledPostPreviewScreen extends StatelessWidget {
  final SchedulePost post;

  const ScheduledPostPreviewScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final bool isVideo =
        _isVideoUrl(post.imageUrl) ||
        post.contentType.toLowerCase() == 'reel' ||
        post.contentType.toLowerCase() == 'story';
    final String mediaUrl = post.imageUrl;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Media Content
          Positioned.fill(
            child: mediaUrl.isEmpty
                ? const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 50,
                    ),
                  )
                : isVideo
                ? MediaDisplayWidget(videoUrl: mediaUrl, autoPlay: true)
                : InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 3.0,
                    child: Image.network(
                      mediaUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                    ),
                  ),
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
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
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
                        post.contentType.toUpperCase(),
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
                      post.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (post.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: post.tags
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
                          post.scheduleTime,
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
                              post.status,
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: _getStatusColor(post.status),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            post.status.toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(post.status),
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
