import 'dart:io';
import 'package:clip_frame/core/model/content_template_model.dart';
import 'package:clip_frame/core/services/api_services/content_template_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clip_frame/core/model/my_content_model.dart';
import 'package:clip_frame/core/services/api_services/my_content_service.dart';

class ContentCreationController extends GetxController {
  static ContentCreationController get to => Get.find();

  // Templates
  var reelTemplates = <ContentTemplateModel>[].obs;
  var postTemplates = <ContentTemplateModel>[].obs;
  var storyTemplates = <ContentTemplateModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchAllTemplates();
    });
  }

  Future<void> fetchAllTemplates() async {
    isLoading.value = true;
    try {
      // 1. Fetch Reels separately to ensure we get all available items
      debugPrint("📡 [ContentCreationController] Fetching Reels...");
      final allReelTemplates =
          await ContentTemplateService.fetchTemplatesByType('reel');
      debugPrint(
        "📥 [ContentCreationController] Received ${allReelTemplates.length} raw Reel templates.",
      );

      // Re-apply strict filter to ensure no posts leaked into the reel fetch (if server is loose)
      reelTemplates.assignAll(
        allReelTemplates.where((t) {
          final type = (t.type ?? '').toLowerCase();
          final category = (t.category ?? '').toLowerCase();
          final title = (t.title ?? '').toLowerCase();

          // STRICT EXCLUSION: No posts/images in Reels tab
          if (type == 'post' || type == 'posts' || type == 'image') {
            return false;
          }

          bool hasVideoSign = false;
          if (t.steps != null && t.steps!.isNotEmpty) {
            final url = (t.steps![0].url ?? '').toLowerCase();
            if (url.endsWith('.mp4') ||
                url.contains('video') ||
                url.contains('mov')) {
              hasVideoSign = true;
            }
          }

          final isReel =
              type.contains('reel') ||
              type.contains('video') ||
              type.contains('short') ||
              type.contains('movie') ||
              category.contains('reel') ||
              category.contains('video') ||
              title.contains('reel') ||
              hasVideoSign;

          if (isReel) {
            debugPrint(
              "   🎬 Identified Reel: '${t.title}' (ID: ${t.id}, Type: $type)",
            );
          }
          return isReel;
        }).toList(),
      );

      // 2. Fetch Posts separately
      debugPrint("📡 [ContentCreationController] Fetching Posts...");
      final allPostTemplates =
          await ContentTemplateService.fetchTemplatesByType('post');
      debugPrint(
        "📥 [ContentCreationController] Received ${allPostTemplates.length} raw Post templates.",
      );

      postTemplates.assignAll(
        allPostTemplates.where((t) {
          final type = (t.type ?? '').toLowerCase();
          return type == 'post' || type == 'posts' || type == 'image';
        }).toList(),
      );

      // 3. Fetch Stories separately
      debugPrint("📡 [ContentCreationController] Fetching Stories...");
      final allStoryTemplates =
          await ContentTemplateService.fetchTemplatesByType('story');
      debugPrint(
        "📥 [ContentCreationController] Received ${allStoryTemplates.length} raw Story templates.",
      );

      storyTemplates.assignAll(
        allStoryTemplates.where((t) {
          final type = (t.type ?? '').toLowerCase();
          return type.contains('story');
        }).toList(),
      );

      // 4. Fetch User-Created Content and Merge into Reels
      debugPrint(
        "📡 [ContentCreationController] Fetching User-Created Reels...",
      );
      try {
        final userContentResponse = await MyContentService.getMyContents();
        if (userContentResponse.isSuccess &&
            userContentResponse.responseBody != null) {
          final myContents = MyContentsResponse.fromJson(
            userContentResponse.responseBody!,
          );

          final userReels = myContents.data.data
              .where((item) => item.contentType == 'reel')
              .map((item) {
                // Convert ContentItem to ContentTemplateModel
                return ContentTemplateModel(
                  id: item.id,
                  title: item.caption.isNotEmpty ? item.caption : "My Reel",
                  type: 'reel',
                  category: 'User Created',
                  steps: [
                    TemplateStep(
                      url: item.mediaUrls.isNotEmpty ? item.mediaUrls[0] : "",
                    ),
                  ],
                  thumbnail: item.mediaUrls.isNotEmpty ? item.mediaUrls[0] : "",
                );
              })
              .toList();

          debugPrint(
            "📥 [ContentCreationController] Merging ${userReels.length} User Reels into the list.",
          );
          // Insert at the beginning so they show up first
          reelTemplates.insertAll(0, userReels);
        }
      } catch (e) {
        debugPrint(
          "⚠️ [ContentCreationController] Note: Could not fetch user reels: $e",
        );
        // Non-critical, so we don't crash the whole fetch
      }

      debugPrint(
        "✅ [ContentCreationController] Fetch Complete. Total Reels (Templates + User): ${reelTemplates.length}",
      );
    } catch (e) {
      debugPrint("⛔ ContentCreationController Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Template ID from which this creation started
  final RxString templateId = ''.obs;

  // Final processed media path (Single)
  final RxString mediaPath = ''.obs;

  // Selected Media Files (Multiple - for Carousel)
  final RxList<File> selectedFiles = <File>[].obs;

  // Content Type (post, reel, story, carousel)
  final RxString selectedContentType = 'post'.obs;

  // Caption generated or edited
  final RxString caption = ''.obs;

  // Hashtags selected or edited
  final RxList<String> hashtags = <String>[].obs;

  // Is media an image or video
  final RxBool isImage = false.obs;

  // Scheduling data
  final RxString selectedPlatform = 'Facebook'.obs;
  final RxBool remindMe = true.obs;
  final Rx<DateTime?> scheduledDate = Rx<DateTime?>(null);
  final RxString scheduledTime = ''.obs; // e.g., "05:00 PM"

  // Video Filters
  final Rx<List<double>?> selectedFilterMatrix = Rx<List<double>?>(null);

  void reset() {
    templateId.value = '';
    mediaPath.value = '';
    selectedFiles.clear();
    selectedContentType.value = 'post';
    caption.value = '';
    hashtags.clear();
    isImage.value = false;
    selectedPlatform.value = 'Facebook';
    remindMe.value = true;
    scheduledDate.value = null;
    scheduledTime.value = '';
    selectedFilterMatrix.value = null;
  }

  void updateMetadata({String? newCaption, List<String>? newHashtags}) {
    if (newCaption != null) caption.value = newCaption;
    if (newHashtags != null) {
      hashtags.assignAll(newHashtags);
    }
  }
}
