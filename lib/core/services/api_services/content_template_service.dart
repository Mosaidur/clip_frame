import 'package:clip_frame/core/model/content_template_model.dart';
import 'package:clip_frame/core/services/api_services/network_caller.dart';
import 'package:clip_frame/core/services/api_services/urls.dart';
import 'package:clip_frame/core/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class ContentTemplateService {
  static Future<List<ContentTemplateModel>> fetchTemplates() async {
    try {
      final token = await AuthService.getToken();
      final response = await NetworkCaller.getRequest(
        url: Urls.contentTemplateUrl,
        token: token,
      );

      if (response.isSuccess && response.responseBody != null) {
        final dynamic body = response.responseBody;
        dynamic rawData;

        // Try different structures: data -> data OR just data OR content_templates
        if (body['data'] != null) {
          if (body['data'] is Map && body['data']['data'] != null) {
            rawData = body['data']['data'];
          } else if (body['data'] is List) {
            rawData = body['data'];
          }
        } else if (body['content_templates'] != null) {
          rawData = body['content_templates'];
        } else if (body is List) {
          rawData = body;
        }

        if (rawData is List) {
          return rawData
              .map((json) => ContentTemplateModel.fromJson(json))
              .toList();
        } else {
          debugPrint(
            "⚠️ ContentTemplateService: No list data found in response",
          );
          return [];
        }
      } else {
        debugPrint("❌ ContentTemplateService: Response failed or body is null");
        return [];
      }
    } catch (e) {
      debugPrint("⛔ ContentTemplateService Error: $e");
      return [];
    }
  }

  static Future<List<ContentTemplateModel>> fetchTemplatesByType(
    String type,
  ) async {
    final allTemplates = await fetchTemplates();
    if (allTemplates.isEmpty) return [];

    return allTemplates
        .where((t) => t.type?.toLowerCase() == type.toLowerCase())
        .toList();
  }
}
