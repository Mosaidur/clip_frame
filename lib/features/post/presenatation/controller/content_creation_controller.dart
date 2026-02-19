import 'package:clip_frame/core/model/content_template_model.dart';
import 'package:clip_frame/core/services/api_services/content_template_service.dart';
import 'package:get/get.dart';

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
    fetchAllTemplates();
  }

  Future<void> fetchAllTemplates() async {
    isLoading.value = true;
    try {
      // Fetch all templates and filter locally to ensure robustness
      final allTemplates = await ContentTemplateService.fetchTemplates();

      if (allTemplates.isNotEmpty) {
        // Filter for Reels (reels, reel, video, short)
        // Filter for Reels (reels, reel, video, short) - TEMPORARY DEBUG: SHOW ALL
        reelTemplates.assignAll(allTemplates);
        /*
        reelTemplates.assignAll(
          allTemplates.where((t) {
            final type = (t.type ?? '').toLowerCase();
            return type.contains('reel') ||
                type.contains('video') ||
                type.contains('short');
          }).toList(),
        );
        */

        // Filter for Posts (posts, post, image)
        postTemplates.assignAll(
          allTemplates.where((t) {
            final type = (t.type ?? '').toLowerCase();
            return type == 'post' || type == 'posts' || type == 'image';
          }).toList(),
        );

        // Filter for Stories (stories, story)
        storyTemplates.assignAll(
          allTemplates.where((t) {
            final type = (t.type ?? '').toLowerCase();
            return type.contains('story');
          }).toList(),
        );
      } else {
        // Clear all if empty
        reelTemplates.clear();
        postTemplates.clear();
        storyTemplates.clear();
      }
    } catch (e) {
      print("Error fetching templates: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Template ID from which this creation started
  final RxString templateId = ''.obs;

  // Final processed media path
  final RxString mediaPath = ''.obs;

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

  void reset() {
    templateId.value = '';
    mediaPath.value = '';
    caption.value = '';
    hashtags.clear();
    isImage.value = false;
    selectedPlatform.value = 'Facebook';
    remindMe.value = true;
    scheduledDate.value = null;
    scheduledTime.value = '';
  }

  void updateMetadata({String? newCaption, List<String>? newHashtags}) {
    if (newCaption != null) caption.value = newCaption;
    if (newHashtags != null) {
      hashtags.assignAll(newHashtags);
    }
  }
}
