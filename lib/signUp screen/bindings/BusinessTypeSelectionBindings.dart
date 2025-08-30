import 'package:get/get.dart';
import '../controllers/BusinessTypeSelectionController.dart';

class BusinessTypeSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BusinessTypeSelectionController>(() => BusinessTypeSelectionController());
  }
}