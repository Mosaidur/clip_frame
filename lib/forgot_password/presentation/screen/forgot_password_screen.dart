import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Shared/widgets/language_toggle_button.dart';
import '../../../splashScreen/controllers/language_controller.dart';
import '../../controllers/forgot_password_page_controller.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final ForgotPasswordPageController controller = Get.put(ForgotPasswordPageController());
  
  Shader linearGradient = const LinearGradient(
    colors: <Color>[Color(0xFF4983F6), Color(0xFFC175F5), Color(0xFFFBACB7)],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  final LanguageController langController = Get.put(LanguageController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEBC794), Color(0xFFB38FFC)],
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black12,
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                      // Language Toggle
                      Obx(() {
                        return LanguageToggleButton(
                          currentLanguage: langController.locale.value.languageCode == 'es' ? 'Es' : 'En',
                          onLanguageChanged: (lang) {
                            langController.changeLanguage(
                              lang == 'Es' ? const Locale('es', 'ES') : const Locale('en', 'US'),
                            );
                          },
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Logo
                  Image.asset("assets/images/ClipFramelogo.png", height: 40),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Forgot Password',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()..shader = linearGradient,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Enter your email address and we will send you a code to reset your password',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 30),
                        // Email Field
                        TextField(
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Submit Button
                        Obx(
                          () => ElevatedButton(
                            onPressed: controller.isLoading.value ? null : controller.submitEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text('Send Reset Code'),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
