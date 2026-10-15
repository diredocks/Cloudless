import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/cities.dart';
import '../models/weather.dart';
import '../models/weather_tab.dart';
import 'api.dart';
import 'settings.dart';

/// The user's cities, falling back to the default catalog before any are saved.
final appCitiesProvider = Provider<List<CityLocation>>((ref) {
  final cities = ref.watch(
    settingsProvider.select((settings) => settings.cities),
  );
  return cities.isNotEmpty ? cities : cityCatalog;
});

/// The active city, resolved against [appCitiesProvider]. Falls back to the
/// first city when the stored selection is unset or no longer present.
final selectedCityProvider = Provider<CityLocation>((ref) {
  final cities = ref.watch(appCitiesProvider);
  final selectedId = ref.watch(
    settingsProvider.select((settings) => settings.selectedCityId),
  );
  return cities.firstWhere(
    (city) => city.id == selectedId,
    orElse: () => cities.first,
  );
});

/// The weather bundle for [city], fetched through the Caiyun client.
///
/// The provider is keyed by [CityLocation] (by id) and rebuilt — hence
/// refetched — whenever the client changes, e.g. after a new API key or
/// language. Kept alive so switching tabs or back to a city does not refetch.
final weatherBundleProvider =
    FutureProvider.family<WeatherBundle, CityLocation>((ref, city) {
      final api = ref.watch(caiyunApiProvider);
      if (api == null) {
        throw StateError('Weather requested without an API key');
      }
      return api.fetch(city);
    });

/// The active weather tab. Ephemeral UI state, reset to today on each launch.
final weatherTabProvider = NotifierProvider<WeatherTabNotifier, WeatherTab>(
  WeatherTabNotifier.new,
);

class WeatherTabNotifier extends Notifier<WeatherTab> {
  @override
  WeatherTab build() => WeatherTab.today;

  void select(WeatherTab tab) => state = tab;
}
