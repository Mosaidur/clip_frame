import 'package:get/get.dart';
import 'package:clip_frame/photo_edit.dart';
import 'package:clip_frame/video_edit.dart';

import '../../splashScreen/bindings/welcome_binding.dart';
import '../../splashScreen/presenatation/screen/onboardingScreen.dart';

class AppRoutes {
  static const WELCOME = '/welcome';
  static const HOME = '/home';
  static const PHOTO_EDIT = '/photo_edit';
  static const VIDEO_EDIT = '/video_edit';

  static final pages = [
    GetPage(
      name: WELCOME,
      page: () => WelcomeScreen(),
      binding: WelcomeBinding(),
    ),
    // GetPage(name: HOME, page: () => HomePage()),
    GetPage(name: PHOTO_EDIT, page: () => PhotoEditorPage()),
    GetPage(name: VIDEO_EDIT, page: () => VideoEditorPage()),
  ];
}
