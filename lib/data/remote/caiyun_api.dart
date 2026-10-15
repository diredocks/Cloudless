import '../../models/city.dart';
import '../../models/weather_bundle.dart';
import 'api_client.dart';
import 'caiyun_mapper.dart';
import 'weather_api_exception.dart';

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
