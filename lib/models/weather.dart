import '../theme/weather_palette.dart';

class CurrentWeather {
  const CurrentWeather({
    required this.location,
    required this.temperature,
    required this.summary,
    required this.feelsLikeValue,
    required this.feelsLikeLabel,
    required this.windValue,
    required this.windLabel,
    required this.uvValue,
    required this.uvLabel,
    required this.rainValue,
    required this.rainLabel,
    required this.palette,
  });

  final String location;
  final int temperature;
  final String summary;

  final String feelsLikeValue;
  final String feelsLikeLabel;

  final String windValue;
  final String windLabel;

  final String uvValue;
  final String uvLabel;

  final String rainValue;
  final String rainLabel;

  final WeatherPalette palette;
}

class DailyForecast {
  const DailyForecast({
    required this.day,
    required this.condition,
    required this.temperature,
  });

  final String day;
  final String condition;
  final int temperature;
}

class WeeklyWeather {
  const WeeklyWeather({
    required this.location,
    required this.summary,
    required this.days,
    required this.palette,
  });

  final String location;
  final String summary;
  final List<DailyForecast> days;
  final WeatherPalette palette;
}

class City {
  const City({
    required this.name,
    required this.current,
  });

  final String name;
  final CurrentWeather current;
}
