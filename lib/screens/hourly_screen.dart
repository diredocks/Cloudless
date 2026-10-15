import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/weather_l10n.dart';
import '../models/forecasts.dart';
import '../theme/weather_palette.dart';
import '../widgets/forecast_row.dart';
import '../widgets/temperature_label.dart';
import '../widgets/weather_page.dart';

class HourlyScreen extends StatelessWidget {
  const HourlyScreen({
    super.key,
    required this.weather,
    required this.use24Hour,
  });

  final HourlyWeather weather;

  /// Whether hourly labels use a 24-hour clock.
  final bool use24Hour;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = weather.palette;
    final rows = <Widget>[];
    for (var i = 0; i < weather.hours.length; i++) {
      final hour = weather.hours[i];
      if (i > 0 &&
          _dayOf(hour.datetime) != _dayOf(weather.hours[i - 1].datetime)) {
        rows.add(_DayDivider(palette: palette));
      }
      rows.add(
        ForecastRow(
          title: l10n.hourLabel(hour.datetime, use24Hour: use24Hour),
          subtitle: l10n.skyconLabel(hour.skycon),
          palette: palette,
          showTopBorder: i == 0,
          trailing: TemperatureLabel(
            value: hour.temperature,
            color: palette.foreground,
            fontSize: 46,
            degreeScale: 32 / 46,
            letterSpacing: -2,
          ),
        ),
      );
    }

    return WeatherPage(
      topGap: 0.12,
      palette: palette,
      children: (maxHeight) => [
        Text(
          l10n.cityName(weather.city),
          style: palette.text(
            size: 26,
            weight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.hourlyForecastSummary(weather.dominantSkycon),
          style: palette.text(
            size: 44,
            weight: FontWeight.w800,
            height: 1.05,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 40),
        ...rows,
        const SizedBox(height: 8),
      ],
    );
  }

  /// Calendar day (`yyyy-MM-dd`) of an ISO-8601 timestamp.
  static String _dayOf(String isoDateTime) =>
      isoDateTime.length >= 10 ? isoDateTime.substring(0, 10) : isoDateTime;
}

/// Separates the hourly rows of two different days with a hairline.
class _DayDivider extends StatelessWidget {
  const _DayDivider({required this.palette});

  final WeatherPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(height: 1, thickness: 1, color: palette.hairline),
    );
  }
}
