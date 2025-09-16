import 'package:clip_frame/features/post/presenatation/widget2/MediaDisplayWidget.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'customTabBar.dart';

class ReelsScrollContnet extends StatelessWidget {
  final String videoUrl;
  final String category;
  final String format;
  final String title;
  final List<String> tags;
  final String musicTitle;
  final String? profileImageUrl;


  const ReelsScrollContnet({
    super.key,
    required this.videoUrl,
    required this.category,
    required this.format,
    required this.title,
    required this.tags,
    required this.musicTitle,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Fullscreen Video
          Positioned.fill(
            child: MediaDisplayWidget(videoUrl: videoUrl),
          ),

          /// Top Bar
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Menu
                  GestureDetector(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black26,
                      ),
                      child: const Icon(Icons.menu_outlined, color: Colors.white),
                    ),
                  ),

                  /// Profile Image
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                    child: profileImageUrl == null || profileImageUrl!.isEmpty
                        ? const Icon(Icons.person, size: 40, color: Colors.white)
                        : ClipOval(
                      child: Image.network(
                        profileImageUrl!,
                        fit: BoxFit.cover,
                        width: 70,
                        height: 70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Tabs
          Positioned(
            top: 120,
            left: 10,
            right: 0,
            child: CustomTabBar(),
          ),

          /// Bottom Left Info Panel
          Positioned(
            left: 20,
            bottom: 30,
            right: 20,
            // width: double.infinity,
            child: Container(
              padding: const EdgeInsets.all(8),
              width: MediaQuery.of(context).size.width  ,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Category & Format
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoRow("Category:", category),
                      _infoRow("Format:", format),
                    ],
                  ),
                  const SizedBox(height: 5),

                  /// Title
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  /// Tags
                  Text(
                    tags.join(", "),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 5),

                  /// Music Row
                  Row(
                    children: [
                      const Icon(Icons.music_note,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          musicTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  /// Create Button
                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Your action here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007CFE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text(
                        "Create this Reel",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text(
          "$label ",
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

/// Simple Video Player
// class VideoPlayerWidget extends StatefulWidget {
//   final String videoUrl;
//   const VideoPlayerWidget({super.key, required this.videoUrl});
//
//   @override
//   State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
// }
//
// class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
//   late VideoPlayerController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.network(widget.videoUrl)
//       ..initialize().then((_) {
//         setState(() {});
//         _controller.play();
//         _controller.setLooping(true);
//       });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return _controller.value.isInitialized
//         ? FittedBox(
//       fit: BoxFit.cover,
//       child: SizedBox(
//         width: _controller.value.size.width,
//         height: _controller.value.size.height,
//         child: VideoPlayer(_controller),
//       ),
//     )
//         : const Center(child: CircularProgressIndicator());
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }
