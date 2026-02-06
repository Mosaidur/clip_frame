import 'package:clip_frame/Shared/routes/routes.dart';
import 'package:clip_frame/core/model/user_model.dart';
import 'package:clip_frame/core/services/api_services/authentication/login_controller.dart'
    as api;
import 'package:clip_frame/core/services/api_services/network_caller.dart';
import 'package:clip_frame/core/services/api_services/urls.dart';
import 'package:clip_frame/core/services/auth_service.dart';
import 'package:clip_frame/core/services/onboarding_status_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var rememberMe = false.obs;
  var obscurePassword = true.obs;
  var isLoading = false.obs;

  // API Controller instance
  final api.LoginController _apiController = api.LoginController();

  @override
  void onInit() {
    super.onInit();

    // Check if coming from email verification with verified email
    final args = Get.arguments;
    if (args != null && args is Map) {
      final verifiedEmail = args['verifiedEmail'];
      final showSuccess = args['showVerificationSuccess'] ?? false;

      if (verifiedEmail != null && verifiedEmail is String) {
        // Pre-fill email field
        emailController.text = verifiedEmail;

        if (showSuccess) {
          // Show success message after a short delay
          Future.delayed(const Duration(milliseconds: 500), () {
            Get.snackbar(
              'success'.tr,
              'Email verified successfully! Please login to continue.',
              backgroundColor: Colors.green.withOpacity(0.7),
              colorText: Colors.white,
            );
          });
        }
      }
    }
  }

  void toggleRememberMe(bool value) {
    rememberMe.value = value;
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('error'.tr, 'pleaseEnterEmailPassword'.tr);
      return;
    }

    // Show loading state
    isLoading.value = true;

    try {
      // Call API
      bool success = await _apiController.login(email, password);

      if (success) {
        Get.snackbar('success'.tr, 'loggedInAs'.tr + email);

        // 1. Initial local check
        bool hasCompletedOnboarding =
            await OnboardingStatusService.isOnboardingComplete(email);

        if (!hasCompletedOnboarding) {
          // 2. Try to verify with backend if local status is false
          try {
            String? token = await AuthService.getToken();
            final response = await NetworkCaller.getRequest(
              url: Urls.getUserProfileUrl,
              token: token,
            );

            if (response.isSuccess && response.responseBody != null) {
              UserResponse userResponse = UserResponse.fromJson(
                response.responseBody!,
              );
              if (userResponse.success && userResponse.data != null) {
                // Sync status if profile says it's onboarded
                await OnboardingStatusService.syncWithProfile(
                  email,
                  userResponse.data,
                );
                hasCompletedOnboarding =
                    await OnboardingStatusService.isOnboardingComplete(email);
              }
            }
          } catch (e) {
            print("Error syncing onboarding status during login: $e");
          }
        }

        if (hasCompletedOnboarding) {
          // User already completed onboarding, go to home
          Get.offAllNamed(AppRoutes.HOME);
        } else {
          // New user or hasn't completed onboarding, go to onboarding
          Get.offAllNamed(AppRoutes.userOnboarding);
        }
      } else {
        // Show error message from API
        Get.snackbar(
          'error'.tr,
          _apiController.errorMessage ?? 'loginFailed'.tr,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'An error occurred: ${e.toString()}',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void googleLogin() {
    Get.snackbar('googleLogin'.tr, 'googleLogin'.tr + ' clicked');
  }

  void facebookLogin() {
    Get.snackbar('facebookLogin'.tr, 'facebookLogin'.tr + ' clicked');
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
