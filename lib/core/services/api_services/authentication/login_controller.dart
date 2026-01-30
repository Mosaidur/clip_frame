import 'package:clip_frame/core/services/api_services/network_caller.dart';
import 'package:clip_frame/core/services/api_services/urls.dart';
import 'package:clip_frame/core/services/auth_service.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  var _inProgress = false.obs;
  var _errorMessage = ''.obs;

  bool get inProgress => _inProgress.value;
  String? get errorMessage => _errorMessage.value.isEmpty ? null : _errorMessage.value;

  Future<bool> login(
    String email,
    String password,
  ) async {
    _inProgress.value = true;
    bool isSuccess = false;

    //call api

    Map<String, String> requestBody = {
      "email": email,
      "password": password,
    };

    NetworkResponse response = await NetworkCaller.postRequest(
      url: Urls.loginUrl,
      body: requestBody,
      isFromLogin: true,
    );
    if (response.isSuccess && response.responseBody?['data'] != null) {
      isSuccess = true;
      // Save token
      var data = response.responseBody!['data'];
      String? token;
      if (data is Map && data.containsKey('token')) {
        token = data['token'];
      } else if (data is Map && data.containsKey('accessToken')) {
        token = data['accessToken'];
      }
      
      if (token != null) {
        await AuthService.saveToken(token);
      }
    } else {
      _errorMessage.value = response.errorMessage ?? 'Login failed';
    }
    _inProgress.value = false;
    return isSuccess;
  }
}