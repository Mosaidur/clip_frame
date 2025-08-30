import 'package:clip_frame/Shared/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var rememberMe = false.obs;
  var obscurePassword = true.obs;

  void toggleRememberMe(bool value) {
    rememberMe.value = value;
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void login() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('error'.tr, 'pleaseEnterEmailPassword'.tr);
    } else {
      // Get.snackbar('success'.tr, 'loggedInAs'.tr + email);
      Get.toNamed(AppRoutes.HOME);
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
