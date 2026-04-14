import 'package:clip_frame/features/post/presenatation/widget2/MediaDisplayWidget.dart';
import 'package:clip_frame/features/post/presenatation/widget2/customTabBar.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';
import 'package:clip_frame/core/model/content_template_model.dart';
import 'package:clip_frame/features/post/presenatation/controller/content_creation_controller.dart';

import '../Screen_2/post_highlight.dart';
import '../Screen_2/video_Highlight.dart';

class PostScrollContnet extends StatelessWidget {
  final ContentTemplateModel template;
  final String imageUrl;
  final String category;
  final String format;
  final String title;
  final List<String> tags;
  final String musicTitle;
  final String? profileImageUrl;

  const PostScrollContnet({
    super.key,
    required this.template,
    required this.imageUrl,
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
      backgroundColor: Colors.black, // Background color for horizontal images
      body: Stack(
        children: [
          /// Fullscreen Image with containment
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: Center(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit
                      .contain, // Changed from cover to contain to show full horizontal image
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.error, color: Colors.white, size: 50),
                  ),
                ),
              ),
            ),
          ),

          /// Gradient overlay to ensure text readability on light images
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.0, 0.2, 0.7, 1.0],
                  ),
                ),
              ),
            ),
          ),

          /// Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// Safe space for the parent's back button
                    const SizedBox(width: 50),

                    /// Profile Image
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                      child: profileImageUrl == null || profileImageUrl!.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            )
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
          ),

          /// Tabs
          Positioned(top: 120, left: 10, right: 0, child: CustomTabBar()),

          /// Bottom Left Info Panel
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(20),
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
                        const Icon(
                          Icons.music_note,
                          color: Colors.white,
                          size: 14,
                        ),
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
                          // Initialize ContentCreationController with template data
                          if (!Get.isRegistered<ContentCreationController>()) {
                            Get.put(ContentCreationController());
                          }

                          final controller =
                              Get.find<ContentCreationController>();
                          controller.templateId.value = template.id ?? '';
                          controller.caption.value = template.title ?? '';
                          controller.hashtags.assignAll(
                            template.hashtags ?? [],
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostHighlight(
                                url: imageUrl,
                                contentType: 'Post',
                                template: template,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007CFE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text(
                          "Create this Post",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
