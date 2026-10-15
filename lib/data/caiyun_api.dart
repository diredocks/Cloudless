import '../models/weather.dart';
import 'api_client.dart';
import 'skycons.dart';

/// Categories of failure the UI can translate on its own. The [detail] carries
/// any service-provided text (already localized by the requested `lang`).
enum WeatherErrorKind {
  unreachable,
  badStatus,
  invalidData,
  serviceError,
  noData,
}

/// Raised when the Caiyun weather service cannot be reached or answers with an
/// error.
class WeatherApiException implements Exception {
  const WeatherApiException(this.kind, {this.detail, this.statusCode});

  final WeatherErrorKind kind;

  /// Service-provided error text, when available.
  final String? detail;

  /// HTTP status code, set for [WeatherErrorKind.badStatus].
  final int? statusCode;

  @override
  String toString() => detail ?? kind.name;
}

/// Thin client for the Caiyun v2.6 comprehensive weather endpoint.
///
/// Docs: https://docs.caiyunapp.com/weather-api/v2/v2.6/6-weather.html
class CaiyunApi extends JsonApiClient {
  CaiyunApi({required this.token, this.language = 'en_US', super.client});

  static const String _baseUrl = 'https://api.caiyunapp.com/v2.6';

  final String token;

  /// Caiyun `lang` value, e.g. `en_US` or `zh_CN`.
  final String language;

  @override
  WeatherApiException transportFailure() =>
      const WeatherApiException(WeatherErrorKind.unreachable);

  @override
  WeatherApiException badStatus(int statusCode) =>
      WeatherApiException(WeatherErrorKind.badStatus, statusCode: statusCode);

  @override
  WeatherApiException invalidBody() =>
      const WeatherApiException(WeatherErrorKind.invalidData);

  Future<WeatherBundle> fetch(CityLocation city) async {
    final uri =
        Uri.parse('$_baseUrl/$token/${city.longitude},${city.latitude}/weather')
            .replace(
              queryParameters: <String, String>{
                'lang': language,
                'dailysteps': '7',
                'hourlysteps': '24',
              },
            );

    final decoded = await getJson(uri);

    if (decoded is! Map<String, dynamic> || decoded['status'] != 'ok') {
      final error = decoded is Map ? decoded['error'] : null;
      throw WeatherApiException(
        WeatherErrorKind.serviceError,
        detail: error?.toString(),
      );
    }

    final result = decoded['result'];
    if (result is! Map<String, dynamic>) {
      throw const WeatherApiException(WeatherErrorKind.noData);
    }

    return CaiyunMapper.toBundle(city, result);
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
    final hourly = _map(result['hourly']);

    return WeatherBundle(
      city: city,
      current: _current(city, realtime, result, daily),
      weekly: _weekly(city, daily),
      hourly: _hourly(city, hourly),
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
      city: city,
      temperature: temperature,
      skycon: skycon,
      apiSummary: (keypoint == null || keypoint.isEmpty) ? null : keypoint,
      feelsLike: apparent,
      comfortDesc: _text(comfort['desc']),
      windSpeed: windSpeed,
      uvIndex: _round(uv['index']),
      uvDesc: _text(uv['desc']),
      rainProbability: probability,
      rainIntensity: intensity,
      palette: skyconFor(skycon).palette,
    );
  }

  static WeeklyWeather _weekly(CityLocation city, Map<String, dynamic> daily) {
    final skycons = daily['skycon'];
    final rawTemperatures = daily['temperature'];
    final temperatures = rawTemperatures is List ? rawTemperatures : const [];
    final days = <DailyForecast>[];

    for (var i = 0; i < temperatures.length; i++) {
      final entry = _map(temperatures[i]);
      final date = entry['date'] as String?;
      if (date == null) continue;
      days.add(
        DailyForecast(
          date: date,
          skycon: _skyconAt(skycons, i),
          temperature: _round(entry['max']),
        ),
      );
    }

    final dominant = _dominantSkycon(skycons);
    return WeeklyWeather(
      city: city,
      dominantSkycon: dominant,
      days: days,
      palette: skyconFor(dominant).palette,
    );
  }

  static HourlyWeather _hourly(CityLocation city, Map<String, dynamic> hourly) {
    final rawTemperatures = hourly['temperature'];
    final temperatures = rawTemperatures is List ? rawTemperatures : const [];
    final skycons = hourly['skycon'];
    final precipitations = hourly['precipitation'];
    final hours = <HourlyForecast>[];

    for (var i = 0; i < temperatures.length; i++) {
      final entry = _map(temperatures[i]);
      final datetime = entry['datetime'] as String?;
      if (datetime == null) continue;
      hours.add(
        HourlyForecast(
          datetime: datetime,
          skycon: _skyconAt(skycons, i),
          temperature: _round(entry['value']),
          rainProbability: _probabilityAt(precipitations, i),
        ),
      );
    }

    final dominant = _dominantSkycon(skycons);
    return HourlyWeather(
      city: city,
      dominantSkycon: dominant,
      hours: hours,
      palette: skyconFor(dominant).palette,
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

  static int _probabilityAt(Object? list, int index) {
    if (list is List && index < list.length) {
      final value = _map(list[index])['probability'];
      if (value is num) return value.round();
    }
    return 0;
  }

  static Map<String, dynamic> _map(Object? value) =>
      value is Map<String, dynamic> ? value : const <String, dynamic>{};

  static int _round(Object? value, {int fallback = 0}) =>
      value is num ? value.round() : fallback;

  static double _double(Object? value, {double fallback = 0}) =>
      value is num ? value.toDouble() : fallback;

  static String? _text(Object? value) {
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return null;
  }
}
