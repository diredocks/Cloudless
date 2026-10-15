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
