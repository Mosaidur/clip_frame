import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Shared/routes/routes.dart';
import '../../../Shared/widgets/language_toggle_button.dart';
import '../../../splashScreen/controllers/language_controller.dart';
import '../../controllers/loginControllerPage.dart';

class LoginScreen extends GetView<LoginController> {
  // Use 'controller' provided by GetView

  final LanguageController langController = Get.put(
    LanguageController(),
    permanent: true,
  );

  @override
  Widget build(BuildContext context) {
    // Ensure controller is found (binding should provide it)
    // If binding didn't run (unlikely with named routes), this might fail, so we can keep a fallback Get.put if needed,
    // but better to trust the binding.
    // Actually, to be safe against direct widget instantiation without binding:
    // val c = Get.put(LoginController()); // But this causes the disposal issue if not careful.
    // Let's stick to GetView which uses Get.find().
    // If the binding is not set up correctly in GetPage, this will error.
    // AppRoutes defines binding: logInBindings(), so we are safe.

    Shader linearGradient = const LinearGradient(
      colors: <Color>[Color(0xFF4983F6), Color(0xFFC175F5), Color(0xFFFBACB7)],
    ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'getStartedLoginScreen'.tr,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()..shader = linearGradient,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'disclaimerLoginScreen'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        // Google Button
                        ElevatedButton.icon(
                          onPressed: controller.googleLogin,
                          icon: Image.asset(
                            "assets/images/google.png",
                            height: 20,
                          ),
                          label: Text('signInGoogle'.tr),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.grey),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Facebook Button
                        ElevatedButton.icon(
                          onPressed: controller.facebookLogin,
                          icon: Image.asset(
                            "assets/images/facebook.png",
                            height: 20,
                          ),
                          label: Text('signInFacebook'.tr),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.grey),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text('or'.tr),
                        const SizedBox(height: 15),
                        // Email Field
                        TextField(
                          controller: controller.emailController,
                          decoration: InputDecoration(
                            labelText: 'email'.tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        // Password Field with toggle
                        Obx(
                          () => TextField(
                            controller: controller.passwordController,
                            obscureText: controller.obscurePassword.value,
                            decoration: InputDecoration(
                              labelText: 'password'.tr,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.obscurePassword.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: controller.togglePasswordVisibility,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Remember me + Forgot Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Obx(
                              () => Row(
                                children: [
                                  Checkbox(
                                    value: controller.rememberMe.value,
                                    onChanged: (val) {
                                      controller.toggleRememberMe(val ?? false);
                                      print(controller.rememberMe.value);
                                    },
                                  ),
                                  Text('rememberMe'.tr),
                                ],
                              ),
                            ),
                            Flexible(
                              child: TextButton(
                                onPressed: () {
                                  Get.toNamed(AppRoutes.forgotPassword);
                                },
                                child: Text('forgotPassword'.tr),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Login Button
                        Obx(
                          () => ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.login,
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
                                : Text('login'.tr),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Sign Up
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('dontHaveAccount'.tr),
                            GestureDetector(
                              onTap: () {
                                // Get.snackbar('signUp'.tr, 'goToSignupPage'.tr);
                                Get.toNamed(AppRoutes.signUp);
                              },
                              child: Text(
                                'signUp'.tr,
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
