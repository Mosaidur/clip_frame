import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
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
  }) async {
    try {
      Uri uri = Uri.parse(url);
      final Map<String, String> headers = {'content-type': 'application/json'};
      // Add Authorization header if token is provided
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      _logRequest(url, null, headers);

      final response = await get(
        uri,
        headers: headers,
      ).timeout(const Duration(seconds: 30));
      logResponse(url, response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedJson = jsonDecode(response.body);
        return NetworkResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          responseBody: decodedJson,
        );
      } else if (response.statusCode == 401) {
        final decodedJson = jsonDecode(response.body);
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          responseBody: decodedJson,
          errorMessage: _unAuthorizeMessage,
        );
      } else {
        final decodedJson = jsonDecode(response.body);
        // Try to extract error message from 'message' field first, then 'data' if it's a String
        String? errorMsg;
        if (decodedJson['message'] != null &&
            decodedJson['message'] is String) {
          errorMsg = decodedJson['message'];
        } else if (decodedJson['data'] != null &&
            decodedJson['data'] is String) {
          errorMsg = decodedJson['data'];
        }
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          responseBody: decodedJson,
          errorMessage: errorMsg ?? _defaultErrorMessage,
        );
      }
    } catch (e) {
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }

  static Future<NetworkResponse> postRequest({
    required String url,
    Map<String, dynamic>? body,
    bool isFromLogin = false,
    String? token,
  }) async {
    try {
      Uri uri = Uri.parse(url);
      final Map<String, String> headers = {'content-type': 'application/json'};
      // Add Authorization header if token is provided
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        debugPrint(
          "🚀 DEBUG: Token added to headers: ${token.substring(0, 5)}...",
        );
      } else {
        debugPrint("🚀 DEBUG: No token provided to NetworkCaller.");
      }

      _logRequest(url, body, headers);
      Response response = await post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      logResponse(url, response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedJson = jsonDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseBody: decodedJson,
        );
      } else if (response.statusCode == 401) {
        if (isFromLogin == false) {
          // _onUnAuthorize();
        }
        final decodedJson = jsonDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: _unAuthorizeMessage,
        );
      } else {
        final decodedJson = jsonDecode(response.body);
        // Try to extract error message from 'message' field first, then 'data' if it's a String
        String? errorMsg;
        if (decodedJson['message'] != null &&
            decodedJson['message'] is String) {
          errorMsg = decodedJson['message'];
        } else if (decodedJson['data'] != null &&
            decodedJson['data'] is String) {
          errorMsg = decodedJson['data'];
        }
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          responseBody: decodedJson,
          errorMessage: errorMsg ?? _defaultErrorMessage,
        );
      }
    } catch (e) {
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
  }) async {
    try {
      Uri uri = Uri.parse(url);
      final Map<String, String> headers = {'content-type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      _logRequest(url, body, headers);
      Response response = await put(
        uri,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      logResponse(url, response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedJson = jsonDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseBody: decodedJson,
        );
      } else {
        final decodedJson = jsonDecode(response.body);
        String? errorMsg;
        if (decodedJson['message'] != null &&
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
  }) async {
    try {
      Uri uri = Uri.parse(url);
      final Map<String, String> headers = {'content-type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      _logRequest(url, body, headers);
      Response response = await patch(
        uri,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      logResponse(url, response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedJson = jsonDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseBody: decodedJson,
        );
      } else {
        final decodedJson = jsonDecode(response.body);
        String? errorMsg;
        if (decodedJson['message'] != null &&
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
  }) async {
    try {
      Uri uri = Uri.parse(url);
      final Map<String, String> headers = {'content-type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      _logRequest(url, null, headers);
      Response response = await delete(
        uri,
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      logResponse(url, response);
      if (response.statusCode == 200 || response.statusCode == 204) {
        final decodedJson = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : null;
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseBody: decodedJson,
        );
      } else {
        final decodedJson = response.body.isNotEmpty
            ? jsonDecode(response.body)
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
  }) async {
    try {
      Uri uri = Uri.parse(url);
      final request = MultipartRequest('POST', uri);

      // Add Authorization header
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Wrap the whole JSON body into a single 'data' field if the backend expects it
      // Based on the "Data is required" error, this is highly likely.
      request.fields['data'] = jsonEncode(body);

      // Add the file
      final fileName = p.basename(file.path);
      final mimeType = fileName.endsWith('.mp4') ? 'video/mp4' : 'image/jpeg';
      final fileSizeMB = (await file.length()) / (1024 * 1024);

      request.files.add(
        await MultipartFile.fromPath(
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
      final response = await Response.fromStream(streamedResponse);

      logResponse(url, response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedJson = jsonDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseBody: decodedJson,
        );
      } else {
        final decodedJson = jsonDecode(response.body);
        debugPrint("⛔ [NetworkCaller] Multipart failed: $decodedJson");
        String? errorMsg;
        if (decodedJson['message'] != null &&
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

  static void logResponse(String url, Response response) {
    debugPrint(
      '=====================Response========================\n'
      'URL: $url \n'
      'BODY:${response.body}\n'
      'STATUS CODE:${response.statusCode}\n'
      '=================================================================',
    );
  }

  // static Future<void> _onUnAuthorize() async {
  //   await AuthController.clearData();
  //   Navigator.of(TaskManager.navigator.currentContext!)
  //       .pushNamedAndRemoveUntil(SignInScreen.name, (predicate) => false);
  // }
}
