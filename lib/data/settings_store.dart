import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/weather.dart';

/// Persistence for user settings and the saved city list.
abstract class SettingsStore {
  String? get apiKey;

  Future<void> setApiKey(String value);

  /// Preferred UI language code (`en`, `zh`) or null to follow the system.
  String? get languageCode;

  Future<void> setLanguageCode(String? value);

  /// Whether hourly forecast times use a 24-hour clock; false means am/pm.
  bool get use24Hour;

  Future<void> setUse24Hour(bool value);

  /// The user's cities in display order. Empty when the user has not saved any
  /// yet, in which case the caller seeds the defaults.
  List<CityLocation> get cities;

  Future<void> setCities(List<CityLocation> cities);

  /// Id of the currently selected city, or null when unset.
  String? get selectedCityId;

  Future<void> setSelectedCityId(String? value);
}

/// [SettingsStore] backed by [SharedPreferences].
class SharedPreferencesSettingsStore implements SettingsStore {
  SharedPreferencesSettingsStore(this._preferences);

  static const String _apiKeyKey = 'caiyun_api_key';
  static const String _languageKey = 'app_language';
  static const String _use24HourKey = 'use_24_hour';
  static const String _citiesKey = 'saved_cities';
  static const String _selectedCityKey = 'selected_city';

  final SharedPreferences _preferences;

  static Future<SharedPreferencesSettingsStore> load() async =>
      SharedPreferencesSettingsStore(await SharedPreferences.getInstance());

  @override
  String? get apiKey {
    final value = _preferences.getString(_apiKeyKey);
    return (value == null || value.isEmpty) ? null : value;
  }

  @override
  Future<void> setApiKey(String value) =>
      _preferences.setString(_apiKeyKey, value);

  @override
  String? get languageCode {
    final value = _preferences.getString(_languageKey);
    return (value == null || value.isEmpty) ? null : value;
  }

  @override
  Future<void> setLanguageCode(String? value) async {
    if (value == null || value.isEmpty) {
      await _preferences.remove(_languageKey);
      return;
    }
    await _preferences.setString(_languageKey, value);
  }

  @override
  bool get use24Hour => _preferences.getBool(_use24HourKey) ?? false;

  @override
  Future<void> setUse24Hour(bool value) =>
      _preferences.setBool(_use24HourKey, value);

  @override
  List<CityLocation> get cities {
    final raw = _preferences.getStringList(_citiesKey);
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

  @override
  Future<void> setCities(List<CityLocation> cities) =>
      _preferences.setStringList(_citiesKey, [
        for (final city in cities) jsonEncode(city.toJson()),
      ]);

  @override
  String? get selectedCityId {
    final value = _preferences.getString(_selectedCityKey);
    return (value == null || value.isEmpty) ? null : value;
  }

  @override
  Future<void> setSelectedCityId(String? value) async {
    if (value == null || value.isEmpty) {
      await _preferences.remove(_selectedCityKey);
      return;
    }
    await _preferences.setString(_selectedCityKey, value);
  }
}
