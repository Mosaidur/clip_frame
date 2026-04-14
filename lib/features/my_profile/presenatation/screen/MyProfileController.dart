import 'package:clip_frame/core/model/user_model.dart';
import 'package:clip_frame/splashScreen/controllers/language_controller.dart';
import 'package:clip_frame/core/services/api_services/authentication/logout_controller.dart'
    as api;
import 'package:clip_frame/core/services/api_services/network_caller.dart';
import 'package:clip_frame/core/services/api_services/urls.dart';
import 'package:clip_frame/core/services/auth_service.dart';
import 'package:clip_frame/shared/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:clip_frame/core/model/my_content_model.dart';
import 'package:clip_frame/core/services/api_services/my_content_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:clip_frame/core/services/api_services/social_auth_service.dart';

class MyProfileController extends GetxController {
  var selectedTab = 0.obs; // 0 = About Me, 1 = My Creations
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Update Profile
  var isUpdating = false.obs;
  Rx<File?> selectedImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  // Logout API Controller
  final api.LogoutController _logoutController = Get.put(
    api.LogoutController(),
  );

  // Social Auth Service
  final SocialAuthService _socialAuthService = SocialAuthService();

  Rx<UserModel?> userModel = Rx<UserModel?>(null);

  // Platform Selection
  final List<Map<String, dynamic>> socialPlatformOptions = [
    {'name': 'Facebook', 'key': 'facebook'},
    {'name': 'Instagram', 'key': 'instagram'},
  ];
  var tempSelectedPlatforms = <String>[].obs;
  var selectedPlatformIndex =
      0.obs; // To track focused platform in selection UI

  // My Creations
  var myCreations = <ContentItem>[].obs;
  var isCreationsLoading = false.obs;
  var creationsErrorMessage = ''.obs;

  // Language and Timezone Selection
  final List<String> availableLanguages = ["English", "Hindi", "Spanish"];

  final List<String> availableTimezones = [
    "UTC (GMT+00:00)",
    "Europe/London (GMT+01:00)",
    "Europe/Paris (GMT+02:00)",
    "Europe/Berlin (GMT+02:00)",
    "America/New_York (GMT-04:00)",
    "America/Chicago (GMT-05:00)",
    "America/Denver (GMT-06:00)",
    "America/Los_Angeles (GMT-07:00)",
    "Asia/Dhaka (GMT+06:00)",
    "Asia/Kolkata (GMT+05:30)",
    "Asia/Dubai (GMT+04:00)",
    "Asia/Tokyo (GMT+09:00)",
    "Asia/Singapore (GMT+08:00)",
    "Australia/Sydney (GMT+10:00)",
  ];

  // Selection UI state
  var selectedLanguage = "English".obs; // Change to single selection
  var selectedTimezone = "UTC (GMT+00:00)".obs;

  // Helper to map code to display name
  String _getLangName(String code) {
    if (code == 'en') return 'English';
    if (code == 'hi') return 'Hindi';
    if (code == 'es') return 'Spanish';
    return code;
  }

  // Helper to map display name to code
  String _getLangCode(String name) {
    if (name == 'English') return 'en';
    if (name == 'Hindi') return 'hi';
    if (name == 'Spanish') return 'es';
    return name.toLowerCase();
  }

  void setLanguage(String lang) {
    selectedLanguage.value = lang;
  }

  void setTimezone(String tz) {
    selectedTimezone.value = tz;
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUserProfile();
      fetchMyCreations();
    });
  }

  Future<void> getUserProfile() async {
    print('🟣 getUserProfile called');
    isLoading.value = true;
    errorMessage.value = '';

    final String? token = await AuthService.getToken();
    print('🟣 Token: $token');

    if (token == null) {
      print('🟣 Token is null!');
    }

    print('🟣 Calling NetworkCaller...');
    final response = await NetworkCaller.getRequest(
      url: Urls.getUserProfileUrl,
      token: token,
    );
    print(
      '🟣 NetworkCaller returned: ${response.statusCode}, success: ${response.isSuccess}',
    );

    if (response.isSuccess) {
      if (response.responseBody != null) {
        try {
          print('🟣 Parsing UserResponse...');
          UserResponse userResponse = UserResponse.fromJson(
            response.responseBody!,
          );
          print('🟣 Parsed success: ${userResponse.success}');
          if (userResponse.success && userResponse.data != null) {
            userModel.value = userResponse.data;
            // Sync observables with model
            if (userModel.value!.preferredLanguages.isNotEmpty) {
              String langFromApi = userModel.value!.preferredLanguages.first;
              print(
                "🟣 MyProfileController: API returned preferred language: $langFromApi",
              );
              selectedLanguage.value = _getLangName(langFromApi);
            }

            // Handle timezone mapping (find match in list or use raw)
            String rawTz = userModel.value!.timezone;
            selectedTimezone.value = availableTimezones.firstWhere(
              (tz) => tz.contains(rawTz),
              orElse: () => rawTz,
            );

            // Sync App Locale with current preferred language
            final langController = Get.find<LanguageController>();
            print(
              "🟣 MyProfileController: Syncing app language to: ${selectedLanguage.value}",
            );
            langController.changeLanguage(selectedLanguage.value);

            print('🟣 User model updated: ${userModel.value?.name}');
            print('🟣 User Image URL: ${userModel.value?.image}');
          } else {
            errorMessage.value = userResponse.message;
            print('🟣 Error from API: ${userResponse.message}');
          }
        } catch (e) {
          errorMessage.value = "Failed to parse profile data";
          print('🟣 Parse exception: $e');
        }
      }
    } else {
      errorMessage.value = response.errorMessage ?? 'Failed to fetch profile';
      print('🟣 Network error: ${errorMessage.value}');
    }

    isLoading.value = false;
    print('🟣 isLoading set to false');
  }

  Future<void> fetchMyCreations() async {
    print('🔵 fetchMyCreations called');
    isCreationsLoading.value = true;
    creationsErrorMessage.value = '';

    try {
      final response = await MyContentService.getMyContents();
      print(
        '🔵 NetworkCaller returned for creations: ${response.statusCode}, success: ${response.isSuccess}',
      );
      print('🔵 Response body: ${response.responseBody}');

      if (response.isSuccess && response.responseBody != null) {
        final MyContentsResponse contentResponse = MyContentsResponse.fromJson(
          response.responseBody!,
        );
        if (contentResponse.success) {
          myCreations.assignAll(contentResponse.data.data);
          print('🔵 My creations updated: ${myCreations.length} items');
          if (myCreations.isEmpty) {
            print('🔵 Warning: API returned success but empty list');
          }
        } else {
          creationsErrorMessage.value = contentResponse.message;
          print('🔵 API error message: ${contentResponse.message}');
        }
      } else {
        creationsErrorMessage.value =
            response.errorMessage ?? 'Failed to fetch creations';
        print('🔵 Network error: ${creationsErrorMessage.value}');
      }
    } catch (e, stackTrace) {
      creationsErrorMessage.value =
          "An error occurred while fetching creations: $e";
      print('🔵 fetchMyCreations exception: $e');
      print('🔵 Stacktrace: $stackTrace');
    } finally {
      isCreationsLoading.value = false;
      print(
        '🔵 fetchMyCreations finished. isCreationsLoading: ${isCreationsLoading.value}',
      );
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    String? businessCategory,
    String? businessName,
    String? businessDescription,
    String? businessType,
    String? timezone,
    String? preferredLanguage, // Changed to single string
  }) async {
    isUpdating.value = true;
    Get.snackbar(
      'Profile Update'.tr,
      'Starting update process...'.tr,
      backgroundColor: Colors.blue.withOpacity(0.7),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      isDismissible: true,
      showProgressIndicator: true,
    );
    try {
      String? token = await AuthService.getToken();

      // Clean up timezone to just use the key (e.g. "Asia/Dhaka")
      String cleanTz = timezone ?? "UTC";
      if (cleanTz.contains(" (")) {
        cleanTz = cleanTz.split(" (").first;
      }

      Map<String, dynamic> body = {
        'name': name,
        'phone': phone,
        if (businessCategory != null) 'businessCategory': businessCategory,
        if (businessName != null) 'businessName': businessName,
        if (businessDescription != null)
          'description':
              businessDescription, // Changed from businessDescription to description
        if (businessType != null) 'businessType': businessType,
        'timezone': cleanTz,
        if (preferredLanguage != null)
          'preferredLanguages': [_getLangCode(preferredLanguage)],
      };

      print("📤 MyProfileController: Sending Update Request with body: $body");

      NetworkResponse response;
      if (selectedImage.value != null) {
        response =
            await NetworkCaller.patchMultipartRequest(
              url: Urls.updateUserProfileUrl,
              body: body,
              file: selectedImage.value!,
              fileKey: 'image', // As per API documentation
              token: token,
            ).timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                return NetworkResponse(
                  isSuccess: false,
                  statusCode: 408,
                  errorMessage: 'Request timed out',
                );
              },
            );
      } else {
        response =
            await NetworkCaller.patchRequest(
              url: Urls.updateUserProfileUrl,
              body: body,
              token: token,
            ).timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                return NetworkResponse(
                  isSuccess: false,
                  statusCode: 408,
                  errorMessage: 'Request timed out',
                );
              },
            );
      }

      debugPrint("📡 [UpdateProfile] Full Response: ${response.responseBody}");

      if (response.isSuccess) {
        Get.closeAllSnackbars();

        // Update App Locale if preferred language changed
        if (preferredLanguage != null) {
          print(
            "🔄 MyProfileController: Preferred language updated, changing app language to: $preferredLanguage",
          );
          final langController = Get.find<LanguageController>();
          langController.changeLanguage(preferredLanguage);
        }

        Get.snackbar(
          'Success ✅'.tr,
          'Profile and Image updated successfully!'.tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle, color: Colors.white),
          snackPosition: SnackPosition.TOP,
        );

        // Use a slight delay to ensure the user sees the success message before backing
        Future.delayed(const Duration(seconds: 1), () {
          if (Get.isOverlaysOpen) {
            Get.back(); // Close snackbar
          }
          Get.back(); // Back to profile screen
        });

        await getUserProfile(); // Refresh data
      } else {
        Get.closeAllSnackbars();
        String msg = response.errorMessage ?? 'Update failed'.tr;
        if (msg.contains("delete file to S3")) {
          msg =
              "Critical Server Error: Failed to remove old S3 file. Please apply the try-catch fix on your Node.js backend (user.service.ts) to allow profile updates.";
        }
        Get.snackbar(
          'Update Failed ❌'.tr,
          msg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 10),
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } catch (e) {
      Get.snackbar('Error'.tr, 'Update failed: $e'.tr);
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    isUpdating.value = true;
    try {
      String? token = await AuthService.getToken();
      Map<String, dynamic> body = {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      };

      final response = await NetworkCaller.postRequest(
        url: Urls.changePasswordUrl,
        body: body,
        token: token,
      );

      if (response.isSuccess) {
        Get.back(); // Close dialog
        Get.snackbar(
          'Success ✅'.tr,
          'Password changed successfully!'.tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error ❌'.tr,
          response.errorMessage ?? 'Failed to change password'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error'.tr, 'Something went wrong'.tr);
    } finally {
      isUpdating.value = false;
    }
  }

  void showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Change Password".tr,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Current Password".tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (v) => v == null || v.isEmpty ? "Required".tr : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "New Password".tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (v) => v == null || v.length < 6
                    ? "Minimum 6 characters".tr
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Confirm New Password".tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (v) => v != newPasswordController.text
                    ? "Passwords do not match".tr
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text("Cancel".tr)),
          Obx(
            () => ElevatedButton(
              onPressed: isUpdating.value
                  ? null
                  : () {
                      if (formKey.currentState!.validate()) {
                        changePassword(
                          oldPassword: oldPasswordController.text,
                          newPassword: newPasswordController.text,
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB38FFC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isUpdating.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      "Update".tr,
                      style: const TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> updatePlatforms(List<String> platforms) async {
    isUpdating.value = true;
    try {
      String? token = await AuthService.getToken();
      Map<String, dynamic> body = {'platforms': platforms};

      final response = await NetworkCaller.patchRequest(
        url: Urls.updateUserProfileUrl,
        body: body,
        token: token,
      );

      if (response.isSuccess) {
        Get.snackbar(
          'Success ✅',
          'Platforms updated successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        // Auto back after successful update
        Future.delayed(const Duration(seconds: 1), () {
          Get.back();
        });
        await getUserProfile();
      } else {
        Get.snackbar(
          'Update Failed ❌',
          response.errorMessage ?? 'Failed to update platforms',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Update failed: $e');
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> disconnectPlatform(String platform) async {
    if (userModel.value == null) return;

    isUpdating.value = true;
    try {
      List<String> currentPlatforms = List.from(userModel.value!.platforms);
      currentPlatforms.remove(platform);

      await updatePlatforms(currentPlatforms);

      // If it was facebook/instagram, also logout from SDK for cleanliness
      if (platform == 'facebook' || platform == 'instagram') {
        await FacebookAuth.instance.logOut();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to disconnect: $e');
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;

      // Verify token presence before hitting API
      String? token = await AuthService.getToken();
      print(
        "🔑 MyProfileController: Token before logout: ${token != null ? 'Present' : 'NULL'}",
      );

      // Hit logout API
      bool apiSuccess = await _logoutController.logout();

      if (apiSuccess) {
        await AuthService.clearData();
        Get.offAllNamed(AppRoutes.WELCOME);
        Get.snackbar(
          'Success',
          'Logged out successfully',
          backgroundColor: Colors.green.withOpacity(0.7),
          colorText: Colors.white,
        );
      } else {
        // Even if API fails, we usually clear data for UX, but we show a warning
        await AuthService.clearData();
        Get.offAllNamed(AppRoutes.WELCOME);
        Get.snackbar(
          'Logout',
          'Logged out locally, but backend session might remain active.',
          backgroundColor: Colors.orange.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Logout failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // --- Dynamic Social Connection Methods ---

  Future<void> connectFacebook({bool switchAccount = false}) async {
    try {
      isUpdating.value = true;

      if (switchAccount) {
        print("🔄 Switching Facebook Account: Logging out current session...");
        await FacebookAuth.instance.logOut();
      }

      final LoginResult result = await FacebookAuth.instance.login(
        permissions: [
          'email',
          'public_profile',
          'pages_show_list',
          'pages_read_engagement',
          'pages_manage_posts',
        ],
        loginBehavior: switchAccount
            ? LoginBehavior.webOnly
            : LoginBehavior.dialogOnly,
      );

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        print("Facebook Access Token: ${accessToken.tokenString}");

        bool success = await _socialAuthService.connectFacebook(
          accessToken.tokenString,
        );
        if (success) {
          Get.snackbar(
            "Success ✅",
            "Connected to Facebook successfully!",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          await getUserProfile(); // Refresh UI
        } else {
          Get.snackbar(
            "Account Link Error ❌",
            "Failed to link Facebook to your account.",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else if (result.status != LoginStatus.cancelled) {
        Get.snackbar(
          "Login Failed",
          result.message ?? "Facebook login failed.",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred: $e");
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> connectInstagram({bool switchAccount = false}) async {
    try {
      isUpdating.value = true;

      if (switchAccount) {
        print("🔄 Switching Instagram Account: Logging out current session...");
        await FacebookAuth.instance.logOut();
      }

      // Instagram Graph API via Facebook Login
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
        loginBehavior: switchAccount
            ? LoginBehavior.webOnly
            : LoginBehavior.dialogOnly,
      );

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        print("Instagram (via FB) Access Token: ${accessToken.tokenString}");

        bool success = await _socialAuthService.connectInstagram(
          accessToken.tokenString,
        );
        if (success) {
          Get.snackbar(
            "Success ✅",
            "Connected to Instagram successfully!",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          await getUserProfile(); // Refresh UI
        } else {
          Get.snackbar(
            "Account Link Error ❌",
            "Failed to link Instagram to your account.",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else if (result.status != LoginStatus.cancelled) {
        Get.snackbar(
          "Login Failed",
          result.message ?? "Instagram login failed.",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred: $e");
    } finally {
      isUpdating.value = false;
    }
  }
}
