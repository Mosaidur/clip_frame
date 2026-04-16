import 'package:flutter/material.dart';
import 'package:clip_frame/core/model/premium_plan_model.dart';
import 'package:clip_frame/core/services/api_services/premium_plan_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';

class PremiumSelectionController extends GetxController {
  final PremiumPlanService _service = PremiumPlanService();

  var isLoading = false.obs;
  var plans = <PremiumPlanModel>[].obs;
  var selectedPlan = Rxn<PremiumPlanModel>();
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlans();
  }

  void selectPlan(PremiumPlanModel plan) {
    selectedPlan.value = plan;
  }

  Future<void> subscribe() async {
    if (selectedPlan.value == null) {
      Get.snackbar("Error", "Please select a plan first");
      return;
    }

    isLoading(true);
    try {
      final response =
          await _service.createSubscription(selectedPlan.value!.id);

      if (response.statusCode == 201 && response.responseBody != null) {
        final data = response.responseBody!['data'];
        final clientSecret = data['clientSecret'];

        // 1. Initialize Payment Sheet
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'ClipFrame',
            style: ThemeMode.dark,
          ),
        );

        // 2. Present Payment Sheet
        await Stripe.instance.presentPaymentSheet();

        Get.snackbar("Success", "Subscription created successfully!");
        Get.back(); // Go back to profile or home
      } else if (response.statusCode == 409) {
        Get.snackbar("Info", "You already have an active subscription");
      } else {
        String msg = response.errorMessage ?? "Failed to create subscription";
        Get.snackbar("Error", msg);
      }
    } catch (e) {
      if (e is StripeException) {
        Get.snackbar("Payment Error", e.error.localizedMessage ?? "Canceled");
      } else {
        Get.snackbar("Error", "An unexpected error occurred: $e");
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchPlans() async {
    isLoading(true);
    errorMessage('');
    try {
      final response = await _service.getPremiumPlans();
      if (response.isSuccess && response.responseBody != null) {
        final List<dynamic> plansJson = response.responseBody!['data'] ?? [];
        final List<PremiumPlanModel> fetchedPlans =
            plansJson.map((json) => PremiumPlanModel.fromJson(json)).toList();

        plans.assignAll(fetchedPlans);

        // Select the first plan by default if any exist
        if (fetchedPlans.isNotEmpty) {
          selectedPlan.value = fetchedPlans.first;
        }
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
