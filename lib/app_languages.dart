import 'dart:ui';

/// A supported UI language with its name written in that language.
class AppLanguage {
  const AppLanguage(this.code, this.nativeName);
  final String code;
  final String nativeName;
}

/// The 15 supported languages, ordered roughly by number of speakers.
/// Keep in sync with tool/gen_l10n.py.
const appLanguages = [
  AppLanguage('en', 'English'),
  AppLanguage('zh', '中文（简体）'),
  AppLanguage('hi', 'हिन्दी'),
  AppLanguage('es', 'Español'),
  AppLanguage('ar', 'العربية'),
  AppLanguage('fr', 'Français'),
  AppLanguage('bn', 'বাংলা'),
  AppLanguage('pt', 'Português'),
  AppLanguage('ru', 'Русский'),
  AppLanguage('ur', 'اردو'),
  AppLanguage('id', 'Bahasa Indonesia'),
  AppLanguage('de', 'Deutsch'),
  AppLanguage('ja', '日本語'),
  AppLanguage('tr', 'Türkçe'),
  AppLanguage('ko', '한국어'),
];

/// Picks the first device language the app supports, otherwise English.
Locale resolveDeviceLocale(List<Locale>? deviceLocales) {
  for (final locale in deviceLocales ?? const <Locale>[]) {
    if (appLanguages.any((l) => l.code == locale.languageCode)) {
      return Locale(locale.languageCode);
    }
  }
  return const Locale('en');
}
