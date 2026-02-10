import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/api_services/user_onboarding/user_onboarding_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/onboarding_status_service.dart';
import '../../../Shared/routes/routes.dart';

class UserOnboardingPageController extends GetxController {
  final PageController pageController = PageController();
  final UserOnboardingService _apiService = UserOnboardingService();

  var currentPage = 0.obs;
  var isLoading = false.obs;

  // Step 1: Business Type
  var selectedBusinessType = ''.obs;
  final businessTypeSearchController = TextEditingController();
  final customBusinessTypeController = TextEditingController();

  final List<String> predefinedBusinessTypes = [
    "Restaurants & Cafes",
    "Retail Stores & Boutiques",
    "Beauty Salons & Barbershops",
    "Gyms & Fitness Studios",
    "Local Academies (e.g., language, music, cooking)",
  ];

  var filteredBusinessTypes = <String>[].obs;
  var customBusinessTypes = <String>[].obs;

  // Step 2: Description
  final businessDescriptionController = TextEditingController();
  var descriptionCharCount = 0.obs;

  final List<String> descriptionSuggestions = [
    "Lorem Ipsum is simply dummy text",
    "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
    "Lorem Ipsum has been the industry's standard dummy text.",
  ];

  void updateDescriptionCount() {
    descriptionCharCount.value = businessDescriptionController.text.length;
  }

  // Step 3: Audience & Language
  var selectedAudiences = <String>[].obs;
  final List<String> audienceOptions = ["local", "tourist", "online", "all"];

  var selectedLanguage = 'en'.obs; // Language code for backend
  var languageOptions = [
    "en", // English
    "es", // Spanish
    "bn", // Bengali
    "hi", // Hindi
    "fr", // French
  ].obs;

  // Language code to display name mapping
  final Map<String, String> languageDisplayNames = {
    "en": "English",
    "es": "Spanish",
    "bn": "Bengali",
    "hi": "Hindi",
    "fr": "French",
  };

  // Helper method to get display name from code
  String getLanguageDisplayName(String code) {
    return languageDisplayNames[code] ?? code;
  }

  final languageController =
      TextEditingController(); // For custom? Keeping it if needed

  void addCustomLanguage(String language) {
    if (!languageOptions.contains(language)) {
      languageOptions.add(language);
      selectedLanguage.value = language;
    }
  }

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
  final passwordController = TextEditingController();

  // Step 6: Branding
  var primaryColor = const Color(0xFF000000).obs;
  var secondaryColor = const Color(0xFF000000).obs;
  var logoPath = ''.obs;
  File? logoFile;

  Future<void> pickLogo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        logoPath.value = image.path;
        logoFile = File(image.path);
      }
    } catch (e) {
      print("Error picking logo: $e");
    }
  }

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

  // Business Type Methods
  void filterBusinessTypes(String query) {
    if (query.isEmpty) {
      filteredBusinessTypes.clear();
    } else {
      final allTypes = [...predefinedBusinessTypes, ...customBusinessTypes];
      filteredBusinessTypes.value = allTypes
          .where((type) => type.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void selectBusinessType(String type) {
    selectedBusinessType.value = type;
    customBusinessTypeController.clear();
  }

  void addCustomBusinessType(String type) {
    if (!customBusinessTypes.contains(type) &&
        !predefinedBusinessTypes.contains(type)) {
      customBusinessTypes.add(type);
      selectedBusinessType.value = type;
    }
  }

  bool validateCurrentStep() {
    switch (currentPage.value) {
      case 0: // Business Type
        if (selectedBusinessType.value.isEmpty &&
            customBusinessTypeController.text.isEmpty) {
          Get.snackbar(
            "Required",
            "Please select or enter a business type.",
            backgroundColor: Colors.red.withOpacity(0.5),
            colorText: Colors.white,
          );
          return false;
        }
        return true;
      case 1: // Description
        if (businessDescriptionController.text.trim().isEmpty) {
          Get.snackbar(
            "Required",
            "Please enter a business description.",
            backgroundColor: Colors.red.withOpacity(0.5),
            colorText: Colors.white,
          );
          return false;
        }
        return true;
      case 2: // Audience & Language
        if (selectedAudiences.isEmpty) {
          Get.snackbar(
            "Required",
            "Please select at least one target audience.",
            backgroundColor: Colors.red.withOpacity(0.5),
            colorText: Colors.white,
          );
          return false;
        }
        return true;
      case 3: // Platform Selection & Connect Form
        if (selectedPlatform.value.isEmpty) {
          Get.snackbar(
            "Required",
            "Please select a social media platform.",
            backgroundColor: Colors.red.withOpacity(0.5),
            colorText: Colors.white,
          );
          return false;
        }
        if (handleController.text.trim().isEmpty) {
          Get.snackbar(
            "Required",
            "Please enter your ${selectedPlatform.value} username.",
            backgroundColor: Colors.red.withOpacity(0.5),
            colorText: Colors.white,
          );
          return false;
        }
        return true;
      case 4: // Branding
        // Colors and logo can be optional for now as they have defaults or skip option
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
      "preferredLanguages": [
        selectedLanguage.value,
      ], // Must be a list for the API
      "autoTranslateCaptions": autoTranslateCaptions.value,
      "socialHandles": [
        {
          "platform": selectedPlatform.value.toLowerCase(),
          "username": handleController.text,
          "password": passwordController.text, // Added password
        },
      ],
      "branding": {
        "primaryColor":
            "#${primaryColor.value.value.toRadixString(16).substring(2).toUpperCase()}",
        "secondaryColor":
            "#${secondaryColor.value.value.toRadixString(16).substring(2).toUpperCase()}",
        "logo": logoPath
            .value, // This might need to be uploaded separately or as base64
      },
    };

    print("📦 Onboarding Payload: $data");

    String? token = await AuthService.getToken();
    print("🔑 Token available: ${token != null && token.isNotEmpty}");

    // API Call
    bool success = await _apiService.submitOnboardingData(data);
    print("📡 Onboarding API Success: $success");

    isLoading.value = false;

    if (success) {
      // Mark onboarding as complete for this specific user
      String? email = OnboardingStatusService.getEmailFromToken(token ?? "");
      if (email != null) {
        await OnboardingStatusService.markOnboardingComplete(email);
      }

      // Navigate to Login to force user to log in again/verify credentials
      Get.offAllNamed(AppRoutes.login);
    } else {
      Get.snackbar(
        "Error",
        "Failed to submit onboarding data. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    businessTypeSearchController.dispose();
    customBusinessTypeController.dispose();
    businessDescriptionController.dispose();
    languageController.dispose();
    handleController.dispose();
    passwordController.dispose();
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
