import 'package:shared_preferences/shared_preferences.dart';

/// Persistence for user settings.
abstract class SettingsStore {
  String? get apiKey;

  Future<void> setApiKey(String value);

  /// Preferred UI language code (`en`, `zh`) or null to follow the system.
  String? get languageCode;

  Future<void> setLanguageCode(String? value);
}

/// [SettingsStore] backed by [SharedPreferences].
class SharedPreferencesSettingsStore implements SettingsStore {
  SharedPreferencesSettingsStore(this._preferences);

  static const String _apiKeyKey = 'caiyun_api_key';
  static const String _languageKey = 'app_language';

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
    } else {
      await _preferences.setString(_languageKey, value);
    }
  }
}
