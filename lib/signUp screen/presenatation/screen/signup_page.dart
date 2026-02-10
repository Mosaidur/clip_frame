import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Shared/routes/routes.dart';
import '../../../Shared/widgets/customText.dart';
import '../../../Shared/widgets/language_toggle_button.dart';
import '../../../splashScreen/controllers/language_controller.dart';
import '../../controllers/SignUpControllerPage.dart';

class signUpScreen extends GetView<SignUpController> {
  // Use 'controller' (from GetView) instead of 'signUpcontroller' if possible,
  // or just assign it using Get.find() if you want to keep variable name.
  // Actually, let's keep the name 'signUpcontroller' for minimal refactor,
  // but initialize it with Get.find() or just use 'controller' alias.
  // Ideally, valid GetX syntax:
  SignUpController get signUpcontroller => controller;

  final LanguageController langController = Get.put(
    LanguageController(),
    permanent: true,
  );

  @override
  Widget build(BuildContext context) {
    Shader linearGradient = const LinearGradient(
      colors: <Color>[Color(0xFF4983F6), Color(0xFFC175F5), Color(0xFFFBACB7)],
    ).createShader(const Rect.fromLTWH(0.0, 0.0, 50.0, 20.0));

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
                  // header of the auth feature
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
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Language Toggle
                      Obx(() {
                        return LanguageToggleButton(
                          currentLanguage:
                              langController.locale.value.languageCode == 'es'
                              ? 'Es'
                              : 'En',
                          onLanguageChanged: (lang) {
                            langController.changeLanguage(
                              lang == 'Es'
                                  ? const Locale('es', 'ES')
                                  : const Locale('en', 'US'),
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
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Sign Up',
                            // textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()..shader = linearGradient,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Create an account to log in to explore our app',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                      bottom: 4,
                                    ),
                                    child: Text(
                                      'First Name',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  CustomTextField(
                                    controller:
                                        signUpcontroller.firstNameController,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16), // spacing between fields
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                      bottom: 4,
                                    ),
                                    child: Text(
                                      'Last Name',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  CustomTextField(
                                    controller:
                                        signUpcontroller.lastNameController,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        // Email Field
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 20),
                          child: Text(
                            'Email',
                            textAlign: TextAlign.start,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        CustomTextField(
                          controller: signUpcontroller.emailController,
                        ),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 20),
                          child: Text(
                            'Phone',
                            textAlign: TextAlign.start,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        CustomTextField(
                          controller: signUpcontroller.phoneController,
                        ),
                        const SizedBox(height: 15),
                        // Password Field with toggle
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 20),
                          child: Text(
                            'Password',
                            textAlign: TextAlign.start,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        Obx(
                          () => TextField(
                            controller: signUpcontroller.passwordController,
                            obscureText: signUpcontroller.obscurePassword.value,
                            decoration: InputDecoration(
                              // labelText: 'password'.tr,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  signUpcontroller.obscurePassword.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed:
                                    signUpcontroller.togglePasswordVisibility,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 20),
                          child: Text(
                            'Confirm Password',
                            textAlign: TextAlign.start,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),

                        Obx(
                          () => TextField(
                            controller:
                                signUpcontroller.confirmPasswordController,
                            obscureText: signUpcontroller.obscurePassword.value,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  signUpcontroller.obscurePassword.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: signUpcontroller
                                    .toggleConfirmPasswordVisibility,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                        // SignUp Button
                        Obx(
                          () => ElevatedButton(
                            onPressed: signUpcontroller.isLoading.value
                                ? null
                                : signUpcontroller.signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: signUpcontroller.isLoading.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text('Register'),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Sign Up
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Already have an account? '),
                            GestureDetector(
                              onTap: () {
                                Get.snackbar('signUp'.tr, 'goToSignupPage'.tr);
                                Get.toNamed(AppRoutes.login);
                              },
                              child: Text(
                                'Log In',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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
