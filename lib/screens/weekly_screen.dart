import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/weather_l10n.dart';
import '../models/weather.dart';
import '../theme/weather_palette.dart';
import '../widgets/temperature_label.dart';

class WeeklyScreen extends StatelessWidget {
  const WeeklyScreen({super.key, required this.weather});

  final WeeklyWeather weather;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = weather.palette;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: constraints.maxHeight * 0.12),
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
                    l10n.weeklyForecastSummary(weather.dominantSkycon),
                    style: palette.text(
                      size: 44,
                      weight: FontWeight.w800,
                      height: 1.05,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 40),
                  for (var i = 0; i < weather.days.length; i++)
                    _WeekRow(
                      forecast: weather.days[i],
                      palette: palette,
                      showTopBorder: i == 0,
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WeekRow extends StatelessWidget {
  const _WeekRow({
    required this.forecast,
    required this.palette,
    required this.showTopBorder,
  });

  final DailyForecast forecast;
  final WeatherPalette palette;
  final bool showTopBorder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: showTopBorder ? palette.hairline : Colors.transparent,
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.weekdayName(forecast.date),
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
