import 'package:clip_frame/core/services/api_services/network_caller.dart';
import 'package:clip_frame/core/services/api_services/urls.dart';
import 'package:clip_frame/core/services/auth_service.dart';

class PremiumPlanService {
  Future<NetworkResponse> getPremiumPlans() async {
    final String? token = await AuthService.getToken();
    final NetworkResponse response = await NetworkCaller.getRequest(
      url: Urls.getPlaneUrl,
      token: token,
    );
    return response;
  }
}
