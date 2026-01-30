import 'package:get/get.dart';
import '../controllers/user_onboarding_page_controller.dart';

class UserOnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserOnboardingPageController>(
      () => UserOnboardingPageController(),
    );
  }
}
