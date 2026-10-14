import '../l10n/app_localizations.dart';
import '../theme/weather_palette.dart';

/// A Caiyun sky condition with its display palette and localized label.
///
/// Single source of truth for the mapping: to support a new condition add an
/// entry to [skyconCatalog] and the matching `sky*` ARB entries. Unknown codes
/// fall back to [fallbackSkycon].
class Skycon {
  const Skycon({
    required this.code,
    required this.palette,
    required this.label,
  });

  final String code;
  final WeatherPalette palette;

  /// Resolves the localized label for the given [AppLocalizations].
  final String Function(AppLocalizations) label;
}

/// Palette and label shown when the service reports an unrecognized code.
const fallbackSkycon = Skycon(
  code: '',
  palette: WeatherPalette.sky,
  label: _clearLabel,
);

String _clearLabel(AppLocalizations l10n) => l10n.skyClear;

/// Every supported Caiyun sky condition code.
final List<Skycon> skyconCatalog = <Skycon>[
  Skycon(
    code: 'CLEAR_DAY',
    palette: WeatherPalette.sunny,
    label: (l10n) => l10n.skySunny,
  ),
  Skycon(
    code: 'CLEAR_NIGHT',
    palette: WeatherPalette.clearNight,
    label: (l10n) => l10n.skyClear,
  ),
  Skycon(
    code: 'PARTLY_CLOUDY_DAY',
    palette: WeatherPalette.partlyCloudyDay,
    label: (l10n) => l10n.skyPartlyCloudy,
  ),
  Skycon(
    code: 'PARTLY_CLOUDY_NIGHT',
    palette: WeatherPalette.partlyCloudyNight,
    label: (l10n) => l10n.skyPartlyCloudy,
  ),
  Skycon(
    code: 'CLOUDY',
    palette: WeatherPalette.cloudy,
    label: (l10n) => l10n.skyCloudy,
  ),
  Skycon(
    code: 'LIGHT_HAZE',
    palette: WeatherPalette.lightHaze,
    label: (l10n) => l10n.skyLightHaze,
  ),
  Skycon(
    code: 'MODERATE_HAZE',
    palette: WeatherPalette.moderateHaze,
    label: (l10n) => l10n.skyHazy,
  ),
  Skycon(
    code: 'HEAVY_HAZE',
    palette: WeatherPalette.heavyHaze,
    label: (l10n) => l10n.skyHeavyHaze,
  ),
  Skycon(
    code: 'FOG',
    palette: WeatherPalette.fog,
    label: (l10n) => l10n.skyFoggy,
  ),
  Skycon(
    code: 'DUST',
    palette: WeatherPalette.dust,
    label: (l10n) => l10n.skyDusty,
  ),
  Skycon(
    code: 'SAND',
    palette: WeatherPalette.sand,
    label: (l10n) => l10n.skySandy,
  ),
  Skycon(
    code: 'WIND',
    palette: WeatherPalette.wind,
    label: (l10n) => l10n.skyWindy,
  ),
  Skycon(
    code: 'LIGHT_RAIN',
    palette: WeatherPalette.lightRain,
    label: (l10n) => l10n.skyLightRain,
  ),
  Skycon(
    code: 'MODERATE_RAIN',
    palette: WeatherPalette.rain,
    label: (l10n) => l10n.skyRain,
  ),
  Skycon(
    code: 'HEAVY_RAIN',
    palette: WeatherPalette.heavyRain,
    label: (l10n) => l10n.skyHeavyRain,
  ),
  Skycon(
    code: 'STORM_RAIN',
    palette: WeatherPalette.storm,
    label: (l10n) => l10n.skyStorm,
  ),
  Skycon(
    code: 'LIGHT_SNOW',
    palette: WeatherPalette.lightSnow,
    label: (l10n) => l10n.skyLightSnow,
  ),
  Skycon(
    code: 'MODERATE_SNOW',
    palette: WeatherPalette.snow,
    label: (l10n) => l10n.skySnow,
  ),
  Skycon(
    code: 'HEAVY_SNOW',
    palette: WeatherPalette.heavySnow,
    label: (l10n) => l10n.skyHeavySnow,
  ),
  Skycon(
    code: 'STORM_SNOW',
    palette: WeatherPalette.blizzard,
    label: (l10n) => l10n.skyBlizzard,
  ),
];

final Map<String, Skycon> _byCode = {
  for (final skycon in skyconCatalog) skycon.code: skycon,
};

/// The [Skycon] for [code], or [fallbackSkycon] when unknown.
Skycon skyconFor(String code) => _byCode[code] ?? fallbackSkycon;
