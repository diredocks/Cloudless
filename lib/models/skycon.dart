import '../l10n/app_localizations.dart';
import '../theme/weather_palette.dart';

/// A Caiyun sky condition with its display palette and localized label.
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
