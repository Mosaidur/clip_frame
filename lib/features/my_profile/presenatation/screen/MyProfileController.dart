import 'package:clip_frame/core/model/user_model.dart';
import 'package:clip_frame/core/services/api_services/authentication/logout_controller.dart'
    as api;
import 'package:clip_frame/core/services/api_services/network_caller.dart';
import 'package:clip_frame/core/services/api_services/urls.dart';
import 'package:clip_frame/core/services/auth_service.dart';
import 'package:clip_frame/shared/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/AboutMeWidget.dart';
import '../widgets/MyCreationsWidget.dart';
import 'package:clip_frame/core/model/my_content_model.dart';
import 'package:clip_frame/core/services/api_services/my_content_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:clip_frame/features/my_profile/presenatation/screen/EditProfileScreen.dart';
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
    {'name': 'TikTok', 'key': 'tiktok'},
  ];
  var tempSelectedPlatforms = <String>[].obs;
  var selectedPlatformIndex =
      0.obs; // To track focused platform in selection UI

  // My Creations
  var myCreations = <ContentItem>[].obs;
  var isCreationsLoading = false.obs;
  var creationsErrorMessage = ''.obs;

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
    } catch (e) {
      creationsErrorMessage.value =
          "An error occurred while fetching creations";
      print('🔵 fetchMyCreations exception: $e');
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
  }) async {
    isUpdating.value = true;
    Get.snackbar(
      'Profile Update',
      'Starting update process...',
      backgroundColor: Colors.blue.withOpacity(0.7),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      isDismissible: true,
      showProgressIndicator: true,
    );
    try {
      String? token = await AuthService.getToken();
      Map<String, dynamic> body = {
        'name': name,
        'phone': phone,
        if (businessCategory != null) 'businessCategory': businessCategory,
        if (businessName != null) 'businessName': businessName,
      };

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
        Get.snackbar(
          'Success ✅',
          'Profile and Image updated successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
        Get.back(); // Close edit screen immediately
        await getUserProfile(); // Refresh data
      } else {
        Get.closeAllSnackbars();
        String msg = response.errorMessage ?? 'Update failed';
        if (msg.contains("delete file to S3")) {
          msg =
              "Critical Server Error: Failed to remove old S3 file. Please apply the try-catch fix on your Node.js backend (user.service.ts) to allow profile updates.";
        }
        Get.snackbar(
          'Update Failed ❌',
          msg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 10),
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Update failed: $e');
    } finally {
      isUpdating.value = false;
    }
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
        );
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

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyProfileController>();
    final width = MediaQuery.of(context).size.width;
    // final height = MediaQuery.of(context).size.height; // Unused

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.getUserProfile();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Top Row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _roundIcon(Icons.settings, () {}),
                      Text(
                        "Profile",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      _roundIcon(Icons.edit, () {
                        Get.to(() => const EditProfileScreen());
                      }),
                    ],
                  ),
                ),

                // Profile Section
                Obx(() {
                  if (controller.isLoading.value) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (controller.errorMessage.value.isNotEmpty) {
                    return Container(
                      height: 200,
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              controller.errorMessage.value,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: controller.getUserProfile,
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final user = controller.userModel.value;

                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await controller.pickImage();
                          if (controller.selectedImage.value != null) {
                            // Show loading or confirm update
                            await controller.updateProfile(
                              name: user?.name ?? "",
                              phone: user?.phone ?? "",
                            );
                          }
                        },
                        child: Stack(
                          children: [
                            Container(
                              height: 140,
                              width: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFFF277F),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFF277F,
                                    ).withOpacity(0.2),
                                    blurRadius: 15,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: ClipOval(
                                    child:
                                        controller.selectedImage.value != null
                                        ? Image.file(
                                            controller.selectedImage.value!,
                                            fit: BoxFit.cover,
                                          )
                                        : (user?.image != null &&
                                              user!.image!.isNotEmpty)
                                        ? Image.network(
                                            user.image!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) => Image.asset(
                                                  "assets/images/profile_image.png",
                                                  fit: BoxFit.cover,
                                                ),
                                          )
                                        : Image.asset(
                                            "assets/images/profile_image.png",
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 5,
                              right: 5,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF007CFE),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.name ?? "User",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        user?.email ?? "",
                        style: GoogleFonts.poppins(
                          color: Colors.black54,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 20),

                // Tabs + Content
                Container(
                  width: width,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // Tabs
                      Obx(() {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(60),
                            color: Colors.black.withOpacity(0.05),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => controller.selectedTab.value = 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient:
                                          controller.selectedTab.value == 0
                                          ? const LinearGradient(
                                              colors: [
                                                Color(0xFFFF277F),
                                                Color(0xFF007CFE),
                                              ],
                                            )
                                          : null,
                                      borderRadius: BorderRadius.circular(60),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "About me",
                                        style: GoogleFonts.poppins(
                                          color:
                                              controller.selectedTab.value == 0
                                              ? Colors.white
                                              : Colors.black54,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    controller.selectedTab.value = 1;
                                    controller.fetchMyCreations();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient:
                                          controller.selectedTab.value == 1
                                          ? const LinearGradient(
                                              colors: [
                                                Color(0xFFFF277F),
                                                Color(0xFF007CFE),
                                              ],
                                            )
                                          : null,
                                      borderRadius: BorderRadius.circular(60),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "My Creations",
                                        style: GoogleFonts.poppins(
                                          color:
                                              controller.selectedTab.value == 1
                                              ? Colors.white
                                              : Colors.black54,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 20),

                      // Tab Content
                      Obx(() {
                        return controller.selectedTab.value == 0
                            ? const AboutMeWidget()
                            : const MyCreationsWidget();
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roundIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.1),
        ),
        child: Icon(icon, color: Colors.black),
      ),
    );
  }
}
