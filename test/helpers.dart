import 'package:cloudless_app/data/cities.dart';
import 'package:cloudless_app/data/settings_store.dart';
import 'package:cloudless_app/models/weather.dart';

/// The first catalog entry, used by tests that need a concrete [CityLocation].
final CityLocation beijingCity = cityCatalog.first;

/// In-memory [SettingsStore] for widget tests.
class MemorySettingsStore implements SettingsStore {
  MemorySettingsStore([
    this._apiKey,
    this._languageCode,
    this._use24Hour = false,
  ]);

  String? _apiKey;
  String? _languageCode;
  bool _use24Hour;
  List<CityLocation> _cities = const [];
  String? _selectedCityId;

  @override
  String? get apiKey => _apiKey;

  @override
  Future<void> setApiKey(String value) async => _apiKey = value;

  @override
  String? get languageCode => _languageCode;

  @override
  Future<void> setLanguageCode(String? value) async => _languageCode = value;

  @override
  bool get use24Hour => _use24Hour;

  @override
  Future<void> setUse24Hour(bool value) async => _use24Hour = value;

  @override
  List<CityLocation> get cities => _cities;

  @override
  Future<void> setCities(List<CityLocation> cities) async =>
      _cities = List.of(cities);

  @override
  String? get selectedCityId => _selectedCityId;

  @override
  Future<void> setSelectedCityId(String? value) async =>
      _selectedCityId = value;
}
