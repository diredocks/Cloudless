import 'city.dart';
import 'current_weather.dart';
import 'forecasts.dart';

/// Everything needed to render a city: the current conditions plus its weekly
/// and hourly forecasts.
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
