import 'dart:io';
import 'package:clip_frame/core/services/api_services/network_caller.dart';
import 'package:clip_frame/core/services/api_services/urls.dart';
import 'package:clip_frame/core/services/auth_service.dart';

class UserOnboardingService {
  Future<bool> submitOnboardingData(Map<String, dynamic> data) async {
    String? token = await AuthService.getToken();

    // Prepare the body
    final Map<String, dynamic> body = Map.from(data);

    // Extract branding colors if they exist
    if (data.containsKey('branding')) {
      final branding = data['branding'] as Map<String, dynamic>;
      final List<Map<String, String>> colors = [];
      if (branding.containsKey('primaryColor')) {
        colors.add({"name": "primary", "value": branding['primaryColor']});
      }
      if (branding.containsKey('secondaryColor')) {
        colors.add({"name": "secondary", "value": branding['secondaryColor']});
      }
      body['brandColors'] = colors;
      body.remove('branding');
    }

    final response = await NetworkCaller.postRequest(
      url: Urls.userOnboardingUrl,
      body: body,
      token: token,
    );
    return response.isSuccess;
  }

  /// Submit onboarding data together with the logo image as multipart/form-data.
  Future<bool> submitOnboardingWithLogo({
    required Map<String, dynamic> data,
    required File logoFile,
    String? token,
  }) async {
    token ??= await AuthService.getToken();

    // Prepare the body for individual fields
    final Map<String, dynamic> body = Map.from(data);

    // Extract branding colors if they exist
    if (data.containsKey('branding')) {
      final branding = data['branding'] as Map<String, dynamic>;
      final List<Map<String, String>> colors = [];
      if (branding.containsKey('primaryColor')) {
        colors.add({"name": "primary", "value": branding['primaryColor']});
      }
      if (branding.containsKey('secondaryColor')) {
        colors.add({"name": "secondary", "value": branding['secondaryColor']});
      }
      body['brandColors'] = colors;
      body.remove('branding');
    }

    final response = await NetworkCaller.postMultipartRequest(
      url: Urls.userOnboardingUrl,
      body: body,
      fileKey: 'logo', // Changed back to 'logo' to test if 'image' was wrong
      file: logoFile,
      token: token,
      wrapInData: false, // Send individual fields
    );
    return response.isSuccess;
  }
}
