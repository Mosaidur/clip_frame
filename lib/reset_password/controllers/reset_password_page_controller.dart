import 'package:clip_frame/core/services/api_services/authentication/reset_password_controller.dart' as api;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Shared/routes/routes.dart';

class ResetPasswordPageController extends GetxController {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var isLoading = false.obs;
  var obscureNewPassword = true.obs;
  var obscureConfirmPassword = true.obs;

  // Email and token passed from email verification screen
  String email = '';
  String? token;

  // API Controller instance
  final api.ResetPasswordController _apiController = api.ResetPasswordController();

  @override
  void onInit() {
    super.onInit();
    // Get arguments from route - can be email string or map with email and token
    final args = Get.arguments;
    if (args is String) {
      email = args;
    } else if (args is Map) {
      email = args['email'] ?? '';
      token = args['token'];
    }
    print("📝 Reset Password - Email: $email, Token: $token");
  }

  void toggleNewPasswordVisibility() {
    obscureNewPassword.value = !obscureNewPassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  Future<void> resetPassword() async {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar('error'.tr, 'Please fill all fields');
      return;
    }

    if (newPassword.length < 8) {
      Get.snackbar('error'.tr, 'Password must be at least 8 characters');
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar('error'.tr, 'Passwords do not match');
      return;
    }

    isLoading.value = true;

    try {
      bool success = await _apiController.resetPassword(newPassword, confirmPassword, token);

      if (success) {
        Get.snackbar('success'.tr, 'Password reset successfully!');
        // Navigate to login screen
        Get.offAllNamed(AppRoutes.login);
      } else {
        Get.snackbar(
          'error'.tr,
          _apiController.errorMessage ?? 'Failed to reset password',
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

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
