import 'package:clip_frame/Shared/routes/routes.dart';
import 'package:clip_frame/core/services/api_services/authentication/login_controller.dart' as api;
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
        Get.offAllNamed(AppRoutes.HOME);
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
