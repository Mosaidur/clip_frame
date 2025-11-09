import 'package:flutter/material.dart';
import 'package:path/path.dart' as widget;

import '../widget2/MediaDisplayWidget.dart';
import 'Content_Steps.dart';

class VideoHighlight extends StatelessWidget {
  final String url ; // ✅ make it final

  const VideoHighlight({super.key, required this.url }); // ✅ initialize via constructor

  @override
  Widget build(BuildContext context) {
    String title = "Video Highlight";
    String subTitle =
        "Create a reel showcasing your expert chefs cooking. This engages curiosity and shows the food quality naturally.";
    // String url = "assets/images/highlight.png"; // Replace with your image path
    String tips =
        "Why this idea? Trending #Food #Cooking content gets high engagement and saves on Instagram and TikTok. Idea product-first brands.";

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEBC894),
              Color(0xFFFFFFFF),
              Color(0xFFB49EF4),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.black87,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                // Image section with border
                Container(
                  width: double.infinity  ,
                  height: 400,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                          child: MediaDisplayWidget(videoUrl: url)
                      ),
                      // Container(
                      //   width: 60,
                      //   height: 60,
                      //   decoration: const BoxDecoration(
                      //     shape: BoxShape.circle,
                      //     color: Colors.white70,
                      //   ),
                      //   child: const Icon(
                      //     Icons.play_arrow,
                      //     color: Colors.black87,
                      //     size: 40,
                      //   ),
                      // ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tips,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {

                      Navigator.push(
                        context,
                        // MaterialPageRoute(builder: (context) => StepByStepContentScreen()),
                        MaterialPageRoute(builder: (context) => StepByStepPage()),
                      );

                    },
                    child: const Text(
                      "Start Creating",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
