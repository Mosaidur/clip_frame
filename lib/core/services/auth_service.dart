import 'package:clip_frame/core/services/api_services/network_caller.dart';
import 'package:clip_frame/core/services/api_services/urls.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
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
    try {
      NetworkResponse response = await NetworkCaller.postRequest(
        url: Urls.refreshTokenUrl,
        body: {}, 
        token: currentToken,
        isRefreshCall: true,
      );

      if (response.isSuccess && response.responseBody != null) {
        var data = response.responseBody!['data'];
        String? newToken;
        if (data is Map) {
          newToken = data['token'] ?? data['accessToken'];
        }

        if (newToken != null) {
          await saveToken(newToken);
          print("✅ AuthService: Token refreshed successfully");
          return true;
        }
      }
    } catch (e) {
      print("⛔ AuthService: Error during token refresh: $e");
    }

    print("❌ AuthService: Token refresh failed");
    return false;
  }

  static Future<void> forceLogout() async {
    print("🚪 AuthService: Forcing logout due to invalid/expired session");
    await clearData();
    // Navigate to welcome screen using GetX
    Get.offAllNamed('/welcome'); 
  }

  static Future<void> clearData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    // Note: We no longer clear onboarding status here as it's now tracked per user email
  }
}
