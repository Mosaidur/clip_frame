import 'package:clip_frame/core/services/api_services/network_caller.dart';
import 'package:clip_frame/core/services/api_services/urls.dart';
import 'package:get/get.dart';

class ResetPasswordController extends GetxController {
  var _inProgress = false.obs;
  var _errorMessage = ''.obs;

  bool get inProgress => _inProgress.value;
  String? get errorMessage => _errorMessage.value.isEmpty ? null : _errorMessage.value;

  Future<bool> resetPassword(
    String newPassword,
    String confirmPassword,
    String? token,
  ) async {
    _inProgress.value = true;
    bool isSuccess = false;

    // Only email and passwords in body
    Map<String, dynamic> requestBody = {
      "newPassword": newPassword,
      "confirmPassword": confirmPassword,
    };

    print("📤 Reset Password Request Body: $requestBody");

    // Pass token via the token parameter, which NetworkCaller puts in the Authorization header
    NetworkResponse response = await NetworkCaller.postRequest(
      url: Urls.resetPasswordUrl,
      body: requestBody,
      token: token,
    );

    if (response.isSuccess) {
      isSuccess = true;
    } else {
      _errorMessage.value = response.errorMessage ?? 'Failed to reset password';
    }
    _inProgress.value = false;
    return isSuccess;
  }
}
