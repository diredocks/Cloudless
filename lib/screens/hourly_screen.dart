import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/weather_l10n.dart';
import '../models/weather.dart';
import '../theme/weather_palette.dart';
import '../widgets/hairline_row.dart';
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
        _HourRow(
          forecast: hour,
          palette: palette,
          use24Hour: use24Hour,
          showTopBorder: i == 0,
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

class _HourRow extends StatelessWidget {
  const _HourRow({
    required this.forecast,
    required this.palette,
    required this.use24Hour,
    required this.showTopBorder,
  });

  final HourlyForecast forecast;
  final WeatherPalette palette;
  final bool use24Hour;
  final bool showTopBorder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return HairlineRow(
      palette: palette,
      showTopBorder: showTopBorder,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.hourLabel(forecast.datetime, use24Hour: use24Hour),
                  style: palette.text(
                    size: 22,
                    weight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
                Text(
                  l10n.skyconLabel(forecast.skycon),
                  style: palette.text(
                    size: 30,
                    weight: FontWeight.w900,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          TemperatureLabel(
            value: forecast.temperature,
            color: palette.foreground,
            fontSize: 46,
            degreeScale: 32 / 46,
            letterSpacing: -2,
          ),
        ],
      ),
    );
  }
}
