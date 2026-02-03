import 'package:clip_frame/core/services/api_services/network_caller.dart';
import 'package:clip_frame/core/services/api_services/urls.dart';
import 'package:clip_frame/core/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class ContentService {
  static Future<NetworkResponse> createContent({
    required String templateId,
    required String caption,
    required String mediaPath,
    required String contentType,
    required Map<String, dynamic> scheduledAt,
    required bool remindMe,
    required List<String> platform,
    required List<String> tags,
  }) async {
    try {
      final token = await AuthService.getToken();
      final url = Urls.createContentUrl(templateId);

      final Map<String, dynamic> body = {
        "caption": caption,
        "contentType": contentType,
        "scheduledAt": scheduledAt,
        "remindMe": remindMe,
        "status": "draft",
        "platform": platform,
        "tags": tags,
      };

      final String fileKey = contentType == "post" ? 'image' : 'media';

      debugPrint(
        "🚀 [ContentService] Creating content (Multipart) for template: $templateId using key: $fileKey",
      );
      final response = await NetworkCaller.postMultipartRequest(
        url: url,
        body: body,
        fileKey: fileKey,
        file: File(mediaPath),
        token: token,
      );

      return response;
    } catch (e) {
      debugPrint("⛔ [ContentService] Error creating content: $e");
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }

  static Future<NetworkResponse> updateContent({
    required String id,
    required String caption,
    required Map<String, dynamic> scheduledAt,
    required bool remindMe,
    required List<String> platform,
    required List<String> tags,
  }) async {
    try {
      final token = await AuthService.getToken();
      final url = Urls.updateContentUrl(id);

      final Map<String, dynamic> body = {
        "caption": caption,
        "scheduledAt": scheduledAt,
        "remindMe": remindMe,
        "platform": platform,
        "tags": tags,
      };

      debugPrint(
        "🚀 [ContentService] Updating content for ID: $id at URL: $url (Using PATCH)",
      );
      final response = await NetworkCaller.patchRequest(
        url: url,
        body: body,
        token: token,
      );

      return response;
    } catch (e) {
      debugPrint("⛔ [ContentService] Error updating content: $e");
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }
}
