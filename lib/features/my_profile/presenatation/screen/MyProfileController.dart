import 'package:clip_frame/core/model/user_model.dart';
import 'package:clip_frame/core/services/api_services/network_caller.dart';
import 'package:clip_frame/core/services/api_services/urls.dart';
import 'package:clip_frame/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/AboutMeWidget.dart';
import '../widgets/MyCreationsWidget.dart';

class MyProfileController extends GetxController {
  var selectedTab = 0.obs; // 0 = About Me, 1 = My Creations
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  Rx<UserModel?> userModel = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    getUserProfile();
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
    final response = await NetworkCaller.getRequest(url: Urls.getUserProfileUrl, token: token);
    print('🟣 NetworkCaller returned: ${response.statusCode}, success: ${response.isSuccess}');

    if (response.isSuccess) {
      if (response.responseBody != null) {
        try {
          print('🟣 Parsing UserResponse...');
          UserResponse userResponse = UserResponse.fromJson(response.responseBody!);
          print('🟣 Parsed success: ${userResponse.success}');
          if (userResponse.success && userResponse.data != null) {
            userModel.value = userResponse.data;
            print('🟣 User model updated: ${userModel.value?.name}');
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
}

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyProfileController());
    final width = MediaQuery.of(context).size.width;
    // final height = MediaQuery.of(context).size.height; // Unused

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      child: SafeArea(
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _roundIcon(Icons.settings, () {}),
                      const Text(
                        "Profile",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      _roundIcon(Icons.edit, () {
                         // TODO: Navigate to Edit Profile
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
                            Text(controller.errorMessage.value, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 8),
                            ElevatedButton(onPressed: controller.getUserProfile, child: const Text("Retry"))
                          ],
                        ),
                      ),
                    );
                  }

                  final user = controller.userModel.value;

                  return Column(
                    children: [
                      Container(
                        height: 130,
                        width: 130,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: ClipOval(
                          child: Image.network(
                            "https://example.com/profile.jpg", // Placeholder or from user.image if available
                            height: 125,
                            width: 125,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                "assets/images/profile_image.png",
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.name ?? "User",
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        user?.email ?? "",
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
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
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF277F), Color(0xFF007CFE)],
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => controller.selectedTab.value = 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: controller.selectedTab.value == 0
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(60),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "About me",
                                        style: TextStyle(
                                          color: controller.selectedTab.value == 0
                                              ? Colors.black
                                              : Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => controller.selectedTab.value = 1,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: controller.selectedTab.value == 1
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(60),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "My Creations",
                                        style: TextStyle(
                                          color: controller.selectedTab.value == 1
                                              ? Colors.black
                                              : Colors.white,
                                          fontWeight: FontWeight.w600,
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
