import 'dart:convert';
import 'package:flutter/material.dart';

import '../widget2/reelsScrollContent.dart';

/// Import your VideoPage widget from before
/// (make sure VideoPage & VideoPlayerWidget are in another file and imported)

class Reelsscrollpage extends StatefulWidget {
  const Reelsscrollpage({super.key});

  @override
  State<Reelsscrollpage> createState() => _ReelsscrollpageState();
}

class _ReelsscrollpageState extends State<Reelsscrollpage> {
  List<dynamic> videos = [];

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  void _loadVideos() {
    /// Mock JSON (can be replaced with API call)
    const jsonString = '''
    {
      "videos": [
        {
          "videoUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
          "thumbnailUrl": "https://example.com/thumbnails/thumb1.jpg",
          "category": "Education",
          "format": "MP4",
          "title": "Learn Flutter in 60 seconds",
          "tags": ["flutter", "mobile", "dart"],
          "musicTitle": "Inspiring Beats"
        },
        {
          "videoUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
          "thumbnailUrl": "https://example.com/thumbnails/thumb2.jpg",
          "category": "Travel",
          "format": "MP4",
          "title": "Exploring the mountains",
          "tags": ["nature", "adventure", "travel"],
          "musicTitle": "Calm Nature Sound"
        },
        {
          "videoUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
          "thumbnailUrl": "https://example.com/thumbnails/thumb3.jpg",
          "category": "Entertainment",
          "format": "MOV",
          "title": "Funny moments compilation",
          "tags": ["funny", "comedy", "viral"],
          "musicTitle": "Comedy Beats"
        },
        {
          "videoUrl": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
          "thumbnailUrl": "https://example.com/thumbnails/thumb4.jpg",
          "category": "Sports",
          "format": "MP4",
          "title": "Top 10 football goals",
          "tags": ["football", "sports", "goals"],
          "musicTitle": "Stadium Energy"
        }
      ]
    }
    ''';

    final data = json.decode(jsonString);
    setState(() {
      videos = data["videos"];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return ReelsScrollContnet(
            videoUrl: video["videoUrl"],
            category: video["category"],
            format: video["format"],
            title: video["title"],
            tags: List<String>.from(video["tags"]),
            musicTitle: video["musicTitle"],
            profileImageUrl: video["thumbnailUrl"],
          );
        },
      ),
    );
  }
}
