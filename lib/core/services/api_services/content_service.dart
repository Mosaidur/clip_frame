import 'package:clip_frame/core/services/api_services/network_caller.dart';
import 'package:clip_frame/core/services/api_services/urls.dart';
import 'package:clip_frame/core/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class ContentService {
  static Future<NetworkResponse> createContent({
    required String templateId,
    required String caption,
    List<File>? files,
    String? mediaPath,
    required String contentType,
    required Map<String, dynamic> scheduledAt,
    required bool remindMe,
    required List<String> platform,
    required List<String> tags,
    List<String>? preferredLanguages,
  }) async {
    try {
      final token = await AuthService.getToken();
      final url = Urls.createContentUrl(templateId);

      // Check if any of the files are videos
      bool isVideo = false;
      if (files != null && files.isNotEmpty) {
        isVideo = files.any((f) => f.path.toLowerCase().endsWith('.mp4'));
      } else if (mediaPath != null && mediaPath.isNotEmpty) {
        isVideo = mediaPath.toLowerCase().endsWith('.mp4');
      }

      final Map<String, dynamic> body = {
        "caption": caption,
        "contentType": (isVideo && contentType == "post")
            ? "reel"
            : contentType,
        "scheduledAt": scheduledAt,
        "remindMe": remindMe,
        "status": "draft",
        "platform": platform,
        "tags": tags,
        "preferredLanguages": preferredLanguages ?? ["en"],
      };

      final String fileKey = (isVideo)
          ? 'media'
          : (contentType == "post" ||
                contentType == "carousel" ||
                contentType == "story")
          ? 'image'
          : 'media';

      debugPrint(
        "🚀 [ContentService] Creating content (Multipart) for template: $templateId using key: $fileKey, type: $contentType",
      );

      final NetworkResponse response;
      // If we have multiple files, use postMultipartRequestList regardless of contentType
      if (files != null && files.length > 1) {
        response = await NetworkCaller.postMultipartRequestList(
          url: url,
          body: body,
          fileKey: fileKey,
          files: files,
          token: token,
          wrapInData: true,
        );
      } else if (files != null && files.isNotEmpty) {
        response = await NetworkCaller.postMultipartRequest(
          url: url,
          body: body,
          fileKey: fileKey,
          file: files[0],
          token: token,
          wrapInData: true,
        );
      } else if (mediaPath != null && mediaPath.isNotEmpty) {
        response = await NetworkCaller.postMultipartRequest(
          url: url,
          body: body,
          fileKey: fileKey,
          file: File(mediaPath),
          token: token,
          wrapInData: true,
        );
      } else {
        return NetworkResponse(
          isSuccess: false,
          statusCode: -1,
          errorMessage: "No media provided for creation",
        );
      }

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
    List<String>? preferredLanguages,
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
        "preferredLanguages": preferredLanguages ?? ["en"],
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

  static Future<NetworkResponse> deleteContent(String id) async {
    try {
      final token = await AuthService.getToken();
      final url = Urls.deleteContentUrl(id);

      debugPrint(
        "🚀 [ContentService] Deleting content for ID: $id at URL: $url",
      );
      final response = await NetworkCaller.deleteRequest(
        url: url,
        token: token,
      );

      return response;
    } catch (e) {
      debugPrint("⛔ [ContentService] Error deleting content: $e");
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }
}
