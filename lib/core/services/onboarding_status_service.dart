import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class OnboardingStatusService {
  static const String _onboardingPrefix = 'onboarding_complete_';
  
  // Internal helper to get key
  static String _getKey(String email) => '$_onboardingPrefix${email.trim().toLowerCase()}';

  /// Save onboarding completion status for a specific email
  static Future<void> markOnboardingComplete(String email) async {
    if (email.isEmpty) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_getKey(email), true);
    print("✅ Onboarding marked as complete for: $email");
  }
  
  /// Check if onboarding is completed for a specific email
  static Future<bool> isOnboardingComplete(String email) async {
    if (email.isEmpty) return false;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool status = prefs.getBool(_getKey(email)) ?? false;
    print("🔍 Checking onboarding status for $email: $status");
    return status;
  }

  /// Helper to extract email from JWT token (for Splash Screen)
  static String? getEmailFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final Map<String, dynamic> data = jsonDecode(payload);
      return data['email'];
    } catch (e) {
      print("❌ Error decoding token: $e");
      return null;
    }
  }
}
