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

  // Validation regex
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final phoneRegex = RegExp(r'^\+?1?\d{9,15}$');

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
  void signUp() {
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
      Get.snackbar('error'.tr, 'Please Enter Valid Phone');
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

    // Simulate signup process
    isLoading.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
      Get.snackbar('success'.tr, 'signedUpAs'.tr + email);
      // Navigate or API call here
    });

    if (areAllFieldsFilled()) {
      print("Navigating to RegistrationProcess...");
      Get.toNamed(AppRoutes.RegistrationProcess);
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
