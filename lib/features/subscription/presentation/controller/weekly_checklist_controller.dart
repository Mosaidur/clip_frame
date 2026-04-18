import 'package:clip_frame/core/services/api_services/network_caller.dart';
import 'package:clip_frame/core/services/api_services/urls.dart';
import 'package:clip_frame/core/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:clip_frame/features/subscription/data/weekly_checklist_model.dart';

class WeeklyChecklistController extends GetxController {
  var checklistModel = Rxn<WeeklyChecklistModel>();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWeeklyChecklist();
  }

  Future<void> fetchWeeklyChecklist() async {
    isLoading.value = true;
    final String? token = await AuthService.getToken();
    if (token == null) {
      isLoading.value = false;
      return;
    }

    try {
      final response = await NetworkCaller.getRequest(
        url: Urls.weeklyChecklistUrl,
        token: token,
      );

      if (response.isSuccess && response.responseBody != null) {
        final data = response.responseBody!['data'];
        if (data != null) {
          checklistModel.value = WeeklyChecklistModel.fromJson(data);
        }
      }
    } catch (e) {
      print("Error fetching weekly checklist: $e");
    } finally {
      isLoading.value = false;
    }
  }

  int get completedTotal => checklistModel.value?.checklist.where((e) => e.isDone).length ?? 0;
  int get targetTotal => checklistModel.value?.checklist.length ?? 0;
  bool get allTasksCompleted => checklistModel.value?.isFullDone ?? false;

  /// Calculates the overall percentage of completion (e.g. 15 items out of 22 total)
  double get cumulativeProgress {
    if (checklistModel.value == null || checklistModel.value!.checklist.isEmpty) return 0.0;
    
    int totalCompleted = 0;
    int totalTarget = 0;
    
    for (var item in checklistModel.value!.checklist) {
      totalCompleted += item.completed;
      totalTarget += item.target;
    }
    
    return totalTarget > 0 ? (totalCompleted / totalTarget).clamp(0.0, 1.0) : 0.0;
  }

  String get remainingTasksMessage {
    if (checklistModel.value == null) return "Loading...";
    
    final incomplete = checklistModel.value!.checklist.firstWhereOrNull((e) => !e.isDone);
    if (incomplete == null) return "All tasks completed!";

    final diff = incomplete.target - incomplete.completed;
    return "Create $diff more ${incomplete.id.capitalizeFirst}${diff > 1 ? 's' : ''} to reach target";
  }
}
