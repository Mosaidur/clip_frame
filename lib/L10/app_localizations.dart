import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  // Add all your localized strings here
  Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'ClipFrame',
      'welcomeMessage': 'Welcome to ClipFrame!',
    },
    'es': {
      'appTitle': 'ClipFrame',
      'welcomeMessage': '¡Bienvenido a ClipFrame!',
    },
  };

  String get appTitle {
    return _localizedValues[locale.languageCode]!['appTitle']!;
  }

  String get welcomeMessage {
    return _localizedValues[locale.languageCode]!['welcomeMessage']!;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
