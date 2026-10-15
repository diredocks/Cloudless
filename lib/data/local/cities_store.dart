import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/city.dart';

/// Persistence for the user's saved [CityList].
abstract class CitiesStore {
  /// The current city list, seeded on load and kept up to date by [save].
  CityList get cityList;

  /// Persists [cityList], replacing the stored value.
  Future<void> save(CityList cityList);
}

/// [CitiesStore] backed by [SharedPreferences].
class SharedPreferencesCitiesStore implements CitiesStore {
  SharedPreferencesCitiesStore(this._preferences)
    : _cityList = _read(_preferences);

  static const String _citiesKey = 'saved_cities';
  static const String _selectedCityKey = 'selected_city';

  final SharedPreferences _preferences;
  CityList _cityList;

  static Future<SharedPreferencesCitiesStore> load() async =>
      SharedPreferencesCitiesStore(await SharedPreferences.getInstance());

  @override
  CityList get cityList => _cityList;

  @override
  Future<void> save(CityList value) async {
    _cityList = value;
    await _preferences.setStringList(_citiesKey, [
      for (final city in value.cities) jsonEncode(city.toJson()),
    ]);
    await _setOrRemove(_selectedCityKey, value.selectedCityId);
  }

  static CityList _read(SharedPreferences preferences) => CityList(
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
