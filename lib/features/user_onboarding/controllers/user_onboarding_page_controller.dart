import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/api_services/user_onboarding/user_onboarding_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/onboarding_status_service.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../../../core/services/api_services/social_auth_service.dart';
import '../../../Shared/routes/routes.dart';

class UserOnboardingPageController extends GetxController {
  final PageController pageController = PageController();
  final UserOnboardingService _apiService = UserOnboardingService();

  var currentPage = 0.obs;
  var isLoading = false.obs;

  // Step 1: Business Type
  var selectedBusinessType = 'restaurant'.obs;

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
  ].obs;

  // Language code to display name mapping
  final Map<String, String> languageDisplayNames = {
    "en": "English",
    "es": "Spanish",
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
    if (isLoading.value) return;
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
        selectedBusinessType.value = 'restaurant';
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
        // Users can optionally connect platforms or just enter handles later.
        // If they connected, we can proceed. If not, they can still proceed manually.
        // But if required, we ask them to connect at least one.
        if (!isFacebookConnected.value && !isInstagramConnected.value) {
          Get.snackbar(
            "Recommendation",
            "Connecting a social platform is recommended for the best experience.",
            backgroundColor: Colors.blue.withOpacity(0.5),
            colorText: Colors.white,
          );
          // We will let them pass anyway for smoother onboarding
          return true;
        }
        return true;
      case 4: // Branding
        // Colors and logo can be optional for now as they have defaults or skip option
        return true;
      default:
        return true;
    }
  }

  Future<bool> submitOnboarding() async {
    isLoading.value = true;
    bool success = false;

    try {
      Map<String, dynamic> data = {
        "businessType": selectedBusinessType.value,
        "businessDescription": businessDescriptionController.text,
        "targetAudience": selectedAudiences,
        "preferredLanguages": [selectedLanguage.value],
        "autoTranslateCaptions": autoTranslateCaptions.value,
        "socialHandles": [
          if (isFacebookConnected.value)
            {"platform": "facebook", "accessToken": facebookAccessToken.value},
          if (isInstagramConnected.value)
            {
              "platform": "instagram",
              "accessToken": instagramAccessToken.value,
            },
          if (!isFacebookConnected.value && !isInstagramConnected.value)
            {
              "platform": selectedPlatform.value.toLowerCase().isEmpty
                  ? "none"
                  : selectedPlatform.value.toLowerCase(),
              "username": handleController.text,
              "password": passwordController.text,
            },
        ],
        "branding": {
          "primaryColor":
              "#${primaryColor.value.value.toRadixString(16).substring(2).toUpperCase()}",
          "secondaryColor":
              "#${secondaryColor.value.value.toRadixString(16).substring(2).toUpperCase()}",
        },
      };

      print("📦 Onboarding Payload: $data");

      String? token = await AuthService.getToken();
      print("🔑 Token available: ${token != null && token.isNotEmpty}");

      // Validation: Check if logo is picked if they chose to continue
      if (logoFile == null) {
        Get.snackbar(
          "Logo Required",
          "Please upload your business logo to continue.",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return false;
      }

      // API Call — use multipart with logo
      success = await _apiService.submitOnboardingWithLogo(
        data: data,
        logoFile: logoFile!,
        token: token,
      );
      print("📡 Onboarding API Success: $success");

      if (success) {
        String? email = OnboardingStatusService.getEmailFromToken(token ?? "");
        if (email != null) {
          await OnboardingStatusService.markOnboardingComplete(email);
        }
        // Navigation will be handled by the UI or here if needed
      } else {
        Get.snackbar(
          "Submission Failed",
          "There was an error saving your data. Please try again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("❌ Error in submitOnboarding: $e");
      Get.snackbar(
        "Error",
        "An unexpected error occurred: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
    return success;
  }

  // Social Auth Service
  final SocialAuthService _socialAuthService = SocialAuthService();

  // Connected status
  var isFacebookConnected = false.obs;
  var isInstagramConnected = false.obs;
  var facebookAccessToken = ''.obs;
  var instagramAccessToken = ''.obs;

  Future<void> connectFacebook() async {
    try {
      isLoading.value = true;
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: [
          'email',
          'public_profile',
          'pages_show_list',
          'pages_read_engagement',
          'pages_manage_posts',
        ],
      );

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        print("Facebook Access Token: ${accessToken.tokenString}");
        facebookAccessToken.value = accessToken.tokenString;

        bool success = await _socialAuthService.connectFacebook(
          accessToken.tokenString,
        );
        if (success) {
          isFacebookConnected.value = true;
          Get.snackbar("Success", "Connected to Facebook successfully!");
          // Advance to branding page if that's the desired flow,
          // but we'll let user click Continue manually
        } else {
          Get.snackbar(
            "Error",
            "Failed to connect to backend",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        print("❌ Facebook Login Failed: ${result.status}");
        print("❌ Facebook Login Message: ${result.message}");
        Get.snackbar(
          "Login Failed",
          result.message ?? "Unknown error",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error connecting Facebook: $e");
      Get.snackbar(
        "Error",
        "An unexpected error occurred: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> connectInstagram() async {
    try {
      isLoading.value = true;
      // Instagram Graph API via Facebook Login requires specific scopes
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: [
          'email',
          'public_profile',
          'pages_show_list',
          'instagram_basic',
          'instagram_content_publish',
          'instagram_manage_insights',
          'business_management',
        ],
      );

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        print("Instagram (via FB) Access Token: ${accessToken.tokenString}");
        instagramAccessToken.value = accessToken.tokenString;

        bool success = await _socialAuthService.connectInstagram(
          accessToken.tokenString,
        );
        if (success) {
          isInstagramConnected.value = true;
          Get.snackbar("Success", "Connected to Instagram successfully!");
        } else {
          Get.snackbar(
            "Error",
            "Failed to connect to backend",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        print("Instagram Login Status: ${result.status}");
        Get.snackbar(
          "Error",
          "Instagram login failed: ${result.message}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error connecting Instagram: $e");
      Get.snackbar(
        "Error",
        "An unexpected error occurred: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    pageController.dispose();
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
