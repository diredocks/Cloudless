import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/caiyun_api.dart';
import '../data/cities.dart';
import '../models/weather.dart';
import '../models/weather_tab.dart';
import 'services.dart';

/// The weather session: the user's cities, the selected one, the active tab and
/// the fetched bundles.
class WeatherState {
  const WeatherState({
    required this.cities,
    required this.selectedId,
    required this.tab,
    required this.bundles,
  });

  final List<CityLocation> cities;
  final String selectedId;
  final WeatherTab tab;
  final Map<String, WeatherBundle> bundles;

  CityLocation get selectedCity => cities.firstWhere(
    (city) => city.id == selectedId,
    orElse: () => cities.first,
  );

  WeatherState copyWith({
    List<CityLocation>? cities,
    String? selectedId,
    WeatherTab? tab,
    Map<String, WeatherBundle>? bundles,
  }) => WeatherState(
    cities: cities ?? this.cities,
    selectedId: selectedId ?? this.selectedId,
    tab: tab ?? this.tab,
    bundles: bundles ?? this.bundles,
  );
}

/// Owns the weather session, rebuilding (and refetching) whenever the Caiyun
/// client changes, e.g. after a new API key or language is saved.
final weatherControllerProvider =
    AsyncNotifierProvider<WeatherController, WeatherState>(
      WeatherController.new,
    );

class WeatherController extends AsyncNotifier<WeatherState> {
  @override
  Future<WeatherState> build() async {
    final api = ref.watch(caiyunApiProvider);
    if (api == null) {
      throw StateError('Weather requested without an API key');
    }

    final settings = ref.read(settingsProvider);
    final cities = settings.cities.isNotEmpty
        ? List.of(settings.cities)
        : List.of(cityCatalog);
    final savedId = settings.selectedCityId;
    final selectedId = cities.any((city) => city.id == savedId)
        ? savedId!
        : cities.first.id;

    final bundles = await _fetchBundles(api, cities);
    return WeatherState(
      cities: cities,
      selectedId: selectedId,
      tab: WeatherTab.today,
      bundles: bundles,
    );
  }

  Future<Map<String, WeatherBundle>> _fetchBundles(
    CaiyunApi api,
    List<CityLocation> cities,
  ) async {
    final entries = await Future.wait(
      cities.map((city) async => MapEntry(city.id, await api.fetch(city))),
    );
    return Map.fromEntries(entries);
  }

  void selectTab(WeatherTab tab) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(tab: tab));
  }

  Future<void> selectCity(CityLocation city) async {
    final current = state.value;
    if (current == null) return;
    final next = current.copyWith(selectedId: city.id, tab: WeatherTab.today);
    state = AsyncData(next);
    await _persist(next);
  }

  /// Adds [city] and loads its weather. Resolves to true when the city is now
  /// available, false when its weather could not be fetched.
  Future<bool> addCity(CityLocation city) async {
    final current = state.value;
    if (current == null) return false;
    if (current.cities.any((c) => c.id == city.id)) {
      await selectCity(city);
      return true;
    }

    final api = ref.read(caiyunApiProvider);
    if (api == null) return false;

    final WeatherBundle bundle;
    try {
      bundle = await api.fetch(city);
    } on Exception {
      return false;
    }
    if (!ref.mounted) return false;

    final next = current.copyWith(
      cities: [...current.cities, city],
      bundles: {...current.bundles, city.id: bundle},
    );
    state = AsyncData(next);
    await _persist(next);
    return true;
  }

  Future<void> removeCity(CityLocation city) async {
    final current = state.value;
    if (current == null || current.cities.length <= 1) return;

    final cities = current.cities.where((c) => c.id != city.id).toList();
    final selectedId = current.selectedId == city.id
        ? cities.first.id
        : current.selectedId;
    final next = current.copyWith(
      cities: cities,
      selectedId: selectedId,
      bundles: Map.of(current.bundles)..remove(city.id),
    );
    state = AsyncData(next);
    await _persist(next);
  }

  /// Reloads the current cities without blanking the screen. Rethrows failures
  /// so the caller can surface them.
  Future<void> refresh() async {
    final current = state.value;
    final api = ref.read(caiyunApiProvider);
    if (current == null || api == null) return;
    final bundles = await _fetchBundles(api, current.cities);
    if (!ref.mounted) return;
    state = AsyncData(current.copyWith(bundles: bundles));
  }

  /// Writes the session's cities and selection through to [settingsProvider].
  Future<void> _persist(WeatherState session) async {
    final settings = ref.read(settingsProvider);
    await ref
        .read(settingsProvider.notifier)
        .save(
          settings.copyWith(
            cities: session.cities,
            selectedCityId: session.selectedId,
          ),
        );
  }
}
