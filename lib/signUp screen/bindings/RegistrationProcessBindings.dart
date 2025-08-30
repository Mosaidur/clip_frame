import 'package:get/get.dart';
import '../../../splashScreen/controllers/language_controller.dart';
import '../controllers/BusinessTypeSelectionController.dart';
import '../controllers/RegistrationProcessController.dart';

class RegistrationProcessBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LanguageController>(() => LanguageController(), fenix: true);
    Get.lazyPut<BusinessTypeSelectionController>(() => BusinessTypeSelectionController());
    Get.lazyPut<RegistrationProcessController>(() => RegistrationProcessController());
  }
}