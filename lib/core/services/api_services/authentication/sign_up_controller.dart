import 'package:clip_frame/core/services/api_services/network_caller.dart';
import 'package:clip_frame/core/services/api_services/urls.dart';
import 'package:get/get.dart';

class signUp_Controller extends GetxController {
  var _inProgress = false.obs;
  var _errorMessage = ''.obs;

  bool get inProgress => _inProgress.value;
  String? get errorMessage => _errorMessage.value.isEmpty ? null : _errorMessage.value;

  Future<bool> SignUp(
    String email,
    String password,
    String firstName,
    String lastName,
    String confirmPassword,
    String phone,
  ) async {
    _inProgress.value = true;
    bool isSuccess = false;

    //call api
    
    // Normalize phone number: remove spaces, ensure proper format
    String normalizedPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // If phone starts with 0, replace with +880
    if (normalizedPhone.startsWith('0')) {
      normalizedPhone = '+880${normalizedPhone.substring(1)}';
    } 
    // If phone starts with 88 but not +88, add +
    else if (normalizedPhone.startsWith('88') && !normalizedPhone.startsWith('+')) {
      normalizedPhone = '+$normalizedPhone';
    }
    // If phone doesn't start with +, assume it needs +880
    else if (!normalizedPhone.startsWith('+')) {
      normalizedPhone = '+880$normalizedPhone';
    }

    Map<String, String> requestBody = {
      "name": "$firstName $lastName",
      "email": email,
      "password": password,
      "phone": normalizedPhone,
    };

    print("📤 Signup Request Body: $requestBody");

    NetworkResponse response = await NetworkCaller.postRequest(
      url: Urls.signupUrl,
      body: requestBody,
    );
    if (response.isSuccess && response.responseBody?['data'] != null) {
      isSuccess = true;
    } else {
      _errorMessage.value = response.errorMessage ?? 'Signup failed';
    }
    _inProgress.value = false;
    return isSuccess;
  }
}
