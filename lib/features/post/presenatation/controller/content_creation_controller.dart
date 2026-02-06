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
      // Fetch all types in parallel
      final results = await Future.wait([
        ContentTemplateService.fetchTemplates(type: 'reels'),
        ContentTemplateService.fetchTemplates(type: 'posts'),
        ContentTemplateService.fetchTemplates(type: 'stories'),
      ]);

      reelTemplates.assignAll(results[0]);
      postTemplates.assignAll(results[1]);
      storyTemplates.assignAll(results[2]);

      // If empty, try generic fetch as fallback for reels (legacy behavior)
      if (reelTemplates.isEmpty &&
          postTemplates.isEmpty &&
          storyTemplates.isEmpty) {
        var generic = await ContentTemplateService.fetchTemplates();
        reelTemplates.assignAll(generic);
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
