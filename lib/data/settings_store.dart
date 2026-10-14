import 'package:shared_preferences/shared_preferences.dart';

/// Persistence for user settings.
abstract class SettingsStore {
  String? get apiKey;

  Future<void> setApiKey(String value);
}

/// [SettingsStore] backed by [SharedPreferences].
class SharedPreferencesSettingsStore implements SettingsStore {
  SharedPreferencesSettingsStore(this._preferences);

  static const String _apiKeyKey = 'caiyun_api_key';

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
}
