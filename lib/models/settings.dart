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
