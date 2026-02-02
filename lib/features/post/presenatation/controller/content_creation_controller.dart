import 'package:get/get.dart';

class ContentCreationController extends GetxController {
  static ContentCreationController get to => Get.find();

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
