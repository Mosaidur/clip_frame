import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:clip_frame/core/services/auth_service.dart';
import 'package:http_parser/http_parser.dart'; // For MediaType
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:intl/date_symbols.dart';

class NetworkResponse {
  final bool isSuccess;
  final int statusCode;
  final Map<String, dynamic>? responseBody;
  final String? errorMessage;

  NetworkResponse({
    required this.isSuccess,
    required this.statusCode,
    this.responseBody,
    this.errorMessage,
  });
}

class NetworkCaller {
  static const String _defaultErrorMessage = "Something went wrong😢";
  static const String _unAuthorizeMessage = "Unauthorized Token😒";
  //get request
  static Future<NetworkResponse> getRequest({
    required String url,
    String? token,
    bool showDialog = false,
    bool isRefreshCall = false,
  }) async {
    try {
      Uri uri = Uri.parse(url);
      final Map<String, String> headers = {'content-type': 'application/json'};
      // Add Authorization header if token is provided
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      _logRequest(url, null, headers);

      final http.Response response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));
      logResponse(url, response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedJson = _safeDecode(response.body);
        return NetworkResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          responseBody: decodedJson,
        );
      } else if (response.statusCode == 401) {
        if (!isRefreshCall) {
          debugPrint(
            "⛔ [NetworkCaller] Unauthorized (401). Attempting to refresh token...",
          );
          bool isRefreshed = await AuthService.refreshToken();
          if (isRefreshed) {
            final newToken = await AuthService.getToken();
            debugPrint("📥 [NetworkCaller] Retrying original GET request...");
            return await getRequest(
              url: url,
              token: newToken,
              showDialog: showDialog,
              isRefreshCall: true, // Mark as retry to avoid infinite loops
            );
          } else {
            debugPrint("❌ [NetworkCaller] Refresh failed. Forcing logout.");
            AuthService.forceLogout();
          }
        }

        final decodedJson = _safeDecode(response.body);
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          responseBody: decodedJson,
          errorMessage: _unAuthorizeMessage,
        );
      } else if (response.statusCode >= 500) {
        if (showDialog) {
          _showPremiumError('under_maintenance'.tr, 'server_maintenance_msg'.tr);
        }
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          errorMessage: "server_maintenance_msg".tr,
        );
      } else {
        final decodedJson = _safeDecode(response.body);
        String? errorMsg;
        if (decodedJson != null) {
          if (decodedJson['message'] != null &&
              decodedJson['message'] is String) {
            errorMsg = decodedJson['message'];
          } else if (decodedJson['data'] != null &&
              decodedJson['data'] is String) {
            errorMsg = decodedJson['data'];
          }
        }

        if (showDialog) {
          _showPremiumError("error".tr, errorMsg ?? "something_went_wrong".tr);
        }

        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          responseBody: decodedJson,
          errorMessage: errorMsg ?? _defaultErrorMessage,
        );
      }
    } catch (e) {
      debugPrint("⛔ [NetworkCaller] GET error: $e");
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }

  static Map<String, dynamic>? _safeDecode(String body) {
    try {
      if (body.isEmpty) return null;
      return jsonDecode(body);
    } catch (e) {
      debugPrint("⚠️ [NetworkCaller] JSON Decode failed: $e");
      return null;
    }
  }

  static Future<NetworkResponse> postRequest({
    required String url,
    Map<String, dynamic>? body,
    bool isFromLogin = false,
    String? token,
    bool showDialog = false,
    bool isRefreshCall = false,
  }) async {
    try {
      Uri uri = Uri.parse(url);
      final Map<String, String> headers = {'content-type': 'application/json'};
      // Add Authorization header if token is provided
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      _logRequest(url, body, headers);
      http.Response response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      logResponse(url, response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedJson = _safeDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseBody: decodedJson,
        );
      } else if (response.statusCode == 401) {
        if (!isRefreshCall && !isFromLogin) {
          debugPrint(
            "⛔ [NetworkCaller] Unauthorized (401). Attempting to refresh token...",
          );
          bool isRefreshed = await AuthService.refreshToken();
          if (isRefreshed) {
            final newToken = await AuthService.getToken();
            debugPrint("📥 [NetworkCaller] Retrying original POST request...");
            return await postRequest(
              url: url,
              body: body,
              token: newToken,
              showDialog: showDialog,
              isRefreshCall: true,
            );
          } else {
            debugPrint("❌ [NetworkCaller] Refresh failed. Forcing logout.");
            AuthService.forceLogout();
          }
        }
        final decodedJson = _safeDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: _unAuthorizeMessage,
        );
      } else if (response.statusCode >= 500) {
        if (showDialog) {
          _showPremiumError('under_maintenance'.tr, 'server_maintenance_msg'.tr);
        }
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          errorMessage: "server_maintenance_msg".tr,
        );
      } else {
        final decodedJson = _safeDecode(response.body);
        String? errorMsg;
        if (decodedJson != null) {
          if (decodedJson['message'] != null &&
              decodedJson['message'] is String) {
            errorMsg = decodedJson['message'];
          } else if (decodedJson['data'] != null &&
              decodedJson['data'] is String) {
            errorMsg = decodedJson['data'];
          }
        }

        if (showDialog) {
          _showPremiumError("error".tr, errorMsg ?? "something_went_wrong".tr);
        }

        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          responseBody: decodedJson,
          errorMessage: errorMsg ?? _defaultErrorMessage,
        );
      }
    } catch (e) {
      debugPrint("⛔ [NetworkCaller] POST error: $e");
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  static Future<NetworkResponse> putRequest({
    required String url,
    Map<String, dynamic>? body,
    String? token,
    bool isRefreshCall = false,
  }) async {
    try {
      Uri uri = Uri.parse(url);
      final Map<String, String> headers = {'content-type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      _logRequest(url, body, headers);
      http.Response response = await http
          .put(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      logResponse(url, response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedJson = _safeDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseBody: decodedJson,
        );
      } else if (response.statusCode == 401) {
        if (!isRefreshCall) {
          debugPrint(
            "⛔ [NetworkCaller] Unauthorized (401). Attempting to refresh token...",
          );
          bool isRefreshed = await AuthService.refreshToken();
          if (isRefreshed) {
            final newToken = await AuthService.getToken();
            debugPrint("📥 [NetworkCaller] Retrying original PUT request...");
            return await putRequest(
              url: url,
              body: body,
              token: newToken,
              isRefreshCall: true,
            );
          } else {
            debugPrint("❌ [NetworkCaller] Refresh failed. Forcing logout.");
            AuthService.forceLogout();
          }
        }
        final decodedJson = _safeDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: _unAuthorizeMessage,
        );
      } else if (response.statusCode >= 500) {
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          errorMessage: "server_maintenance_msg".tr,
        );
      } else {
        final decodedJson = _safeDecode(response.body);
        String? errorMsg;
        if (decodedJson != null &&
            decodedJson['message'] != null &&
            decodedJson['message'] is String) {
          errorMsg = decodedJson['message'];
        }
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          responseBody: decodedJson,
          errorMessage: errorMsg ?? _defaultErrorMessage,
        );
      }
    } catch (e) {
      debugPrint("⛔ [NetworkCaller] PUT error: $e");
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  static Future<NetworkResponse> patchRequest({
    required String url,
    Map<String, dynamic>? body,
    String? token,
    bool isRefreshCall = false,
  }) async {
    try {
      Uri uri = Uri.parse(url);
      final Map<String, String> headers = {'content-type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      _logRequest(url, body, headers);
      http.Response response = await http
          .patch(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      logResponse(url, response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedJson = _safeDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseBody: decodedJson,
        );
      } else if (response.statusCode == 401) {
        if (!isRefreshCall) {
          debugPrint(
            "⛔ [NetworkCaller] Unauthorized (401). Attempting to refresh token...",
          );
          bool isRefreshed = await AuthService.refreshToken();
          if (isRefreshed) {
            final newToken = await AuthService.getToken();
            debugPrint("📥 [NetworkCaller] Retrying original PATCH request...");
            return await patchRequest(
              url: url,
              body: body,
              token: newToken,
              isRefreshCall: true,
            );
          } else {
            debugPrint("❌ [NetworkCaller] Refresh failed. Forcing logout.");
            AuthService.forceLogout();
          }
        }
        final decodedJson = _safeDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: _unAuthorizeMessage,
        );
      } else if (response.statusCode >= 500) {
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          errorMessage: "server_maintenance_msg".tr,
        );
      } else {
        final decodedJson = _safeDecode(response.body);
        String? errorMsg;
        if (decodedJson != null &&
            decodedJson['message'] != null &&
            decodedJson['message'] is String) {
          errorMsg = decodedJson['message'];
        }
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          responseBody: decodedJson,
          errorMessage: errorMsg ?? _defaultErrorMessage,
        );
      }
    } catch (e) {
      debugPrint("⛔ [NetworkCaller] PATCH error: $e");
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  static Future<NetworkResponse> deleteRequest({
    required String url,
    String? token,
    bool isRefreshCall = false,
  }) async {
    try {
      Uri uri = Uri.parse(url);
      final Map<String, String> headers = {'content-type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      _logRequest(url, null, headers);
      http.Response response = await http
          .delete(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      logResponse(url, response);
      if (response.statusCode == 200 || response.statusCode == 204) {
        final decodedJson = response.body.isNotEmpty
            ? _safeDecode(response.body)
            : null;
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseBody: decodedJson,
        );
      } else if (response.statusCode == 401) {
        if (!isRefreshCall) {
          debugPrint(
            "⛔ [NetworkCaller] Unauthorized (401). Attempting to refresh token...",
          );
          bool isRefreshed = await AuthService.refreshToken();
          if (isRefreshed) {
            final newToken = await AuthService.getToken();
            debugPrint("📥 [NetworkCaller] Retrying original DELETE request...");
            return await deleteRequest(
              url: url,
              token: newToken,
              isRefreshCall: true,
            );
          } else {
            debugPrint("❌ [NetworkCaller] Refresh failed. Forcing logout.");
            AuthService.forceLogout();
          }
        }
        final decodedJson = response.body.isNotEmpty
            ? _safeDecode(response.body)
            : null;
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          responseBody: decodedJson,
          errorMessage: _unAuthorizeMessage,
        );
      } else if (response.statusCode >= 500) {
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          errorMessage: "server_maintenance_msg".tr,
        );
      } else {
        final decodedJson = response.body.isNotEmpty
            ? _safeDecode(response.body)
            : null;
        String? errorMsg;
        if (decodedJson != null &&
            decodedJson['message'] != null &&
            decodedJson['message'] is String) {
          errorMsg = decodedJson['message'];
        }
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          responseBody: decodedJson,
          errorMessage: errorMsg ?? _defaultErrorMessage,
        );
      }
    } catch (e) {
      debugPrint("⛔ [NetworkCaller] DELETE error: $e");
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  static Future<NetworkResponse> postMultipartRequestList({
    required String url,
    required Map<String, dynamic> body,
    required String fileKey,
    required List<File> files,
    String? token,
    bool wrapInData = true,
    bool isRefreshCall = false,
  }) async {
    try {
      Uri uri = Uri.parse(url);
      final request = http.MultipartRequest('POST', uri);

      // Add Authorization header
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add body fields
      if (wrapInData) {
        request.fields['data'] = jsonEncode(body);
      } else {
        body.forEach((key, value) {
          if (value is String) {
            request.fields[key] = value;
          } else {
            request.fields[key] = jsonEncode(value);
          }
        });
      }

      // Add multiple files
      debugPrint(
        '📎 [NetworkCaller] Preparing to add ${files.length} files with key: $fileKey',
      );
      for (int i = 0; i < files.length; i++) {
        var file = files[i];
        final fileName = p.basename(file.path).toLowerCase();

        String mimeType = 'image/jpeg'; // Default
        if (fileName.endsWith('.mp4')) {
          mimeType = 'video/mp4';
        } else if (fileName.endsWith('.png')) {
          mimeType = 'image/png';
        } else if (fileName.endsWith('.gif')) {
          mimeType = 'image/gif';
        } else if (fileName.endsWith('.webp')) {
          mimeType = 'image/webp';
        }

        debugPrint('   👉 Adding file [$i]: $fileName (${mimeType})');
        request.files.add(
          await http.MultipartFile.fromPath(
            fileKey,
            file.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      debugPrint(
        '🚀🚀🚀 [MULTIPART LIST REQUEST] 🚀🚀🚀\n'
        'URL: $url \n'
        'FIELDS: ${request.fields} \n'
        'FILE KEY: $fileKey\n'
        '==================================================',
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 300),
      );
      final response = await http.Response.fromStream(streamedResponse);

      logResponse(url, response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedJson = _safeDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseBody: decodedJson,
        );
      } else if (response.statusCode == 401) {
        if (!isRefreshCall) {
          debugPrint(
            "⛔ [NetworkCaller] Unauthorized (401). Attempting to refresh token...",
          );
          bool isRefreshed = await AuthService.refreshToken();
          if (isRefreshed) {
            final newToken = await AuthService.getToken();
            debugPrint(
              "📥 [NetworkCaller] Retrying original MULTIPART LIST request...",
            );
            return await postMultipartRequestList(
              url: url,
              body: body,
              fileKey: fileKey,
              files: files,
              token: newToken,
              wrapInData: wrapInData,
              isRefreshCall: true,
            );
          } else {
            debugPrint("❌ [NetworkCaller] Refresh failed. Forcing logout.");
            AuthService.forceLogout();
          }
        }
        final decodedJson = _safeDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          responseBody: decodedJson,
          errorMessage: _unAuthorizeMessage,
        );
      } else if (response.statusCode >= 500) {
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          errorMessage: "server_maintenance_msg".tr,
        );
      } else {
        final decodedJson = _safeDecode(response.body);
        debugPrint("⛔ [NetworkCaller] Multipart List failed: $decodedJson");
        String? errorMsg;
        if (decodedJson != null &&
            decodedJson['message'] != null &&
            decodedJson['message'] is String) {
          errorMsg = decodedJson['message'];
        }
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          responseBody: decodedJson,
          errorMessage: errorMsg ?? _defaultErrorMessage,
        );
      }
    } catch (e) {
      debugPrint("⛔ [NetworkCaller] Multipart List error: $e");
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  static Future<NetworkResponse> postMultipartRequest({
    required String url,
    required Map<String, dynamic> body,
    required String fileKey,
    required File file,
    String? token,
    bool wrapInData = true,
    bool isRefreshCall = false,
  }) async {
    try {
      Uri uri = Uri.parse(url);
      final request = http.MultipartRequest('POST', uri);

      // Add Authorization header
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add body fields
      if (wrapInData) {
        request.fields['data'] = jsonEncode(body);
      } else {
        body.forEach((key, value) {
          if (value is String) {
            request.fields[key] = value;
          } else {
            request.fields[key] = jsonEncode(value);
          }
        });
      }

      // Add the file
      final fileName = p.basename(file.path).toLowerCase();
      String mimeType = 'image/jpeg'; // Default
      if (fileName.endsWith('.mp4')) {
        mimeType = 'video/mp4';
      } else if (fileName.endsWith('.png')) {
        mimeType = 'image/png';
      } else if (fileName.endsWith('.gif')) {
        mimeType = 'image/gif';
      } else if (fileName.endsWith('.webp')) {
        mimeType = 'image/webp';
      }

      final fileSizeMB = (await file.length()) / (1024 * 1024);

      request.files.add(
        await http.MultipartFile.fromPath(
          fileKey,
          file.path,
          contentType: MediaType.parse(mimeType),
        ),
      );

      debugPrint(
        '🚀🚀🚀 [MULTIPART REQUEST] 🚀🚀🚀\n'
        'URL: $url \n'
        'FIELDS: ${request.fields} \n'
        'FILE: ${file.path} (${fileSizeMB.toStringAsFixed(2)} MB) as $fileKey\n'
        '==================================================',
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 300),
      );
      final response = await http.Response.fromStream(streamedResponse);

      logResponse(url, response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedJson = _safeDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseBody: decodedJson,
        );
      } else if (response.statusCode == 401) {
        if (!isRefreshCall) {
          debugPrint(
            "⛔ [NetworkCaller] Unauthorized (401). Attempting to refresh token...",
          );
          bool isRefreshed = await AuthService.refreshToken();
          if (isRefreshed) {
            final newToken = await AuthService.getToken();
            debugPrint(
              "📥 [NetworkCaller] Retrying original MULTIPART request...",
            );
            return await postMultipartRequest(
              url: url,
              body: body,
              fileKey: fileKey,
              file: file,
              token: newToken,
              wrapInData: wrapInData,
              isRefreshCall: true,
            );
          } else {
            debugPrint("❌ [NetworkCaller] Refresh failed. Forcing logout.");
            AuthService.forceLogout();
          }
        }
        final decodedJson = _safeDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          responseBody: decodedJson,
          errorMessage: _unAuthorizeMessage,
        );
      } else if (response.statusCode >= 500) {
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          errorMessage: "server_maintenance_msg".tr,
        );
      } else {
        final decodedJson = _safeDecode(response.body);
        debugPrint("⛔ [NetworkCaller] Multipart failed: $decodedJson");
        String? errorMsg;
        if (decodedJson != null &&
            decodedJson['message'] != null &&
            decodedJson['message'] is String) {
          errorMsg = decodedJson['message'];
        }
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          responseBody: decodedJson,
          errorMessage: errorMsg ?? _defaultErrorMessage,
        );
      }
    } catch (e) {
      debugPrint("⛔ [NetworkCaller] Multipart error: $e");
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  static Future<NetworkResponse> patchMultipartRequest({
    required String url,
    required Map<String, dynamic> body,
    String? fileKey,
    File? file,
    String? token,
  }) async {
    try {
      Uri uri = Uri.parse(url);
      final request = http.MultipartRequest('PATCH', uri);

      // Add Authorization header
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add fields
      body.forEach((key, value) {
        if (value is String) {
          request.fields[key] = value;
        } else {
          request.fields[key] = jsonEncode(value);
        }
      });

      // Add the file if provided
      if (file != null && fileKey != null) {
        final fileName = p.basename(file.path);
        final mimeType = fileName.endsWith('.mp4') ? 'video/mp4' : 'image/jpeg';

        request.files.add(
          await http.MultipartFile.fromPath(
            fileKey,
            file.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      debugPrint(
        '🚀🚀🚀 [PATCH MULTIPART REQUEST] 🚀🚀🚀\n'
        'URL: $url \n'
        'FIELDS: ${request.fields} \n'
        'FILE: ${file?.path} \n'
        '==================================================',
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 300),
      );
      final response = await http.Response.fromStream(streamedResponse);

      logResponse(url, response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedJson = _safeDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseBody: decodedJson,
        );
      } else if (response.statusCode >= 500) {
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          errorMessage: "server_maintenance_msg".tr,
        );
      } else {
        final decodedJson = _safeDecode(response.body);
        debugPrint("⛔ [NetworkCaller] PATCH Multipart failed: $decodedJson");
        String? errorMsg;
        if (decodedJson != null &&
            decodedJson['message'] != null &&
            decodedJson['message'] is String) {
          errorMsg = decodedJson['message'];
        }
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          responseBody: decodedJson,
          errorMessage: errorMsg ?? _defaultErrorMessage,
        );
      }
    } catch (e) {
      debugPrint("⛔ [NetworkCaller] PATCH Multipart error: $e");
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  static void _logRequest(
    String url,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ) {
    debugPrint(
      '🚀🚀🚀 [NETWORK REQUEST] 🚀🚀🚀\n'
      'URL: $url \n'
      'BODY: ${jsonEncode(body)} \n'
      'HEADERS: $headers\n'
      '==================================================',
    );
  }

  static void logResponse(String url, http.Response response) {
    debugPrint(
      '=====================Response========================\n'
      'URL: $url \n'
      'BODY:${response.body}\n'
      'STATUS CODE:${response.statusCode}\n'
      '=================================================================',
    );
  }

  static void _showPremiumError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
      icon: Container(
        margin: const EdgeInsets.only(left: 10),
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Color(0xFFFF277F),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.error_outline_rounded,
          color: Colors.white,
          size: 18,
        ),
      ),
      margin: const EdgeInsets.all(20),
      borderRadius: 16,
      duration: const Duration(seconds: 4),
      isDismissible: true,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          spreadRadius: 2,
          offset: const Offset(0, 10),
        ),
      ],
      borderWidth: 1,
      borderColor: Colors.grey.withOpacity(0.1),
      mainButton: TextButton(
        onPressed: () => Get.back(),
        child: Text(
          "OK".tr,
          style: const TextStyle(
            color: Color(0xFFFF277F),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
