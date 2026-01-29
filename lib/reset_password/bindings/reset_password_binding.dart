import 'package:get/get.dart';
import '../controllers/reset_password_page_controller.dart';

class ResetPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResetPasswordPageController>(() => ResetPasswordPageController());
  }
}
