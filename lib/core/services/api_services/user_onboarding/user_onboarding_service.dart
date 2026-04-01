import 'dart:io';
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

  /// Submit onboarding data together with the logo image as multipart/form-data.
  Future<bool> submitOnboardingWithLogo({
    required Map<String, dynamic> data,
    required File logoFile,
    String? token,
  }) async {
    token ??= await AuthService.getToken();
    final response = await NetworkCaller.postMultipartRequest(
      url: Urls.userOnboardingUrl,
      body: data,
      fileKey: 'logo',
      file: logoFile,
      token: token,
    );
    return response.isSuccess;
  }
}
