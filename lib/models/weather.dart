import '../theme/weather_palette.dart';

class CurrentWeather {
  const CurrentWeather({
    required this.city,
    required this.temperature,
    required this.skycon,
    required this.apiSummary,
    required this.feelsLike,
    required this.comfortDesc,
    required this.windSpeed,
    required this.uvIndex,
    required this.uvDesc,
    required this.rainProbability,
    required this.rainIntensity,
    required this.palette,
  });

  final CityLocation city;
  final int temperature;

  /// Caiyun sky condition code, e.g. `CLEAR_DAY`.
  final String skycon;

  /// Natural-language keypoint returned by Caiyun, already localized by the
  /// requested `lang`. May be null or empty.
  final String? apiSummary;

  final int feelsLike;

  /// Comfort description returned by Caiyun's life index, already localized.
  final String? comfortDesc;

  final num windSpeed;

  final int uvIndex;

  /// Ultraviolet description returned by Caiyun's life index.
  final String? uvDesc;

  final int rainProbability;
  final double rainIntensity;

  final WeatherPalette palette;
}

class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.skycon,
    required this.temperature,
  });

  /// ISO-8601 date (or date-time) as returned by Caiyun.
  final String date;

  final String skycon;
  final int temperature;
}

class HourlyForecast {
  const HourlyForecast({
    required this.datetime,
    required this.skycon,
    required this.temperature,
    required this.rainProbability,
  });

  /// ISO-8601 date-time as returned by Caiyun.
  final String datetime;

  final String skycon;
  final int temperature;
  final int rainProbability;
}

class WeeklyWeather {
  const WeeklyWeather({
    required this.city,
    required this.dominantSkycon,
    required this.days,
    required this.palette,
  });

  final CityLocation city;

  /// Most frequent sky condition across the forecast window.
  final String dominantSkycon;

  final List<DailyForecast> days;
  final WeatherPalette palette;
}

class HourlyWeather {
  const HourlyWeather({
    required this.city,
    required this.dominantSkycon,
    required this.hours,
    required this.palette,
  });

  final CityLocation city;

  /// Most frequent sky condition across the forecast window.
  final String dominantSkycon;

  final List<HourlyForecast> hours;
  final WeatherPalette palette;
}

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
}

class WeatherBundle {
  const WeatherBundle({
    required this.city,
    required this.current,
    required this.weekly,
    required this.hourly,
  });

  final CityLocation city;
  final CurrentWeather current;
  final WeeklyWeather weekly;
  final HourlyWeather hourly;
}
