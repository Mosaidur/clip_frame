import 'package:get/get_navigation/src/root/internacionalization.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': {
      'welcomeTitle': 'Welcome to ClipFrame.',
      'welcomeSubtitle': 'Social Media Made Simple for Your Business.',
      'getStarted': 'Lets Get Started',
      'disclaimer': 'By clicking “Lets get Started”, you acknowledge that you have read and understood, and agreed to ClipFrame Terms & Conditions and Privacy Policy.',
      'appTitle': 'Media Edit: Video & Photo (FFmpegKit)',
      'videoEdit': 'Video Edit',
      'photoEdit': 'Photo Edit',
    },
    'es': {
      'welcomeTitle': 'Bienvenido a ClipFrame.',
      'welcomeSubtitle': 'Redes sociales simplificadas para tu negocio.',
      'getStarted': 'Empecemos',
      'disclaimer': 'Al hacer clic en “Empecemos”, reconoces que has leído y entendido, y aceptas los Términos y Condiciones de ClipFrame y la Política de Privacidad.',
      'appTitle': 'Edición de medios: Video y Foto (FFmpegKit)',
      'videoEdit': 'Editar Video',
      'photoEdit': 'Editar Foto',
    },
  };
}