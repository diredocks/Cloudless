import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather.dart';
import '../theme/weather_palette.dart';

/// Raised when the Caiyun weather service cannot be reached or answers with an
/// error.
class WeatherApiException implements Exception {
  const WeatherApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thin client for the Caiyun v2.6 comprehensive weather endpoint.
///
/// Docs: https://docs.caiyunapp.com/weather-api/v2/v2.6/6-weather.html
class CaiyunApi {
  CaiyunApi({required this.token, http.Client? client})
      : _client = client ?? http.Client(),
        _ownsClient = client == null;

  static const String _baseUrl = 'https://api.caiyunapp.com/v2.6';

  final String token;
  final http.Client _client;
  final bool _ownsClient;

  Future<WeatherBundle> fetch(CityLocation city) async {
    final uri = Uri.parse(
      '$_baseUrl/$token/${city.longitude},${city.latitude}/weather'
      '?lang=en_US&dailysteps=7&hourlysteps=24',
    );

    final http.Response response;
    try {
      response = await _client.get(uri);
    } on Exception {
      throw const WeatherApiException('could not reach the weather service');
    }

    if (response.statusCode != 200) {
      throw WeatherApiException(
        'the weather service returned ${response.statusCode}',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const WeatherApiException(
        'the weather service returned invalid data',
      );
    }

    if (decoded is! Map<String, dynamic> || decoded['status'] != 'ok') {
      final error = decoded is Map ? decoded['error'] : null;
      throw WeatherApiException(
        error?.toString() ?? 'the weather service returned an error',
      );
    }

    final result = decoded['result'];
    if (result is! Map<String, dynamic>) {
      throw const WeatherApiException('the weather service returned no data');
    }

    return CaiyunMapper.toBundle(city, result);
  }

  void dispose() {
    if (_ownsClient) _client.close();
  }
}

/// Translates a Caiyun `result` payload into the app's display models.
class CaiyunMapper {
  const CaiyunMapper._();

  static WeatherBundle toBundle(
    CityLocation city,
    Map<String, dynamic> result,
  ) {
    final realtime = _map(result['realtime']);
    final daily = _map(result['daily']);

    return WeatherBundle(
      city: city,
      current: _current(city, realtime, result, daily),
      weekly: _weekly(city, daily),
    );
  }

  static CurrentWeather _current(
    CityLocation city,
    Map<String, dynamic> realtime,
    Map<String, dynamic> result,
    Map<String, dynamic> daily,
  ) {
    final temperature = _round(realtime['temperature']);
    final apparent = _round(
      realtime['apparent_temperature'],
      fallback: temperature,
    );

    final wind = _map(realtime['wind']);
    final windSpeed = _round(wind['speed']);

    final lifeIndex = _map(realtime['life_index']);
    final uv = _map(lifeIndex['ultraviolet']);
    final comfort = _map(lifeIndex['comfort']);

    final local = _map(_map(realtime['precipitation'])['local']);
    final intensity = _double(local['intensity']);
    final probability = _probability(result, daily);

    final skycon = realtime['skycon'] as String? ?? 'CLEAR_DAY';
    final keypoint = (result['forecast_keypoint'] as String?)?.trim();

    return CurrentWeather(
      location: city.name,
      temperature: temperature,
      summary: (keypoint == null || keypoint.isEmpty)
          ? skyconText(skycon)
          : keypoint,
      feelsLikeValue: '$apparent\u00B0',
      feelsLikeLabel: _label(comfort['desc'], fallback: 'mild'),
      windValue: '$windSpeed km/h',
      windLabel: windLabel(windSpeed),
      uvValue: '${_round(uv['index'])}',
      uvLabel: _label(uv['desc'], fallback: 'low'),
      rainValue: '$probability%',
      rainLabel: _rainLabel(intensity, probability),
      palette: paletteFor(skycon),
    );
  }

  static WeeklyWeather _weekly(
    CityLocation city,
    Map<String, dynamic> daily,
  ) {
    final skycons = daily['skycon'];
    final temperatures = daily['temperature'];
    final days = <DailyForecast>[];

    if (temperatures is List) {
      for (var i = 0; i < temperatures.length; i++) {
        final entry = _map(temperatures[i]);
        final date = entry['date'] as String?;
        if (date == null) continue;
        days.add(
          DailyForecast(
            day: weekdayName(date),
            condition: skyconText(_skyconAt(skycons, i)),
            temperature: _round(entry['max']),
          ),
        );
      }
    }

    final dominant = _dominantSkycon(skycons);
    return WeeklyWeather(
      location: city.name,
      summary: 'mostly ${skyconText(dominant)} for the next 7 days',
      days: days,
      palette: paletteFor(dominant),
    );
  }

  /// Rain probability (0-100) for the next hour, falling back to today's daily
  /// probability.
  static int _probability(
    Map<String, dynamic> result,
    Map<String, dynamic> daily,
  ) {
    final hourly = _map(result['hourly']);
    final hourlyPrecipitation = hourly['precipitation'];
    if (hourlyPrecipitation is List && hourlyPrecipitation.isNotEmpty) {
      final value = _map(hourlyPrecipitation.first)['probability'];
      if (value is num) return value.round();
    }

    final dailyPrecipitation = daily['precipitation'];
    if (dailyPrecipitation is List && dailyPrecipitation.isNotEmpty) {
      final value = _map(dailyPrecipitation.first)['probability'];
      if (value is num) return value.round();
    }

    return 0;
  }

  static String _rainLabel(double intensity, int probability) {
    if (intensity > 0) return 'raining';
    if (probability >= 60) return 'likely';
    if (probability >= 30) return 'possible';
    return 'dry';
  }

  static String _dominantSkycon(Object? skyconList) {
    if (skyconList is! List || skyconList.isEmpty) return 'CLEAR_DAY';

    final counts = <String, int>{};
    String? top;
    var topCount = 0;
    for (final item in skyconList) {
      final value = _map(item)['value'];
      if (value is! String) continue;
      final count = (counts[value] ?? 0) + 1;
      counts[value] = count;
      if (count > topCount) {
        topCount = count;
        top = value;
      }
    }
    return top ?? 'CLEAR_DAY';
  }

  static String _skyconAt(Object? list, int index) {
    if (list is List && index < list.length) {
      final value = _map(list[index])['value'];
      if (value is String) return value;
    }
    return 'CLEAR_DAY';
  }

  static const _weekdays = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  /// Weekday name from an ISO-8601 date string such as `2026-10-14T00:00+02:00`.
  static String weekdayName(String isoDate) {
    final datePart = isoDate.length >= 10 ? isoDate.substring(0, 10) : isoDate;
    final date = DateTime.tryParse(datePart);
    if (date == null) return '';
    return _weekdays[date.weekday - 1];
  }

  static String windLabel(num speedKmh) {
    if (speedKmh < 6) return 'calm';
    if (speedKmh < 20) return 'breezy';
    if (speedKmh < 39) return 'windy';
    return 'strong';
  }

  static String skyconText(String skycon) {
    switch (skycon) {
      case 'CLEAR_DAY':
        return 'sunny';
      case 'CLEAR_NIGHT':
        return 'clear';
      case 'PARTLY_CLOUDY_DAY':
      case 'PARTLY_CLOUDY_NIGHT':
        return 'partly cloudy';
      case 'CLOUDY':
        return 'cloudy';
      case 'LIGHT_HAZE':
        return 'light haze';
      case 'MODERATE_HAZE':
        return 'hazy';
      case 'HEAVY_HAZE':
        return 'heavy haze';
      case 'FOG':
        return 'foggy';
      case 'DUST':
        return 'dusty';
      case 'SAND':
        return 'sandy';
      case 'WIND':
        return 'windy';
      case 'LIGHT_RAIN':
        return 'light rain';
      case 'MODERATE_RAIN':
        return 'rain';
      case 'HEAVY_RAIN':
        return 'heavy rain';
      case 'STORM_RAIN':
        return 'storm';
      case 'LIGHT_SNOW':
        return 'light snow';
      case 'MODERATE_SNOW':
        return 'snow';
      case 'HEAVY_SNOW':
        return 'heavy snow';
      case 'STORM_SNOW':
        return 'blizzard';
      default:
        return 'clear';
    }
  }

  static WeatherPalette paletteFor(String skycon) {
    switch (skycon) {
      case 'CLEAR_DAY':
        return WeatherPalette.orange;
      case 'CLEAR_NIGHT':
      case 'PARTLY_CLOUDY_NIGHT':
        return WeatherPalette.navy;
      case 'PARTLY_CLOUDY_DAY':
      case 'FOG':
      case 'WIND':
      case 'LIGHT_SNOW':
      case 'MODERATE_SNOW':
      case 'HEAVY_SNOW':
      case 'STORM_SNOW':
        return WeatherPalette.sky;
      case 'CLOUDY':
      case 'LIGHT_RAIN':
      case 'MODERATE_RAIN':
      case 'HEAVY_RAIN':
      case 'STORM_RAIN':
        return WeatherPalette.blue;
      case 'LIGHT_HAZE':
      case 'MODERATE_HAZE':
      case 'HEAVY_HAZE':
      case 'DUST':
      case 'SAND':
        return WeatherPalette.orange;
      default:
        return WeatherPalette.sky;
    }
  }

  static Map<String, dynamic> _map(Object? value) =>
      value is Map<String, dynamic> ? value : const <String, dynamic>{};

  static int _round(Object? value, {int fallback = 0}) =>
      value is num ? value.round() : fallback;

  static double _double(Object? value, {double fallback = 0}) =>
      value is num ? value.toDouble() : fallback;

  static String _label(Object? value, {required String fallback}) {
    if (value is String && value.trim().isNotEmpty) {
      return value.toLowerCase();
    }
    return fallback;
  }
}
