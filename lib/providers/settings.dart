import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_language.dart';
import '../models/city.dart';
import '../models/settings.dart';
import 'dependencies.dart';

/// The user's persisted settings: the app-level source of truth for the API
/// key, language, saved cities and the selected city.
final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(
  SettingsNotifier.new,
);

/// Holds the persisted [Settings] and writes changes through to the
/// [SettingsStore]. The weather and search providers derive from it.
class SettingsNotifier extends Notifier<Settings> {
  @override
  Settings build() => ref.read(settingsStoreProvider).settings;

  /// Persists [next] and exposes it as the new state.
  Future<void> save(Settings next) => _write(next);

  /// Selects [city] as the active one.
  Future<void> selectCity(CityLocation city) =>
      _write(state.copyWith(selectedCityId: city.id));

  /// Adds [city] to the saved list, unless it is already there.
  Future<void> addCity(CityLocation city) {
    if (_cities.any((c) => c.id == city.id)) return Future.value();
    return _write(state.copyWith(cities: [..._cities, city]));
  }

  /// Removes [city], keeping at least one city and moving the selection to the
  /// first remaining city when the removed one was selected.
  Future<void> removeCity(CityLocation city) {
    final cities = _cities;
    if (cities.length <= 1) return Future.value();
    final remaining = cities.where((c) => c.id != city.id).toList();
    final selectedCityId = state.selectedCityId == city.id
        ? remaining.first.id
        : state.selectedCityId;
    return _write(
      state.copyWith(cities: remaining, selectedCityId: selectedCityId),
    );
  }

  /// The saved cities, seeding the default catalog on first mutation so the
  /// catalog becomes the persisted list once the user edits it.
  List<CityLocation> get _cities =>
      state.cities.isNotEmpty ? state.cities : cityCatalog;

  /// Updates the state optimistically, then persists it.
  Future<void> _write(Settings next) async {
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
