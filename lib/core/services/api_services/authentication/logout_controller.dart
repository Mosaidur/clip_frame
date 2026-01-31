import 'package:clip_frame/core/services/api_services/network_caller.dart';
import 'package:clip_frame/core/services/api_services/urls.dart';
import 'package:clip_frame/core/services/auth_service.dart';
import 'package:get/get.dart';

class LogoutController extends GetxController {
  var _inProgress = false.obs;
  var _errorMessage = ''.obs;

  bool get inProgress => _inProgress.value;
  String? get errorMessage => _errorMessage.value.isEmpty ? null : _errorMessage.value;

  Future<bool> logout() async {
    _inProgress.value = true;
    _errorMessage.value = '';
    bool isSuccess = false;

    // Fetch token
    print("🔍 Fetching token from AuthService...");
    String? token = await AuthService.getToken();
    
    if (token == null || token.isEmpty) {
      print("⚠️ WARNING: Logout attempted but no token was found in local storage.");
    } else {
      print("🔑 Logout Token Found: ${token.substring(0, 10)}..."); // Log first 10 chars for safety
    }

    // Call logout API
    print("📡 Sending POST request to ${Urls.logoutUrl}");
    NetworkResponse response = await NetworkCaller.postRequest(
      url: Urls.logoutUrl,
      body: {}, 
      token: token,
    );

    if (response.isSuccess) {
      isSuccess = true;
      print("📡 Logout API Success: true");
    } else {
      _errorMessage.value = response.errorMessage ?? 'Logout API failed';
      print("❌ Logout API Error: ${response.errorMessage}");
    }

    _inProgress.value = false;
    return isSuccess;
  }
}
