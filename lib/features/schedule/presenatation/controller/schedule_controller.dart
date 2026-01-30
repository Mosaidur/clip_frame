import 'package:get/get.dart';
import 'package:clip_frame/core/services/api_services/network_caller.dart';
import 'package:clip_frame/core/services/api_services/urls.dart';
import 'package:clip_frame/core/services/auth_service.dart';
import '../../data/model.dart';

class ScheduleController extends GetxController {
  var scheduledPosts = <SchedulePost>[].obs;
  var historyPosts = <HistoryPost>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Add selected tab state
  var selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Load both types on init, or load based on tab.
    // Let's load both for now to be safe.
    fetchSchedules("scheduled");
    fetchSchedules("published");
  }

  Future<void> fetchSchedules(String status) async {
    isLoading.value = true;
    errorMessage.value = '';

    final String? token = await AuthService.getToken();
    
    // Construct URL with query parameter
    // Base URL in Urls.dart already has ?status=published for schedulingUrl variable, 
    // but better to construct cleanly if we want dynamic status.
    // The user provided: static const String schedulingUrl = "$baseUrl/api/v1/content/my-contents?status=published";
    // We should probably strip the query param from the constant or replace it.
    // Let's assume we modify the URL dynamically.
    
    // Workaround: We'll take the base part of schedulingUrl or hardcode the path if needed.
    // Assuming Urls.schedulingUrl is the base for this feature.
    // Let's use a cleaner approach: base path + query.
    
    String baseUrlClean = Urls.schedulingUrl.split('?')[0];
    String url = "$baseUrlClean?status=$status";

    if (token == null) {
      // Handle unauthorized or missing token
      isLoading.value = false;
      return;
    }

    final response = await NetworkCaller.getRequest(url: url, token: token);

    if (response.isSuccess) {
      if (response.responseBody != null && response.responseBody!['data'] != null) {
        // Response structure: { success: true, data: { meta: {}, data: [] } }
        var responseData = response.responseBody!['data'];
        
        List<dynamic> listData = [];
        
        if (responseData is Map && responseData['data'] != null) {
           listData = responseData['data'];
        } else if (responseData is List) {
           // Fallback in case structure changes or is different for some endpoints
           listData = responseData;
        }

        if (status == "scheduled") {
           scheduledPosts.value = listData.map((json) => SchedulePost.fromJson(json)).toList();
        } else if (status == "published") {
           historyPosts.value = listData.map((json) => HistoryPost.fromJson(json)).toList();
        }
      }
    } else {
      errorMessage.value = response.errorMessage ?? 'Failed to fetch schedules';
    }
    isLoading.value = false;
  }
}
