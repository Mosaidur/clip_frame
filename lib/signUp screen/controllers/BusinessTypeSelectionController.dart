import 'package:get/get.dart';

import 'package:flutter/material.dart';

class BusinessTypeSelectionController extends GetxController {
  var selectedBusinessTypes = <String>[].obs;
  var businessTypes = <String>[
    "Restaurants & Cafes",
    "Retail Stores & Boutiques",
    "Beauty Salons & Barbershops",
    "Gyms & Fitness Studios",
    "Local Academies (e.g., language, music, cooking)",
  ].obs;

  void selectBusinessType(String type) {
    if (selectedBusinessTypes.contains(type)) {
      // Deselect if already selected, but ensure at least one remains
      if (selectedBusinessTypes.length > 1) {
        selectedBusinessTypes.remove(type);
      } else {
        Get.snackbar(
          'Minimum Selection',
          'At least one business type must be selected.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      // Allow selection only if less than 3 are selected
      if (selectedBusinessTypes.length < 3) {
        selectedBusinessTypes.add(type);
      } else {
        Get.snackbar(
          'Maximum Selection',
          'You can select up to 3 business types.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  void addBusinessType(String type) {
    if (!businessTypes.contains(type) && type.isNotEmpty) {
      businessTypes.add(type);
    }
  }
}