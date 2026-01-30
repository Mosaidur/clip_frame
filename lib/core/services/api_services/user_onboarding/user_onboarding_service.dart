import 'package:clip_frame/core/services/api_services/network_caller.dart';
import 'package:clip_frame/core/services/api_services/urls.dart';
import 'package:clip_frame/core/services/auth_service.dart';

class UserOnboardingService {
  Future<bool> submitOnboardingData(Map<String, dynamic> data) async {
    String? token = await AuthService.getToken();
    final response = await NetworkCaller.postRequest(
      url: Urls.userOnboardingUrl,
      body: data,
      token: token,
    );
    return response.isSuccess;
  }
}
