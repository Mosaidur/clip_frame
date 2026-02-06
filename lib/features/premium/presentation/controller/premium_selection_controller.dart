import 'package:clip_frame/core/model/premium_plan_model.dart';
import 'package:clip_frame/core/services/api_services/premium_plan_service.dart';
import 'package:get/get.dart';

class PremiumSelectionController extends GetxController {
  final PremiumPlanService _service = PremiumPlanService();

  var isLoading = false.obs;
  var plans = <PremiumPlanModel>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    isLoading(true);
    errorMessage('');
    try {
      final response = await _service.getPremiumPlans();
      if (response.isSuccess && response.responseBody != null) {
        final List<dynamic> plansJson = response.responseBody!['data'] ?? [];
        plans.assignAll(
          plansJson.map((json) => PremiumPlanModel.fromJson(json)).toList(),
        );
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to load plans';
      }
    } catch (e) {
      errorMessage('An error occurred: $e');
    } finally {
      isLoading(false);
    }
  }
}
