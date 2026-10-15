import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../data/caiyun_api.dart';
import '../data/city_search_api.dart';
import '../data/settings_store.dart';
import '../l10n/app_language.dart';
import '../models/settings.dart';

/// The persistence backing [settingsProvider].
///
/// Overridden at the root with the store built during startup.
final settingsStoreProvider = Provider<SettingsStore>(
  (ref) => throw UnimplementedError('settingsStoreProvider must be overridden'),
);

/// The HTTP client shared by the network clients, or null to let each client
/// own one. Overridden by tests to inject a mock.
final httpClientProvider = Provider<http.Client?>((ref) => null);

/// The user's persisted settings: the app-level source of truth for the API
/// key, language and time format.
final settingsProvider = NotifierProvider<SettingsController, Settings>(
  SettingsController.new,
);

/// Keeps the persisted [Settings] in state and writes changes through to the
/// underlying [SettingsStore].
class SettingsController extends Notifier<Settings> {
  @override
  Settings build() => ref.read(settingsStoreProvider).settings;

  /// Persists [next] and exposes it as the new state.
  Future<void> save(Settings next) async {
    await ref.read(settingsStoreProvider).save(next);
    if (!ref.mounted) return;
    state = next;
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

/// The Caiyun weather client, rebuilt whenever the API key or language changes.
/// Null until an API key has been configured.
final caiyunApiProvider = Provider<CaiyunApi?>((ref) {
  final key = ref.watch(settingsProvider.select((settings) => settings.apiKey));
  if (key == null || key.isEmpty) return null;
  final api = CaiyunApi(
    token: key,
    language: ref.watch(appLanguageProvider).caiyunLang,
    client: ref.watch(httpClientProvider),
  );
  ref.onDispose(api.dispose);
  return api;
});

/// The area-search client used by the city search feature.
final citySearchApiProvider = Provider<CitySearchApi>((ref) {
  final api = CitySearchApi(client: ref.watch(httpClientProvider));
  ref.onDispose(api.dispose);
  return api;
});
