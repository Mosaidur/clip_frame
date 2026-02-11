import 'package:clip_frame/core/services/api_services/network_caller.dart';
import 'package:clip_frame/core/services/api_services/urls.dart';
import 'package:clip_frame/core/services/auth_service.dart';

class SocialAuthService {
  Future<bool> connectFacebook(String accessToken) async {
    return _sendTokenToBackend(Urls.connectFacebook, accessToken);
  }

  Future<bool> connectInstagram(String accessToken) async {
    return _sendTokenToBackend(Urls.connectInstagram, accessToken);
  }

  Future<bool> _sendTokenToBackend(String url, String accessToken) async {
    try {
      final String? userToken = await AuthService.getToken();

      if (userToken == null) {
        print("❌ No user token found for social integration");
        return false;
      }

      print("📤 Sending Social Token to: $url");

      // The backend expects { "token": "..." }
      Map<String, dynamic> body = {"token": accessToken};

      final response = await NetworkCaller.postRequest(
        url: url,
        body: body,
        token:
            userToken, // network_caller likely handles the Authorization header if we pass this or if it grabs from AuthService internal
      );

      print(
        "📥 Social Auth Response: ${response.statusCode} - ${response.responseBody}",
      );

      if (response.isSuccess) {
        return true;
      } else {
        print("❌ Social Auth Failed: ${response.errorMessage}");
        return false;
      }
    } catch (e) {
      print("❌ Error in social auth: $e");
      return false;
    }
  }
}
