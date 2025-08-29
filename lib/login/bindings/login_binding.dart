import 'package:get/get.dart';
import '../../splashScreen/controllers/language_controller.dart';
import '../controllers/loginControllerPage.dart'; // Adjust path as needed

class logInBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LanguageController>(() => LanguageController(), fenix: true);
    Get.lazyPut<LoginController>(() => LoginController(), fenix: true);
  }
}