import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api_services/user_onboarding/user_onboarding_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../Shared/routes/routes.dart';

class UserOnboardingPageController extends GetxController {
  final PageController pageController = PageController();
  final UserOnboardingService _apiService = UserOnboardingService();

  var currentPage = 0.obs;
  var isLoading = false.obs;

  // Step 1: Business Type
  var selectedBusinessType = ''.obs;
  final customBusinessTypeController = TextEditingController();
  final List<String> businessTypes = [
    "Restaurants & Cafes",
    "Retail Stores & Boutiques",
    "Beauty Salons & Barbershops",
    "Gyms & Fitness Studios",
    "Local Academies (e.g., language, music, cooking)"
  ];

  // Step 2: Description
  final businessDescriptionController = TextEditingController();

  // Step 3: Audience & Language
  var selectedAudiences = <String>[].obs;
  final List<String> audienceOptions = [
    "Local Audience",
    "Tourist Audience",
    "Online only Audience",
    "All types"
  ];

  var selectedLanguage = 'English'.obs; // Single selection for language
  final List<String> languageOptions = [
    "English",
    "Spanish",
    "German",
    "Chinese"
  ];
  final languageController = TextEditingController(); // For custom? Keeping it if needed
  var autoTranslateCaptions = false.obs;

  // Step 4: Social Platforms (Single Select)
  var selectedPlatform = ''.obs;
  final List<Map<String, dynamic>> socialPlatformOptions = [
    {'name': 'Facebook', 'key': 'facebook', 'icon': Icons.facebook},
    {'name': 'Instagram', 'key': 'instagram', 'icon': Icons.camera_alt}, 
    {'name': 'TikTok', 'key': 'tiktok', 'icon': Icons.music_note}, 
  ];

  // Step 5: Handles
  final handleController = TextEditingController();


  void nextPage() {
    if (!validateCurrentStep()) return;

    if (currentPage.value < 4) {
      print("👉 Moving to page ${currentPage.value + 1}");
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      currentPage.value++;
    } else {
      print("🚀 Submitting Onboarding Data...");
      submitOnboarding();
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      currentPage.value--;
    }
  }

  bool validateCurrentStep() {
    switch (currentPage.value) {
      case 0: // Business Type
        if (selectedBusinessType.value.isEmpty && customBusinessTypeController.text.isEmpty) {
          Get.snackbar("Required", "Please select or enter a business type.", 
            backgroundColor: Colors.red.withOpacity(0.5), colorText: Colors.white);
          return false;
        }
        return true;
      case 1: // Description
        if (businessDescriptionController.text.trim().isEmpty) {
           Get.snackbar("Required", "Please enter a business description.",
            backgroundColor: Colors.red.withOpacity(0.5), colorText: Colors.white);
          return false;
        }
        return true;
      case 2: // Audience & Language
        if (selectedAudiences.isEmpty) {
           Get.snackbar("Required", "Please select at least one target audience.",
            backgroundColor: Colors.red.withOpacity(0.5), colorText: Colors.white);
          return false;
        }
        // Language validation (optional since it has default)
        return true;
      case 3: // Platform
        if (selectedPlatform.value.isEmpty) {
           Get.snackbar("Required", "Please select a social media platform.",
            backgroundColor: Colors.red.withOpacity(0.5), colorText: Colors.white);
          return false;
        }
        return true;
      case 4: // Handle
        if (handleController.text.trim().isEmpty) {
           Get.snackbar("Required", "Please enter your ${selectedPlatform.value} username.",
            backgroundColor: Colors.red.withOpacity(0.5), colorText: Colors.white);
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  Future<void> submitOnboarding() async {
    isLoading.value = true;

    String finalBusinessType = selectedBusinessType.value.isNotEmpty 
        ? selectedBusinessType.value 
        : customBusinessTypeController.text;

    Map<String, dynamic> data = {
      "businessType": finalBusinessType,
      "businessDescription": businessDescriptionController.text,
      "targetAudience": selectedAudiences,
      "preferredLanguages": selectedLanguage.value, // Sending as string "English" etc.
      "autoTranslateCaptions": autoTranslateCaptions.value,
      "socialHandles": [
        {
          "platform": selectedPlatform.value.toLowerCase(),
          "username": handleController.text,
        }
      ]
    };
    
    print("📦 Onboarding Payload: $data");
    
    String? token = await AuthService.getToken();
    print("🔑 Token available: ${token != null && token.isNotEmpty}");

    // API Call
    bool success = await _apiService.submitOnboardingData(data);
    print("📡 Onboarding API Success: $success");

    isLoading.value = false;

    if (success) {
      Get.offAllNamed(AppRoutes.HOME); // Navigate to Home
    } else {
      Get.snackbar("Error", "Failed to submit onboarding data. Please try again.",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    customBusinessTypeController.dispose();
    businessDescriptionController.dispose();
    languageController.dispose();
    handleController.dispose();
    super.onClose();
  }
  
  // Logic for toggles
  void toggleAudience(String audience) {
    if (selectedAudiences.contains(audience)) {
      selectedAudiences.remove(audience);
    } else {
      selectedAudiences.add(audience);
    }
  }

  void selectLanguage(String language) {
    selectedLanguage.value = language;
  }
  
  void selectPlatform(String platform) {
    selectedPlatform.value = platform;
  }
  
  String get handleLabel {
    if (selectedPlatform.value.isEmpty) return "Enter username";
    return "Enter your ${selectedPlatform.value} username"; 
  }
}
