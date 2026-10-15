/// The user's persisted preferences: API credentials and display options.
class Settings {
  const Settings({this.apiKey, this.languageCode, this.use24Hour = false});

  /// Caiyun API token, or null when not configured yet.
  final String? apiKey;

  /// Preferred UI language code (`en`, `zh`) or null to follow the system.
  final String? languageCode;

  /// Whether hourly forecast times use a 24-hour clock; false means am/pm.
  final bool use24Hour;

  /// Returns a copy with the given fields replaced.
  ///
  /// The nullable fields keep their current value when omitted; construct a
  /// [Settings] directly to reset one to null.
  Settings copyWith({String? apiKey, String? languageCode, bool? use24Hour}) =>
      Settings(
        apiKey: apiKey ?? this.apiKey,
        languageCode: languageCode ?? this.languageCode,
        use24Hour: use24Hour ?? this.use24Hour,
      );
}

/// The fields edited on the settings screen, held separately from the
/// persisted [Settings] so edits stay local until the user saves.
class SettingsDraft {
  const SettingsDraft({
    this.apiKey = '',
    this.languageCode,
    this.use24Hour = false,
  });

  /// The editable fields of [settings].
  factory SettingsDraft.from(Settings settings) => SettingsDraft(
    apiKey: settings.apiKey ?? '',
    languageCode: settings.languageCode,
    use24Hour: settings.use24Hour,
  );

  /// Caiyun API token; empty when not entered yet.
  final String apiKey;

  /// Preferred UI language (`en`, `zh`) or null to follow the system.
  final String? languageCode;

  /// Whether hourly forecast times use a 24-hour clock.
  final bool use24Hour;

  /// Returns a copy with [apiKey] replaced.
  SettingsDraft withApiKey(String apiKey) => SettingsDraft(
    apiKey: apiKey,
    languageCode: languageCode,
    use24Hour: use24Hour,
  );

  /// Returns a copy with [languageCode] replaced, or null to follow the system.
  SettingsDraft withLanguage(String? languageCode) => SettingsDraft(
    apiKey: apiKey,
    languageCode: languageCode,
    use24Hour: use24Hour,
  );

  /// Returns a copy with [use24Hour] replaced.
  SettingsDraft withUse24Hour(bool use24Hour) => SettingsDraft(
    apiKey: apiKey,
    languageCode: languageCode,
    use24Hour: use24Hour,
  );

  /// The [Settings] to persist.
  Settings toSettings() => Settings(
    apiKey: apiKey,
    languageCode: languageCode,
    use24Hour: use24Hour,
  );
}
