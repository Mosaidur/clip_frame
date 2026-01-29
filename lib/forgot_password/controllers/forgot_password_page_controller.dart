import 'package:clip_frame/core/services/api_services/authentication/forgot_password_controller.dart' as api;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Shared/routes/routes.dart';

class ForgotPasswordPageController extends GetxController {
  final emailController = TextEditingController();
  var isLoading = false.obs;

  // API Controller instance
  final api.ForgotPasswordController _apiController = api.ForgotPasswordController();

  Future<void> submitEmail() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      Get.snackbar('error'.tr, 'Please enter your email');
      return;
    }

    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      Get.snackbar('error'.tr, 'Please enter a valid email');
      return;
    }

    isLoading.value = true;

    try {
      bool success = await _apiController.forgotPassword(email);

      if (success) {
        Get.snackbar('success'.tr, 'Verification code sent to your email!');
        // Navigate to email verification screen with isForPasswordReset flag
        Get.toNamed(AppRoutes.emailVerification, arguments: {
          'email': email,
          'isForPasswordReset': true,
        });
      } else {
        Get.snackbar(
          'error'.tr,
          _apiController.errorMessage ?? 'Failed to send reset code',
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
    emailController.dispose();
    super.onClose();
  }
}
