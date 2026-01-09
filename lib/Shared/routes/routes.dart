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
import '../../splashScreen/bindings/welcome_binding.dart';
import '../../splashScreen/presenatation/screen/onboardingScreen.dart';

class AppRoutes {
  static const WELCOME = '/welcome';
  static const HOME = '/home';
  static const PHOTO_EDIT = '/photo_edit';
  static const VIDEO_EDIT = '/video_edit';
  static const String login = '/login';
  static const String signUp = '/signUp';
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
