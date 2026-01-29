import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
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
  static Future<NetworkResponse> getRequest({required String url}) async {
    try {
      Uri uri = Uri.parse(url);
      final response = await get(uri);
      if (response.statusCode == 200) {
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
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          errorMessage: decodedJson['data'] ?? _defaultErrorMessage,
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

   static Future<NetworkResponse> postRequest({required String url, Map<String, dynamic>? body,bool isFromLogin = false}) async {
    try {
      Uri uri = Uri.parse(url);
      final Map<String, String> headers = {
            'content-type': 'application/json',
          };
          _logRequest;;(url, body, headers);
      Response response = await post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      logResponse(url, response);
      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseBody: decodedJson,
        );
      }
      else if(response.statusCode == 401){
        if(isFromLogin == false) {
          // _onUnAuthorize();
        }
        final decodedJson = jsonDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage:_unAuthorizeMessage,
        );
      }
      else {
        final decodedJson = jsonDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: decodedJson['data'] ?? _defaultErrorMessage,
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


   static void _logRequest(
      String url, Map<String, String>? body, Map<String, String>? headers) {
    debugPrint('=====================Request========================\n'
        'URL: $url \n'
        'BODY:$body \n'
        'HEADERS:$headers\n'
        '==================================================');
  }

  static void logResponse(String url, Response response) {
    debugPrint('=====================Response========================\n'
        'URL: $url \n'
        'BODY:${response.body}\n'
        'STATUS CODE:${response.statusCode}\n'
        '=================================================================');
  }

  // static Future<void> _onUnAuthorize() async {
  //   await AuthController.clearData();
  //   Navigator.of(TaskManager.navigator.currentContext!)
  //       .pushNamedAndRemoveUntil(SignInScreen.name, (predicate) => false);
  // }

}
