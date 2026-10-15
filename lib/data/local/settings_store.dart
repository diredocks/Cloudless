import 'package:shared_preferences/shared_preferences.dart';

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
  }

  static Settings _read(SharedPreferences preferences) => Settings(
    apiKey: _nonEmpty(preferences.getString(_apiKeyKey)),
    languageCode: _nonEmpty(preferences.getString(_languageKey)),
    use24Hour: preferences.getBool(_use24HourKey) ?? false,
  );

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
