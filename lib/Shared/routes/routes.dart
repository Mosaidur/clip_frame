import 'package:get/get.dart';
import 'package:clip_frame/photo_edit.dart';

import 'package:clip_frame/video_edit.dart';
import '../../features/video_editor/presentation/native_editor_page.dart';

import '../../features/HomeScreen.dart';
import '../../login/bindings/login_binding.dart';
import '../../login/presenatation/screen/login_page.dart';
import '../../signUp screen/bindings/RegistrationProcessBindings.dart';
import '../../signUp screen/bindings/AudienceAndLanguageBinding.dart';
import '../../signUp screen/bindings/SignUp_binding.dart';
import '../../signUp screen/presenatation/screen/registrationProcessPage.dart';
import '../../signUp screen/presenatation/screen/signup_page.dart';
import '../../email_verification/bindings/email_verification_binding.dart';
import '../../email_verification/presentation/screen/email_verification_screen.dart';
import '../../forgot_password/bindings/forgot_password_binding.dart';
import '../../forgot_password/presentation/screen/forgot_password_screen.dart';
import '../../reset_password/bindings/reset_password_binding.dart';
import '../../reset_password/presentation/screen/reset_password_screen.dart';
import '../../splashScreen/bindings/welcome_binding.dart';
import '../../splashScreen/presenatation/screen/onboardingScreen.dart';

class AppRoutes {
  static const WELCOME = '/welcome';
  static const HOME = '/home';
  static const PHOTO_EDIT = '/photo_edit';
  static const VIDEO_EDIT = '/video_edit';
  static const String login = '/login';
  static const String signUp = '/signUp';
  static const String emailVerification = '/emailVerification';
  static const String forgotPassword = '/forgotPassword';
  static const String resetPassword = '/resetPassword';
  static const String RegistrationProcess = '/RegistrationProcess';

  static final pages = [
    GetPage(
      name: WELCOME,
      page: () => WelcomeScreen(),
      binding: WelcomeBinding(),
    ),
    GetPage(
      name: login,
      page: () => LoginScreen(),
      binding: logInBindings(),
    ),
    GetPage(
      name: signUp,
      page: () => signUpScreen(),
      binding: SignUpBindings(),
    ),
    GetPage(
      name: emailVerification,
      page: () => EmailVerificationScreen(),
      binding: EmailVerificationBinding(),
    ),
    GetPage(
      name: forgotPassword,
      page: () => ForgotPasswordScreen(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: resetPassword,
      page: () => ResetPasswordScreen(),
      binding: ResetPasswordBinding(),
    ),
    GetPage(
      name: RegistrationProcess,
      page: () => RegistrationProcessPage(),
      binding: RegistrationProcessBinding(),
    ),

GetPage(name: HOME, page: () => HomePage()),




    // GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: PHOTO_EDIT, page: () => PhotoEditorPage()),
    GetPage(name: VIDEO_EDIT, page: () => NativeEditorPage()),
  ];
}
