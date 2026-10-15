import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/city.dart';
import '../../models/settings.dart';

/// Persistence for the user's [Settings].
abstract class SettingsStore {
  /// The current settings, seeded on load and kept up to date by [save].
  Settings get settings;

  /// Persists [settings], replacing the stored value.
  Future<void> save(Settings settings);
}

/// [SettingsStore] backed by [SharedPreferences].
class SharedPreferencesSettingsStore implements SettingsStore {
  SharedPreferencesSettingsStore(this._preferences)
    : _settings = _read(_preferences);

  static const String _apiKeyKey = 'caiyun_api_key';
  static const String _languageKey = 'app_language';
  static const String _use24HourKey = 'use_24_hour';
  static const String _citiesKey = 'saved_cities';
  static const String _selectedCityKey = 'selected_city';

  final SharedPreferences _preferences;
  Settings _settings;

  static Future<SharedPreferencesSettingsStore> load() async =>
      SharedPreferencesSettingsStore(await SharedPreferences.getInstance());

  @override
  Settings get settings => _settings;

  @override
  Future<void> save(Settings value) async {
    _settings = value;
    await _setOrRemove(_apiKeyKey, value.apiKey);
    await _setOrRemove(_languageKey, value.languageCode);
    await _preferences.setBool(_use24HourKey, value.use24Hour);
    await _preferences.setStringList(_citiesKey, [
      for (final city in value.cities) jsonEncode(city.toJson()),
    ]);
    await _setOrRemove(_selectedCityKey, value.selectedCityId);
  }

  static Settings _read(SharedPreferences preferences) => Settings(
    apiKey: _nonEmpty(preferences.getString(_apiKeyKey)),
    languageCode: _nonEmpty(preferences.getString(_languageKey)),
    use24Hour: preferences.getBool(_use24HourKey) ?? false,
    cities: _decodeCities(preferences.getStringList(_citiesKey)),
    selectedCityId: _nonEmpty(preferences.getString(_selectedCityKey)),
  );

  /// Decodes the stored city list, skipping entries that are corrupt or have an
  /// unexpected shape rather than losing the whole list.
  static List<CityLocation> _decodeCities(List<String>? raw) {
    if (raw == null) return const [];
    final result = <CityLocation>[];
    for (final entry in raw) {
      try {
        final decoded = jsonDecode(entry);
        if (decoded is Map<String, dynamic>) {
          result.add(CityLocation.fromJson(decoded));
        }
      } on FormatException {
        // Skip corrupt entries rather than losing the whole list.
      } on TypeError {
        // Skip entries with unexpected shapes.
      }
    }
    return result;
  }

  static String? _nonEmpty(String? value) =>
      (value == null || value.isEmpty) ? null : value;

  Future<void> _setOrRemove(String key, String? value) async {
    if (value == null || value.isEmpty) {
      await _preferences.remove(key);
      return;
    }
    await _preferences.setString(key, value);
  }
}
