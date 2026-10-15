/// A location the app can fetch weather for, identified by its provider id.
class CityLocation {
  const CityLocation({
    required this.id,
    required this.name,
    required this.longitude,
    required this.latitude,
  });

  factory CityLocation.fromJson(Map<String, Object?> json) => CityLocation(
    id: json['id'] as String,
    name: json['name'] as String,
    longitude: (json['longitude'] as num).toDouble(),
    latitude: (json['latitude'] as num).toDouble(),
  );

  final String id;

  /// Default (English) display name; localized names live in the l10n layer.
  final String name;

  final double longitude;
  final double latitude;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'name': name,
    'longitude': longitude,
    'latitude': latitude,
  };

  /// Identity is the city [id]: the catalog and the search API can report the
  /// same city with slightly different coordinates or labels.
  @override
  bool operator ==(Object other) => other is CityLocation && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// The user's saved cities in display order, plus the currently selected one.
class CityList {
  const CityList({this.cities = const [], this.selectedCityId});

  /// The user's cities in display order. Empty when none have been saved yet.
  final List<CityLocation> cities;

  /// Id of the currently selected city, or null when unset.
  final String? selectedCityId;

  /// Returns a copy with the given fields replaced.
  CityList copyWith({List<CityLocation>? cities, String? selectedCityId}) =>
      CityList(
        cities: cities ?? this.cities,
        selectedCityId: selectedCityId ?? this.selectedCityId,
      );
}

/// Default cities seeded on first run. Caiyun does not expose forward
/// geocoding, so the search feature finds more cities through
/// [CitySearchApi].
///
/// The China Weather city codes are used as ids, so these match the remote
/// search results and display in Chinese (that API has no i18n).
const cityCatalog = <CityLocation>[
  CityLocation(
    id: '101010100',
    name: '北京',
    longitude: 116.407526,
    latitude: 39.904030,
  ),
  CityLocation(
    id: '101020100',
    name: '上海',
    longitude: 121.472644,
    latitude: 31.231706,
  ),
  CityLocation(
    id: '101280101',
    name: '广州',
    longitude: 113.280637,
    latitude: 23.125178,
  ),
];
