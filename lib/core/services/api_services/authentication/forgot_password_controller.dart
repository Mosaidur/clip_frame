import 'package:clip_frame/core/services/api_services/network_caller.dart';
import 'package:clip_frame/core/services/api_services/urls.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  var _inProgress = false.obs;
  var _errorMessage = ''.obs;

  bool get inProgress => _inProgress.value;
  String? get errorMessage => _errorMessage.value.isEmpty ? null : _errorMessage.value;

  Future<bool> forgotPassword(String email) async {
    _inProgress.value = true;
    bool isSuccess = false;

    Map<String, String> requestBody = {
      "email": email,
    };

    print("📤Forgot Password Request Body: $requestBody");

    NetworkResponse response = await NetworkCaller.postRequest(
      url: Urls.forgotPassword,
      body: requestBody,
    );

    if (response.isSuccess) {
      isSuccess = true;
    } else {
      _errorMessage.value = response.errorMessage ?? 'Failed to send reset email';
    }
    _inProgress.value = false;
    return isSuccess;
  }
}