import 'package:cloudless_app/l10n/app_language.dart';
import 'package:cloudless_app/l10n/app_localizations.dart';
import 'package:cloudless_app/l10n/weather_l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  test('every registered language has a generated ARB locale', () {
    for (final language in kAppLanguages) {
      expect(
        AppLocalizations.supportedLocales,
        contains(language.locale),
        reason: 'missing ARB file for ${language.locale}',
      );
    }
  });

  test('every supported locale is registered', () {
    for (final locale in AppLocalizations.supportedLocales) {
      expect(
        kAppLanguages.any((l) => l.locale.languageCode == locale.languageCode),
        isTrue,
        reason: 'missing registry entry for $locale',
      );
    }
  });

  test('resolves the Caiyun lang for a device locale', () {
    expect(resolveAppLanguage(const Locale('zh')).caiyunLang, 'zh_CN');
    expect(resolveAppLanguage(const Locale('zh', 'CN')).caiyunLang, 'zh_CN');
    expect(resolveAppLanguage(const Locale('en', 'US')).caiyunLang, 'en_US');
    expect(resolveAppLanguage(const Locale('en', 'GB')).caiyunLang, 'en_US');
    expect(resolveAppLanguage(const Locale('fr')).caiyunLang, 'en_US');
  });

  test('looks up an override by language code', () {
    expect(appLanguageForCode('zh')?.caiyunLang, 'zh_CN');
    expect(appLanguageForCode('en')?.nativeName, 'English');
    expect(appLanguageForCode(null), isNull);
    expect(appLanguageForCode(''), isNull);
    expect(appLanguageForCode('fr'), isNull);
  });

  test('weather labels resolve for every language', () async {
    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = await AppLocalizations.delegate.load(locale);
      expect(l10n.skyconLabel('CLEAR_DAY'), isNotEmpty);
      expect(l10n.windLabel(10), isNotEmpty);
      expect(l10n.weekdayName('2026-10-14T00:00+02:00'), isNotEmpty);
      expect(l10n.cityName(malagaCity), isNotEmpty);
    }
  });
}
