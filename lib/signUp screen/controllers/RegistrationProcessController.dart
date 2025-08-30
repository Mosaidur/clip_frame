import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../splashScreen/controllers/language_controller.dart';
import '../presenatation/widgets/BusinessDescriptionPage.dart';
import '../presenatation/widgets/BusinessTypeSelection.dart';
import '../presenatation/widgets/SocailMedia.dart';
import '../presenatation/widgets/audianceAndLanguage.dart';
import 'BusinessTypeSelectionController.dart';

class RegistrationProcessController extends GetxController {
  final LanguageController languageController = Get.find<LanguageController>();
  final BusinessTypeSelectionController businessTypeController = Get.find<BusinessTypeSelectionController>();
  final PageController pageController = PageController();
  var currentPage = 0.obs;

  final List<Widget> pages = [
    BusinessTypeSelectionPage(),
    // PlaceholderPage(),
    BusinessDescriptionPage(),
    AudienceAndLanguagePage(),
    ScoicalMediaPage()
  ];

  @override
  void onInit() {
    super.onInit();
    pageController.addListener(() {
      currentPage.value = pageController.page?.round() ?? 0;
    });
  }

  void nextPage() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void previousPage() {
    pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}