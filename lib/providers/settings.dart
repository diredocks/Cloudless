import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_language.dart';
import '../models/settings.dart';
import 'dependencies.dart';

/// The user's persisted settings: the app-level source of truth for the API
/// key, language and display options.
final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(
  SettingsNotifier.new,
);

/// Holds the persisted [Settings] and writes changes through to the
/// [SettingsStore].
class SettingsNotifier extends Notifier<Settings> {
  @override
  Settings build() => ref.read(settingsStoreProvider).settings;

  /// Persists [next] and exposes it as the new state.
  Future<void> save(Settings next) async {
    state = next;
    await ref.read(settingsStoreProvider).save(next);
  }
}

/// The language actually in effect: the explicit override, or the best match
/// for the system locale.
///
/// Invalidate this when the system locale changes so the Caiyun client is
/// rebuilt with the new `lang` value.
final appLanguageProvider = Provider<AppLanguage>((ref) {
  final override = appLanguageForCode(
    ref.watch(settingsProvider.select((settings) => settings.languageCode)),
  );
  if (override != null) return override;
  return resolveAppLanguage(WidgetsBinding.instance.platformDispatcher.locale);
});

/// The [SettingsDraft] edited on the settings screen. Seeded from the persisted
/// settings each time the screen mounts and discarded when it closes.
final settingsFormProvider =
    NotifierProvider.autoDispose<SettingsFormNotifier, SettingsDraft>(
      SettingsFormNotifier.new,
    );

class SettingsFormNotifier extends Notifier<SettingsDraft> {
  @override
  SettingsDraft build() => SettingsDraft.from(ref.watch(settingsProvider));

  /// Sets the API key being edited.
  void setApiKey(String key) => state = state.withApiKey(key);

  /// Sets the preferred language, or null to follow the system.
  void setLanguage(String? code) => state = state.withLanguage(code);

  /// Sets whether hourly times use a 24-hour clock.
  void setUse24Hour(bool value) => state = state.withUse24Hour(value);
}
