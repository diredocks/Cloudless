import '../theme/weather_palette.dart';
import 'city.dart';

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
