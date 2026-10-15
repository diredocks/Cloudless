import '../theme/weather_palette.dart';
import 'city.dart';

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
