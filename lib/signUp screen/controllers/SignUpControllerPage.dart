import 'package:clip_frame/core/services/api_services/authentication/sign_up_controller.dart' as api;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Shared/routes/routes.dart';

class SignUpController extends GetxController {
  // Controllers for form fields
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  // Reactive variables
  var obscurePassword = true.obs;
  var obscureConfirmPassword = true.obs;
  var isLoading = false.obs;

  // API Controller instance
  final api.signUp_Controller _apiController = api.signUp_Controller();

  // Validation regex
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  // Updated regex to accept: +8801XXXXXXXXX, 8801XXXXXXXXX, 01XXXXXXXXX, or international format
  final phoneRegex = RegExp(r'^(\+?88)?01[3-9]\d{8}$');

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  /// ✅ Function to check if all fields are filled
  bool areAllFieldsFilled() {
    return emailController.text.trim().isNotEmpty &&
        passwordController.text.trim().isNotEmpty &&
        confirmPasswordController.text.trim().isNotEmpty &&
        phoneController.text.trim().isNotEmpty &&
        firstNameController.text.trim().isNotEmpty &&
        lastNameController.text.trim().isNotEmpty;
  }

  // Signup validation and submission
  Future<void> signUp() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final phone = phoneController.text.trim();
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();

    // ✅ Check if all fields are filled
    if (!areAllFieldsFilled()) {
      Get.snackbar('error'.tr, 'pleaseFillAllFields'.tr);
      return;
    }

    // Validation checks
    if (firstName.isEmpty || lastName.isEmpty) {
      Get.snackbar('error'.tr, 'pleaseEnterFullName'.tr);
      return;
    }

    if (!emailRegex.hasMatch(email)) {
      Get.snackbar('error'.tr, 'please EnterValidEmail'.tr);
      return;
    }

    if (phone.isNotEmpty && !phoneRegex.hasMatch(phone)) {
      Get.snackbar('error'.tr, 'Please Enter Valid Phone Number (e.g., 01XXXXXXXXX or +8801XXXXXXXXX)');
      return;
    }

    if (password.length < 8) {
      Get.snackbar('error'.tr, 'password Must Be 6 Character');
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar('error'.tr, 'Password & Confirm password Do Not Match');
      return;
    }

    // Show loading state
    isLoading.value = true;

    try {
      // Call API
      bool success = await _apiController.SignUp(
        email,
        password,
        firstName,
        lastName,
        confirmPassword,
        phone,
      );

      if (success) {
        Get.snackbar('success'.tr, 'signedUpAs'.tr + email);
        // Navigate to email verification screen with email parameter
        Get.toNamed(AppRoutes.emailVerification, arguments: email);
      } else {
        // Show error message from API
        Get.snackbar(
          'error'.tr,
          _apiController.errorMessage ?? 'signupFailed'.tr,
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

  // Clear all fields
  void clearFields() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    phoneController.clear();
    firstNameController.clear();
    lastNameController.clear();
  }

  @override
  void onClose() {
    // Dispose all controllers
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.onClose();
  }
}
