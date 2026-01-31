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
    print("💎 AuthService: Token in storage is ${token != null ? 'Present' : 'NULL'}");
    return token;
  }

  static Future<void> clearData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    // Note: We no longer clear onboarding status here as it's now tracked per user email
  }
}
