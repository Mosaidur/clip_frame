import 'package:clip_frame/core/services/api_services/authentication/verify_email_controller.dart' as api;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import '../../Shared/routes/routes.dart';

class EmailVerificationController extends GetxController {
  // OTP input controllers (6 digits)
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  // Focus nodes for OTP fields
  final List<FocusNode> focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  var isLoading = false.obs;
  var canResend = false.obs;
  var resendCountdown = 60.obs;
  Timer? _timer;

  // Email passed from signup or forgot password
  String email = '';
  
  // Flag to indicate if this is for password reset flow
  bool isForPasswordReset = false;

  // API Controller instance
  final api.VerifyEmailController _apiController = api.VerifyEmailController();

  @override
  void onInit() {
    super.onInit();
    // Get arguments from route - can be just email string or a map with email and isForPasswordReset
    final args = Get.arguments;
    if (args is String) {
      email = args;
      isForPasswordReset = false;
    } else if (args is Map) {
      email = args['email'] ?? '';
      isForPasswordReset = args['isForPasswordReset'] ?? false;
    }
    startResendTimer();
  }

  void startResendTimer() {
    canResend.value = false;
    resendCountdown.value = 60;
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown.value > 0) {
        resendCountdown.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  String getOTP() {
    return otpControllers.map((controller) => controller.text).join();
  }

  Future<void> verifyEmail() async {
    final otp = getOTP();

    if (otp.length != 6) {
      Get.snackbar('error'.tr, 'Please enter 6-digit OTP');
      return;
    }

    isLoading.value = true;

    try {
      bool success = await _apiController.verifyEmail(email, otp);

      if (success) {
        Get.snackbar('success'.tr, isForPasswordReset ? 'OTP verified successfully!' : 'Email verified successfully!');
        
        // Navigate based on the flow
        if (isForPasswordReset) {
          // Navigate to reset password screen with email and token
          Get.offNamed(AppRoutes.resetPassword, arguments: {
            'email': email,
            'token': _apiController.resetToken,
          });
        } else {
          // Navigate to registration process or home
          Get.offAllNamed(AppRoutes.RegistrationProcess);
        }
      } else {
        Get.snackbar(
          'error'.tr,
          _apiController.errorMessage ?? 'Verification failed',
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

  Future<void> resendOTP() async {
    if (!canResend.value) return;

    isLoading.value = true;

    try {
      bool success = await _apiController.resendOTP(email);

      if (success) {
        Get.snackbar('success'.tr, 'OTP sent successfully!');
        startResendTimer();
        // Clear OTP fields
        for (var controller in otpControllers) {
          controller.clear();
        }
      } else {
        Get.snackbar(
          'error'.tr,
          _apiController.errorMessage ?? 'Failed to resend OTP',
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
    _timer?.cancel();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.onClose();
  }
}
