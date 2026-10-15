import 'package:flutter/foundation.dart';

import '../data/caiyun_api.dart';
import '../data/cities.dart';
import '../data/settings_store.dart';
import '../models/weather.dart';
import '../widgets/weather_bottom_nav.dart';

/// Owns the weather session state: the user's cities, the selected one, the
/// active tab and the fetched bundles.
///
/// Keeping networking and persistence here leaves the widget tree to render
/// only, and makes the session logic unit-testable without a widget harness.
class WeatherController extends ChangeNotifier {
  WeatherController({required CaiyunApi api, required SettingsStore store}) {
    _api = api;
    _store = store;
    final saved = store.settings;
    _cities = saved.cities.isNotEmpty
        ? List.of(saved.cities)
        : List.of(cityCatalog);
    final savedId = saved.selectedCityId;
    _selectedCityId = _cities.any((c) => c.id == savedId)
        ? savedId!
        : _cities.first.id;
  }

  late final CaiyunApi _api;
  late final SettingsStore _store;

  late List<CityLocation> _cities;
  late String _selectedCityId;
  WeatherTab _tab = WeatherTab.today;
  final Map<String, WeatherBundle> _bundles = {};
  bool _loading = true;
  Object? _error;
  bool _disposed = false;

  List<CityLocation> get cities => _cities;
  String get selectedCityId => _selectedCityId;
  WeatherTab get tab => _tab;
  Map<String, WeatherBundle> get bundles => _bundles;
  bool get loading => _loading;
  Object? get error => _error;

  CityLocation get selectedCity => _cities.firstWhere(
    (c) => c.id == _selectedCityId,
    orElse: () => _cities.first,
  );

  Future<Map<String, WeatherBundle>> _fetchBundles() async {
    final entries = await Future.wait(
      _cities.map((city) async => MapEntry(city.id, await _api.fetch(city))),
    );
    return Map.fromEntries(entries);
  }

  /// Loads every city, driving the loading/error status.
  Future<void> load() async {
    _loading = true;
    _error = null;
    _notify();
    try {
      final bundles = await _fetchBundles();
      _bundles
        ..clear()
        ..addAll(bundles);
      _loading = false;
    } on Exception catch (error) {
      _error = error;
      _loading = false;
    }
    _notify();
  }

  /// Reloads the current cities without blanking the screen. Rethrows failures
  /// so the caller can surface them.
  Future<void> refresh() async {
    final bundles = await _fetchBundles();
    _bundles
      ..clear()
      ..addAll(bundles);
    _notify();
  }

  void selectTab(WeatherTab tab) {
    _tab = tab;
    _notify();
  }

  void selectCity(CityLocation city) {
    _selectedCityId = city.id;
    _tab = WeatherTab.today;
    _notify();
    _store.save(_store.settings.copyWith(selectedCityId: city.id));
  }

  /// Adds [city] and loads its weather. Resolves to true when the city is now
  /// available, false when its weather could not be fetched.
  Future<bool> addCity(CityLocation city) async {
    if (_cities.any((c) => c.id == city.id)) {
      selectCity(city);
      return true;
    }

    final WeatherBundle bundle;
    try {
      bundle = await _api.fetch(city);
    } on Exception {
      return false;
    }
    if (_disposed) return false;

    _cities = [..._cities, city];
    _bundles[city.id] = bundle;
    _notify();
    await _store.save(_store.settings.copyWith(cities: _cities));
    return true;
  }

  void removeCity(CityLocation city) {
    if (_cities.length <= 1) return;
    _cities = _cities.where((c) => c.id != city.id).toList();
    _bundles.remove(city.id);
    if (_selectedCityId == city.id) {
      _selectedCityId = _cities.first.id;
    }
    _notify();
    _store.save(
      _store.settings.copyWith(
        cities: _cities,
        selectedCityId: _selectedCityId,
      ),
    );
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
