import 'package:clip_frame/core/model/my_content_model.dart';
import 'package:clip_frame/features/my_profile/presenatation/screen/MyProfileController.dart';
import 'package:clip_frame/features/my_profile/presenatation/widgets/CreationPreviewScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class MyCreationsWidget extends StatelessWidget {
  const MyCreationsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final MyProfileController controller = Get.find<MyProfileController>();

    return Obx(() {
      if (controller.isCreationsLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (controller.creationsErrorMessage.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(
                  controller.creationsErrorMessage.value,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                TextButton(
                  onPressed: () => controller.fetchMyCreations(),
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.myCreations.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: Text("No creations found."),
          ),
        );
      }

      final leftColumnItems = <ContentItem>[];
      final rightColumnItems = <ContentItem>[];

      for (int i = 0; i < controller.myCreations.length; i++) {
        if (i % 2 == 0) {
          leftColumnItems.add(controller.myCreations[i]);
        } else {
          rightColumnItems.add(controller.myCreations[i]);
        }
      }

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: leftColumnItems
                    .map(
                      (item) => _buildMasonryItem(
                        item,
                        i: leftColumnItems.indexOf(item),
                        isLeft: true,
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: rightColumnItems
                    .map(
                      (item) => _buildMasonryItem(
                        item,
                        i: rightColumnItems.indexOf(item),
                        isLeft: false,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMasonryItem(
    ContentItem item, {
    required int i,
    required bool isLeft,
  }) {
    String? imageUrl;
    if (item.mediaUrls.isNotEmpty) {
      imageUrl = item.mediaUrls.first;
    }

    // Assign varying heights to simulate the masonry effect
    final double height = (i % 3 == 0)
        ? 200
        : (i % 3 == 1)
        ? 280
        : 240;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          Get.to(
            () => CreationPreviewScreen(item: item),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 300),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            height: height,
            width: double.infinity,
            color: Colors.grey[200],
            child: _buildMediaPreview(imageUrl, item.contentType),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaPreview(String? url, String contentType) {
    if (url == null || url.isEmpty) {
      return const Center(child: Icon(Icons.movie, color: Colors.grey));
    }

    final bool isVideo = contentType == 'reel' || _isVideoUrl(url);

    if (isVideo) {
      return FutureBuilder<Uint8List?>(
        future: VideoThumbnail.thumbnailData(
          video: url,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 300,
          quality: 50,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(snapshot.data!, fit: BoxFit.cover),
                const Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ],
            );
          }
          return const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
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
