import 'package:clip_frame/core/services/api_services/network_caller.dart';
import 'package:clip_frame/core/services/api_services/urls.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './onboarding_status_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';

  static Future<void> saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(_tokenKey);
    print(
      "💎 AuthService: Token in storage is ${token != null ? 'Present' : 'NULL'}",
    );
    return token;
  }

  static Future<bool> refreshToken() async {
    String? currentToken = await getToken();
    if (currentToken == null || currentToken.isEmpty) return false;

    print("🔄 AuthService: Attempting to refresh token...");
    NetworkResponse response = await NetworkCaller.postRequest(
      url: Urls.refreshTokenUrl,
      body:
          {}, // Send empty map instead of null to avoid "Unexpected token 'n', 'null' is not valid JSON" error
      token: currentToken,
      isRefreshCall: true,
    );

    if (response.isSuccess && response.responseBody != null) {
      var data = response.responseBody!['data'];
      String? newToken;
      if (data is Map && data.containsKey('token')) {
        newToken = data['token'];
      } else if (data is Map && data.containsKey('accessToken')) {
        newToken = data['accessToken'];
      }

      if (newToken != null) {
        await saveToken(newToken);
        print("✅ AuthService: Token refreshed successfully");
        return true;
      }
    }

    print("❌ AuthService: Token refresh failed");
    return false;
  }

  static Future<void> clearData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    // Note: We no longer clear onboarding status here as it's now tracked per user email
  }
}
