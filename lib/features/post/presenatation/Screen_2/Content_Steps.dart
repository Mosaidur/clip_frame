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




import 'package:flutter/material.dart';
import '../../../Video Editing/VideoList.dart';
import '../../../story_creation/story_capture.dart';

class StepByStepPage extends StatelessWidget {
  const StepByStepPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> steps = [
      {
        "image": "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe",
        "step": "Step 1:",
        "title": "Take random photos for the content.",
        "description":
        "Take 3–4 random photos for the story content. Make sure that the photos clearly describe the surroundings with good lighting."
      },
      {
        "image": "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e",
        "step": "Step 2:",
        "title": "We will frame your photos nicely.",
        "description":
        "We will nicely frame all your photos in a very interesting manner for your profile in an eye-catching way."
      },
      {
        "image": "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee",
        "step": "Step 3:",
        "title": "Schedule your story for publishing.",
        "description":
        "Select a time to schedule your story to be posted. Choose your time manually or use our AI to find the best moment to post."
      },
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEBC894), Color(0xFFFFFFFF), Color(0xFFB49EF4)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
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
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 16),

                Center(
                  child: const Text(
                    "Step by Step Content Creation",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Follow the prompt below to capture engaging footage",
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 20),

                // Dynamic List
                Column(
                  children: List.generate(steps.length, (index) {
                    final item = steps[index];
                    final bool imageLeft = index % 2 == 0; // alternate

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imageLeft) _buildImage(item["image"]!),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextContent(item),
                          ),
                          if (!imageLeft) ...[
                            const SizedBox(width: 12),
                            _buildImage(item["image"]!),
                          ],
                        ],
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),
                Center(

                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {

                        Navigator.push(
                          context,
                          // MaterialPageRoute(builder: (context) => StepByStepContentScreen()),
                          MaterialPageRoute(builder: (context) => StoryCapturePage()),
                        );

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Start Capturing",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    "Need help? View tips & examples from other businesses",
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.network(
        url,
        width: 150,
        // height: 150,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/placeholder.png',
            // height: 150,
            width: 150,
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }

  Widget _buildTextContent(Map<String, String> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item["step"]!,
          style: const TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item["title"]!,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          item["description"]!,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
