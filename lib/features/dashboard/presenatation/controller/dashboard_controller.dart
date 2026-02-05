import 'package:clip_frame/core/model/content_template_model.dart';
import 'package:clip_frame/core/services/api_services/content_template_service.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class DashboardController extends GetxController {
  var recentTemplates = <ContentTemplateModel>[].obs;
  var forYouTemplates = <ContentTemplateModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;

      // Fetch Most Recent (General templates, limited to 7)
      final allTemplates = await ContentTemplateService.fetchTemplates();
      debugPrint(
        "📊 Dashboard: Fetched ${allTemplates.length} total templates from API",
      );

      recentTemplates.value = allTemplates.take(7).toList();
      debugPrint("📌 Dashboard - Most Recent:");
      for (var t in recentTemplates) {
        debugPrint("  - ID: ${t.id}, Title: ${t.title}");
      }

      // Fetch For You (Combination of different types if available)
      var shuffled = List<ContentTemplateModel>.from(allTemplates)..shuffle();
      forYouTemplates.value = shuffled.take(7).toList();
      debugPrint("📌 Dashboard - For You:");
      for (var t in forYouTemplates) {
        debugPrint("  - ID: ${t.id}, Title: ${t.title}");
      }
    } catch (e) {
      debugPrint("⛔ DashboardController Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
