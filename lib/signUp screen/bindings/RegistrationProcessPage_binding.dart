import 'package:get/get.dart';
import '../../splashScreen/controllers/language_controller.dart';
import '../controllers/SignUpControllerPage.dart'; // Adjust path as needed

class RegistrationProcessPageBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LanguageController>(() => LanguageController(), fenix: true);
    // Get.lazyPut<SignUpController>(() => SignUpController(), fenix: true);
  }
}