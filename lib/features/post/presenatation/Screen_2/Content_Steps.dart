// import 'package:flutter/material.dart';
//
// class StepByStepContentScreen extends StatelessWidget {
//   StepByStepContentScreen({super.key});
//
//   final List<Map<String, String>> steps = [
//     {
//       "image": "https://images.unsplash.com/photo-1601233743382-5b6b5c1f2190",
//       "step": "Step 1",
//       "title": "Take random photos for the content.",
//       "description":
//       "Take 3, 4 random photos for the story content. Make sure that the photos clearly describe the surrounding with good lighting."
//     },
//     {
//       "image": "https://images.unsplash.com/photo-1551836022-d5d88e9218df",
//       "step": "Step 2",
//       "title": "We will frame your photos for you nicely.",
//       "description":
//       "We will nicely frame all your photos in a very interesting manner for your profile in an eye-catching manner for your profile."
//     },
//     {
//       "image": "https://images.unsplash.com/photo-1515378791036-0648a3ef77b2",
//       "step": "Step 3",
//       "title": "Schedule your story for publishing.",
//       "description":
//       "Select a time to schedule your story to be posted. Choose the time of your choice or our AI will help you find the best time to post the story."
//     },
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // backgroundColor: ,
//       body: Container(
//           width: double.infinity,
//           height: double.infinity,
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 Color(0xFFEBC894),
//                 Color(0xFFFFFFFF),
//                 Color(0xFFB49EF4),
//               ],
//             ),
//           ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Back button
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.2),
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 4,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: IconButton(
//                     icon: const Icon(
//                       Icons.arrow_back_ios_new_rounded,
//                       color: Colors.black87,
//                       size: 20,
//                     ),
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//
//                 // Title
//                 Center(
//                   child: const Text(
//                     "Step by Step Content Creation",
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 6),
//                 const Text(
//                   "Follow the prompt below to capture engaging footage",
//                   style: TextStyle(color: Colors.black54, fontSize: 14),
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 // Dynamic list of steps
//                 Column(
//                   children: List.generate(steps.length, (index) {
//                     final item = steps[index];
//                     return Container(
//                       margin: const EdgeInsets.only(bottom: 16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 10,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           ClipRRect(
//                             borderRadius: const BorderRadius.only(
//                               topLeft: Radius.circular(16),
//                               topRight: Radius.circular(16),
//                             ),
//                             child: Image.network(
//                               item["image"]!,
//                               fit: BoxFit.cover,
//                               height: 150,
//                               width: double.infinity,
//                               errorBuilder: (context, error, stackTrace) =>
//                                   Image.asset(
//                                     "assets/images/placeholder.png",
//                                     fit: BoxFit.cover,
//                                     height: 150,
//                                     width: double.infinity,
//                                   ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(12.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   item["step"]!,
//                                   style: const TextStyle(
//                                     color: Colors.redAccent,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   item["title"]!,
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 6),
//                                 Text(
//                                   item["description"]!,
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.black54,
//                                     height: 1.4,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }),
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 // Start capturing button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {},
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blueAccent,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                     ),
//                     child: const Text(
//                       "Start Capturing",
//                       style: TextStyle(fontSize: 16, color: Colors.white),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 12),
//                 const Center(
//                   child: Text(
//                     "Need help? View tips & examples from other businesses",
//                     style: TextStyle(color: Colors.black54, fontSize: 13),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import '../../../Video Editing/VideoList.dart';
import '../../../story_creation/story_capture.dart';
import 'package:clip_frame/features/post/presenatation/screen/ReviewClipsPage.dart';
import '../../../../features/Video Editing/ProfessionalCamera.dart';
import '../../../../features/Video Editing/VideoEditing.dart';

class StepByStepPage extends StatelessWidget {
  final String contentType;
  const StepByStepPage({super.key, this.contentType = 'Reel'});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> steps = [
      {
        "image": "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe",
        "step": "Step 1:",
        "title": "Waiter welcoming guests to the restaurant.",
        "shotType": "Wide",
        "duration": "6s",
        "tip":
            "Record in landscape for best results. Focus on steam and smile!",
      },
      {
        "image": "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e",
        "step": "Step 2:",
        "title": "Shot of the waiter carrying the tray.",
        "shotType": "Close-up",
        "duration": "5s",
        "tip":
            "Capturing bubbling cheese and golden crust. 4-6 seconds is enough.",
      },
      {
        "image": "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee",
        "step": "Step 3:",
        "title": "Shot of the customers making a toast.",
        "shotType": "Medium",
        "duration": "7s",
        "tip": "Focus on the emotion and connection between the customers.",
      },
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF6E5), Color(0xFFE5D9FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.chevron_left,
                          color: Colors.black,
                          size: 28,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
              const Center(
                child: Text(
                  "Step by Step Content Creation",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Follow the prompt below to capture engaging footage",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),

              // Step List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: steps.length,
                  itemBuilder: (context, index) {
                    final item = steps[index];
                    return _buildStepCard(item);
                  },
                ),
              ),

              // Bottom Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (contentType == 'Story') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StoryCapturePage(),
                          ),
                        );
                      } else {
                        final videoFile = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ProfessionalCameraPage(),
                          ),
                        );
                        if (videoFile != null &&
                            videoFile is File &&
                            context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ReviewClipsPage(recordedClips: [videoFile]),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "Start Creating",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              item["image"]!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.grey[300]),
            ),
          ),
          // Darken the top area for readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                  ],
                ),
              ),
            ),
          ),
          // Step Info at Top
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: item["step"] + " ",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  TextSpan(
                    text: item["title"],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Shot Type and Duration Badges
          Positioned(
            bottom: 80,
            left: 15,
            right: 15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBadge(
                  Icons.videocam_outlined,
                  "Shot Type: ${item["shotType"]}",
                ),
                _buildBadge(
                  Icons.timer_outlined,
                  "Duration: ${item["duration"]}",
                ),
              ],
            ),
          ),
          // Tip at Bottom
          Positioned(
            bottom: 15,
            left: 15,
            right: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(15),
              ),
              child: RichText(
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: "Tip: ",
                      style: TextStyle(
                        color: Color(0xFF007AFF),
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    TextSpan(
                      text: item["tip"],
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
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

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
