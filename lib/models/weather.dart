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

class CityLocation {
  const CityLocation({
    required this.id,
    required this.name,
    required this.longitude,
    required this.latitude,
  });

  final String id;

  /// Default (English) display name; localized names live in the l10n layer.
  final String name;

  final double longitude;
  final double latitude;
}

class WeatherBundle {
  const WeatherBundle({
    required this.city,
    required this.current,
    required this.weekly,
  });

  final CityLocation city;
  final CurrentWeather current;
  final WeeklyWeather weekly;
}
