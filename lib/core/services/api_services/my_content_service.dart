import 'package:clip_frame/core/services/api_services/network_caller.dart';
import 'package:clip_frame/core/services/api_services/urls.dart';
import 'package:clip_frame/core/services/auth_service.dart';

class MyContentService {
  static Future<NetworkResponse> getMyContents() async {
    final String? token = await AuthService.getToken();
    final NetworkResponse response = await NetworkCaller.getRequest(
      url: Urls.getMyContentsUrl,
      token: token,
    );
    return response;
  }
}
