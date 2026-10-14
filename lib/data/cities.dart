import '../models/weather.dart';

/// Default cities seeded on first run. Caiyun does not expose forward
/// geocoding, so the search feature finds more cities through
/// [CitySearchApi].
///
/// The China Weather city codes are used as ids, so these match the remote
/// search results and display in Chinese (that API has no i18n).
const cityCatalog = <CityLocation>[
  CityLocation(
    id: '101010100',
    name: '北京',
    longitude: 116.407526,
    latitude: 39.904030,
  ),
  CityLocation(
    id: '101020100',
    name: '上海',
    longitude: 121.472644,
    latitude: 31.231706,
  ),
  CityLocation(
    id: '101280101',
    name: '广州',
    longitude: 113.280637,
    latitude: 23.125178,
  ),
];
