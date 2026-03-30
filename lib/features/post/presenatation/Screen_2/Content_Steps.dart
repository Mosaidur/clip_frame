import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../story_creation/story_capture.dart';
import 'package:clip_frame/features/post/presenatation/screen/ReviewClipsPage.dart';
import '../../../../features/Video Editing/ProfessionalCamera.dart';

class StepByStepPage extends StatelessWidget {
  final String contentType;
  final Map<String, dynamic>? template;

  const StepByStepPage({super.key, this.contentType = 'Reel', this.template});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> steps = template?['steps'] ?? [];
    final String templateThumbnail = template?['thumbnail'] ?? '';

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
              // Header with Back Button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.black87,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Title and Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template?['title'] ?? "Step by Step Content Creation",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      template?['category'] != null
                          ? "Category: ${template!['category']} • Follow the prompts below"
                          : "Follow the prompt below to capture engaging footage",
                      style: GoogleFonts.poppins(
                        color: Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Step List
              Expanded(
                child: steps.isEmpty
                    ? Center(
                        child: Text(
                          "No steps available for this template.",
                          style: GoogleFonts.poppins(color: Colors.black54),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: steps.length,
                        itemBuilder: (context, index) {
                          final Map<String, dynamic> item =
                              Map<String, dynamic>.from(steps[index]);
                          return _buildStepCard(
                            item,
                            index + 1,
                            templateThumbnail,
                          );
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
                        List<File> recordedClips = [];
                        int totalSteps = steps.isNotEmpty ? steps.length : 1;

                        for (int i = 0; i < totalSteps; i++) {
                          final Map<String, dynamic>? currentStepData = steps.isNotEmpty ? steps[i] : null;

                          final videoFile = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfessionalCameraPage(
                                stepData: currentStepData,
                                stepIndex: i + 1,
                                totalSteps: totalSteps,
                              ),
                            ),
                          );

                          if (videoFile != null && videoFile is File) {
                            recordedClips.add(videoFile);
                          } else {
                            // User backed out of the camera, break the recording flow
                            break;
                          }
                          
                          if (!context.mounted) break;
                        }

                        if (recordedClips.isNotEmpty && context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ReviewClipsPage(recordedClips: recordedClips),
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

  Widget _buildStepCard(
    Map<String, dynamic> item,
    int stepNumber,
    String defaultImage,
  ) {
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
          // Background Image (Using template thumbnail as steps don't have individual images in API)
          Positioned.fill(
            child: defaultImage.isNotEmpty
                ? Image.network(
                    defaultImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.grey[300]),
                  )
                : Container(color: Colors.grey[300]),
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
                    text: "Step $stepNumber: ",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  TextSpan(
                    text: item["title"] ?? "",
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
          Positioned(
            bottom: 75,
            left: 15,
            right: 15,
            child: Wrap(
              spacing: 10,
              runSpacing: 5,
              children: [
                _buildBadge(
                  Icons.videocam_outlined,
                  "Shot Type: ${item["shotType"] ?? 'N/A'}",
                ),
                _buildBadge(
                  Icons.timer_outlined,
                  "Duration: ${item["duration"] ?? '0'}s",
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
                      text: item["mainTip"] ?? item["description"] ?? "",
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
