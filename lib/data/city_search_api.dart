import '../models/weather.dart';
import 'api_client.dart';

/// Raised when the China Weather area search endpoint cannot be reached or
/// answers with data the app cannot read.
class CitySearchException implements Exception {
  const CitySearchException();

  @override
  String toString() => 'CitySearchException';
}

/// Keyword search over the China Weather area endpoints, as used by the APK's
/// `CityActivity`.
///
/// The service has no i18n: province/city/district labels come back in Chinese
/// and are shown verbatim. Each result's `cid` doubles as the [CityLocation.id]
/// so it can be de-duplicated against the user's saved cities.
class CitySearchApi extends JsonApiClient {
  CitySearchApi({super.client});

  static const String _baseUrl =
      'https://decision-admin.tianqi.cn/Home/work2019/searchAreaInfo';

  @override
  CitySearchException transportFailure() => const CitySearchException();

  @override
  CitySearchException badStatus(int statusCode) => const CitySearchException();

  @override
  CitySearchException invalidBody() => const CitySearchException();

  /// Returns the cities whose province/city/district matches [keyword].
  ///
  /// An empty keyword yields no results without hitting the network.
  Future<List<CityLocation>> search(String keyword) async {
    final query = keyword.trim();
    if (query.isEmpty) return const [];

    final uri = Uri.parse(_baseUrl)
        .replace(queryParameters: <String, String>{'key': query});

    final decoded = await getJson(uri);

    if (decoded is! List) throw const CitySearchException();

    final cities = <CityLocation>[];
    for (final item in decoded) {
      if (item is! Map) continue;
      final id = item['cid']?.toString().trim();
      final longitude = double.tryParse(item['lng']?.toString() ?? '');
      final latitude = double.tryParse(item['lat']?.toString() ?? '');
      if (id == null || id.isEmpty || longitude == null || latitude == null) {
        continue;
      }
      cities.add(
        CityLocation(
          id: id,
          name: _label(item['pro'], item['city'], item['dis']),
          longitude: longitude,
          latitude: latitude,
        ),
      );
    }
    return cities;
  }

  /// Joins the province/city/district with `，`, dropping empty and repeated
  /// parts so municipalities like Beijing render as `北京` rather than
  /// `北京，北京，北京`.
  static String _label(Object? province, Object? city, Object? district) {
    final parts = <String>[];
    for (final value in [province, city, district]) {
      final text = value?.toString().trim();
      if (text == null || text.isEmpty) continue;
      if (parts.isEmpty || parts.last != text) parts.add(text);
    }
    return parts.join('，');
  }
}
