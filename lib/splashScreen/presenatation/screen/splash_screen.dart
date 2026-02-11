import 'package:clip_frame/core/model/user_model.dart';
import 'package:clip_frame/core/services/api_services/network_caller.dart';
import 'package:clip_frame/core/services/api_services/urls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../../core/services/auth_service.dart';
import '../../../core/services/onboarding_status_service.dart';
import '../../../Shared/routes/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Show splash screen for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // Check if user has a valid token
    String? token = await AuthService.getToken();

    bool hasCompletedOnboarding = false;
    if (token != null && token.isNotEmpty) {
      // Decode email from token to check user-specific onboarding status
      String? email = OnboardingStatusService.getEmailFromToken(token);
      if (email != null) {
        hasCompletedOnboarding =
            await OnboardingStatusService.isOnboardingComplete(email);

        // If local status is false, try to verify with backend
        if (!hasCompletedOnboarding) {
          try {
            print("🔍 Local onboarding status false, checking backend...");
            final response = await NetworkCaller.getRequest(
              url: Urls.getUserProfileUrl,
              token: token,
            );
            if (response.isSuccess && response.responseBody != null) {
              UserResponse userResponse = UserResponse.fromJson(
                response.responseBody!,
              );
              // CRITICAL FIX: Only sync if explicitly successful AND data is present
              if (userResponse.success && userResponse.data != null) {
                final userData = userResponse.data;
                print(
                  "👤 User Profile from backend: ${userData is Map ? userData : 'Object'}",
                );

                // Check strictly if businessType is valid content (not just present)
                bool backendSaysOnboarded =
                    OnboardingStatusService.isProfileOnboarded(userData);
                print(
                  "🧐 Backend analysis - Is Onboarded: $backendSaysOnboarded",
                );

                if (backendSaysOnboarded) {
                  await OnboardingStatusService.markOnboardingComplete(email);
                  hasCompletedOnboarding = true;
                }
              }
            }
          } catch (e) {
            print("Error syncing onboarding status in Splash: $e");
          }
        }
      }
    }

    if (token != null && token.isNotEmpty && hasCompletedOnboarding) {
      // User has token AND completed onboarding, navigate to home
      print("🔑 Token found and onboarding complete, navigating to HOME");
      Get.offAllNamed(AppRoutes.HOME);
    } else {
      // In all other cases (no token, or incomplete onboarding), go to welcome screen
      // This ensures that onboarding MUST happen immediately after a login session
      if (token != null && !hasCompletedOnboarding) {
        print(
          "⚠️ Token exists but onboarding incomplete for user. Forcing fresh start from WELCOME.",
        );
      } else {
        print("⚠️ No token found, navigating to WELCOME");
      }
      Get.offAllNamed(AppRoutes.WELCOME);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEBC794), Color(0xFFB38FFC)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset('assets/images/ClipFramelogo.png', height: 80),
              const SizedBox(height: 20),
              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
