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
    try {
      // Set a global timeout for the entire check process to prevent hanging on black screen
      await Future.any([
        _performAuthCheck(),
        Future.delayed(const Duration(seconds: 10)).then((_) {
          print("⏰ SplashScreen: Auth check timed out after 10s. Forcing navigation.");
          throw TimeoutException("Auth check timed out");
        }),
      ]);
    } catch (e) {
      print("❌ SplashScreen: Error or timeout during auth check: $e");
      // Fallback: Safe navigation to Welcome if anything fails
      if (mounted) {
        Get.offAllNamed(AppRoutes.WELCOME);
      }
    }
  }

  Future<void> _performAuthCheck() async {
    // Show splash screen for at least 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // Check if user has a valid token
    String? token;
    try {
      token = await AuthService.getToken();
    } catch (e) {
      print("⚠️ SplashScreen: Error getting token: $e");
    }

    if (token != null && token.isNotEmpty) {
      print("🔄 SplashScreen: Token found, attempting to refresh...");
      try {
        bool refreshSuccess = await AuthService.refreshToken();
        if (refreshSuccess) {
          token = await AuthService.getToken(); // Get the new token
        } else {
          print("⚠️ SplashScreen: Token refresh failed.");
        }
      } catch (e) {
        print("⚠️ SplashScreen: Token refresh error: $e");
      }
    }

    bool hasCompletedOnboarding = false;
    if (token != null && token.isNotEmpty) {
      // Decode email from token to check user-specific onboarding status
      try {
        String? email = OnboardingStatusService.getEmailFromToken(token);
        if (email != null) {
          hasCompletedOnboarding =
              await OnboardingStatusService.isOnboardingComplete(email);

          // If local status is false, try to verify with backend
          if (!hasCompletedOnboarding) {
            print("🔍 Local onboarding status false, checking backend...");
            final response = await NetworkCaller.getRequest(
              url: Urls.getUserProfileUrl,
              token: token,
            );
            if (response.isSuccess && response.responseBody != null) {
              UserResponse userResponse = UserResponse.fromJson(
                response.responseBody!,
              );
              if (userResponse.success && userResponse.data != null) {
                final userData = userResponse.data;
                bool backendSaysOnboarded =
                    OnboardingStatusService.isProfileOnboarded(userData);
                if (backendSaysOnboarded) {
                  await OnboardingStatusService.markOnboardingComplete(email);
                  hasCompletedOnboarding = true;
                }
              }
            }
          }
        }
      } catch (e) {
        print("⚠️ SplashScreen: Onboarding check error: $e");
      }
    }

    if (!mounted) return;

    if (token != null && token.isNotEmpty && hasCompletedOnboarding) {
      print("🔑 Token found and onboarding complete, navigating to HOME");
      Get.offAllNamed(AppRoutes.HOME);
    } else {
      if (token != null && !hasCompletedOnboarding) {
        print("⚠️ Token exists but onboarding incomplete. Forcing WELCOME.");
      } else {
        print("⚠️ No valid session, navigating to WELCOME");
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
