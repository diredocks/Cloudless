import 'package:cloudless_app/data/cities.dart';
import 'package:cloudless_app/data/settings_store.dart';
import 'package:cloudless_app/models/weather.dart';

/// The first catalog entry, used by tests that need a concrete [CityLocation].
final CityLocation malagaCity = cityCatalog.first;

/// In-memory [SettingsStore] for widget tests.
class MemorySettingsStore implements SettingsStore {
  MemorySettingsStore([this._apiKey, this._languageCode]);

  String? _apiKey;
  String? _languageCode;

  @override
  String? get apiKey => _apiKey;

  @override
  Future<void> setApiKey(String value) async => _apiKey = value;

  @override
  String? get languageCode => _languageCode;

  @override
  Future<void> setLanguageCode(String? value) async => _languageCode = value;
}
