import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/weather_l10n.dart';
import '../models/forecasts.dart';
import '../widgets/forecast_row.dart';
import '../widgets/temperature_label.dart';
import '../widgets/weather_page.dart';

class WeeklyScreen extends StatelessWidget {
  const WeeklyScreen({super.key, required this.weather});

  final WeeklyWeather weather;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = weather.palette;
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
          ForecastRow(
            title: l10n.weekdayName(weather.days[i].date),
            subtitle: l10n.skyconLabel(weather.days[i].skycon),
            palette: palette,
            showTopBorder: i == 0,
            trailing: TemperatureLabel(
              value: weather.days[i].temperature,
              color: palette.foreground,
              fontSize: 46,
              degreeScale: 32 / 46,
              letterSpacing: -2,
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}
