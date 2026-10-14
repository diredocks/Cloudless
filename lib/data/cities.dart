import '../l10n/app_localizations.dart';
import '../models/weather.dart';

/// Cities the app can show. Caiyun does not expose forward geocoding, so the
/// search feature filters this fixed catalog and real weather is fetched by
/// coordinate.
const cityCatalog = <CityLocation>[
  CityLocation(
    id: 'malaga',
    name: 'malaga, spain',
    longitude: -4.4214,
    latitude: 36.7213,
  ),
  CityLocation(
    id: 'dublin',
    name: 'dublin, ireland',
    longitude: -6.2603,
    latitude: 53.3498,
  ),
  CityLocation(
    id: 'paris',
    name: 'paris, france',
    longitude: 2.3522,
    latitude: 48.8566,
  ),
  CityLocation(
    id: 'reykjavik',
    name: 'reykjavik, iceland',
    longitude: -21.9426,
    latitude: 64.1466,
  ),
  CityLocation(
    id: 'london',
    name: 'london, uk',
    longitude: -0.1276,
    latitude: 51.5072,
  ),
];

/// Localized display name for [city], falling back to its catalog name.
///
/// Add the matching `city*` ARB entries when extending [cityCatalog].
String localizedCityName(AppLocalizations l10n, CityLocation city) =>
    switch (city.id) {
      'malaga' => l10n.cityMalaga,
      'dublin' => l10n.cityDublin,
      'paris' => l10n.cityParis,
      'reykjavik' => l10n.cityReykjavik,
      'london' => l10n.cityLondon,
      _ => city.name,
    };
