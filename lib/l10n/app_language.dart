import 'package:flutter/widgets.dart';

/// A language the app can display, its native name, and the matching Caiyun
/// `lang` value.
///
/// Docs: https://docs.caiyunapp.com/weather-api/lang.html
class AppLanguage {
  const AppLanguage({
    required this.locale,
    required this.caiyunLang,
    required this.nativeName,
  });

  final Locale locale;

  /// Value of the Caiyun `lang` query parameter.
  final String caiyunLang;

  /// The language's name written in that language (endonym).
  final String nativeName;
}

/// Language used when nothing else matches.
const kDefaultAppLanguage = AppLanguage(
  locale: Locale('en'),
  caiyunLang: 'en_US',
  nativeName: 'English',
);

/// Registry of supported languages.
///
/// To ship a new language: add an entry here and an `app_<locale>.arb` file.
/// The ARB's locale and this [Locale] must agree, which
/// `test/app_language_test.dart` enforces.
const kAppLanguages = <AppLanguage>[
  kDefaultAppLanguage,
  AppLanguage(
    locale: Locale('zh'),
    caiyunLang: 'zh_CN',
    nativeName: '简体中文',
  ),
];

/// The [AppLanguage] for a stored language code, or null when the code is
/// unset or unknown.
AppLanguage? appLanguageForCode(String? languageCode) {
  if (languageCode == null || languageCode.isEmpty) return null;
  for (final language in kAppLanguages) {
    if (language.locale.languageCode == languageCode) return language;
  }
  return null;
}

/// Resolves a device locale to a supported [AppLanguage], matching on the full
/// language tag first and then on the language subtag alone.
AppLanguage resolveAppLanguage(Locale locale) {
  final tag = locale.toLanguageTag();
  for (final language in kAppLanguages) {
    if (language.locale.toLanguageTag() == tag) return language;
  }
  for (final language in kAppLanguages) {
    if (language.locale.languageCode == locale.languageCode) return language;
  }
  return kDefaultAppLanguage;
}
