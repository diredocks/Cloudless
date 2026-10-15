import 'city.dart';

/// The user's persisted preferences: API credentials, display options and the
/// saved city list.
class Settings {
  const Settings({
    this.apiKey,
    this.languageCode,
    this.use24Hour = false,
    this.cities = const [],
    this.selectedCityId,
  });

  /// Caiyun API token, or null when not configured yet.
  final String? apiKey;

  /// Preferred UI language code (`en`, `zh`) or null to follow the system.
  final String? languageCode;

  /// Whether hourly forecast times use a 24-hour clock; false means am/pm.
  final bool use24Hour;

  /// The user's cities in display order. Empty when none have been saved yet.
  final List<CityLocation> cities;

  /// Id of the currently selected city, or null when unset.
  final String? selectedCityId;

  /// Returns a copy with the given fields replaced.
  ///
  /// The nullable fields keep their current value when omitted; construct a
  /// [Settings] directly to reset one to null.
  Settings copyWith({
    String? apiKey,
    String? languageCode,
    bool? use24Hour,
    List<CityLocation>? cities,
    String? selectedCityId,
  }) => Settings(
    apiKey: apiKey ?? this.apiKey,
    languageCode: languageCode ?? this.languageCode,
    use24Hour: use24Hour ?? this.use24Hour,
    cities: cities ?? this.cities,
    selectedCityId: selectedCityId ?? this.selectedCityId,
  );
}

/// The display options edited on the settings screen, held separately from the
/// persisted [Settings] so edits stay local until the user saves.
///
/// The API key is edited through a text field and applied on save, so it is not
/// part of the draft.
class SettingsDraft {
  const SettingsDraft({this.languageCode, this.use24Hour = false});

  /// The editable fields of [settings].
  factory SettingsDraft.from(Settings settings) => SettingsDraft(
    languageCode: settings.languageCode,
    use24Hour: settings.use24Hour,
  );

  /// Preferred UI language (`en`, `zh`) or null to follow the system.
  final String? languageCode;

  /// Whether hourly forecast times use a 24-hour clock.
  final bool use24Hour;

  /// Returns a copy with [languageCode] replaced, or null to follow the system.
  SettingsDraft withLanguage(String? languageCode) =>
      SettingsDraft(languageCode: languageCode, use24Hour: use24Hour);

  /// Returns a copy with [use24Hour] replaced.
  SettingsDraft withUse24Hour(bool use24Hour) =>
      SettingsDraft(languageCode: languageCode, use24Hour: use24Hour);

  /// Builds the [Settings] to persist from the draft's display options and
  /// [apiKey], keeping the saved cities and selection from [base].
  Settings toSettings(Settings base, {required String apiKey}) => Settings(
    apiKey: apiKey,
    languageCode: languageCode,
    use24Hour: use24Hour,
    cities: base.cities,
    selectedCityId: base.selectedCityId,
  );
}
