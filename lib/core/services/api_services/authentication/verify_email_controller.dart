import 'package:clip_frame/core/services/api_services/network_caller.dart';
import 'package:clip_frame/core/services/api_services/urls.dart';
import 'package:get/get.dart';

class VerifyEmailController extends GetxController {
  var _inProgress = false.obs;
  var _errorMessage = ''.obs;

  bool get inProgress => _inProgress.value;
  String? get errorMessage => _errorMessage.value.isEmpty ? null : _errorMessage.value;

  Future<bool> verifyEmail(
    String email,
    String otp,
  ) async {
    _inProgress.value = true;
    bool isSuccess = false;

    Map<String, String> requestBody = {
      "email": email,
      "oneTimeCode": otp,
    };

    print("📤 Verify Email Request Body: $requestBody");

    NetworkResponse response = await NetworkCaller.postRequest(
      url: Urls.verifyEmailUrl,
      body: requestBody,
    );
    
    if (response.isSuccess && response.responseBody?['data'] != null) {
      isSuccess = true;
    } else {
      _errorMessage.value = response.errorMessage ?? 'Verification failed';
    }
    _inProgress.value = false;
    return isSuccess;
  }

  Future<bool> resendOTP(String email) async {
    _inProgress.value = true;
    bool isSuccess = false;

    Map<String, String> requestBody = {
      "email": email,
    };

    print("📤 Resend OTP Request Body: $requestBody");

    NetworkResponse response = await NetworkCaller.postRequest(
      url: Urls.resendOTPUrl,
      body: requestBody,
    );
    
    if (response.isSuccess) {
      isSuccess = true;
    } else {
      _errorMessage.value = response.errorMessage ?? 'Failed to resend OTP';
    }
    _inProgress.value = false;
    return isSuccess;
  }
}