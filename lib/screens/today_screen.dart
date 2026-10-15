import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/weather_l10n.dart';
import '../models/current_weather.dart';
import '../widgets/metric_row.dart';
import '../widgets/temperature_label.dart';
import '../widgets/weather_page.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, required this.weather});

  final CurrentWeather weather;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = weather.palette;
    return WeatherPage(
      intrinsicHeight: true,
      topGap: 0.14,
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
        const SizedBox(height: 6),
        TemperatureLabel(value: weather.temperature, color: palette.foreground),
        const SizedBox(height: 18),
        Text(
          l10n.currentSummary(weather),
          style: palette.text(
            size: 36,
            weight: FontWeight.w800,
            height: 1.08,
            letterSpacing: -0.5,
          ),
        ),
        const Spacer(),
        MetricRow(
          label: l10n.metricFeelsLike,
          value: '${weather.feelsLike}\u00B0',
          descriptor: l10n.comfortLabel(weather.comfortDesc),
          palette: palette,
        ),
        MetricRow(
          label: l10n.metricWind,
          value: '${weather.windSpeed} km/h',
          descriptor: l10n.windLabel(weather.windSpeed),
          palette: palette,
        ),
        MetricRow(
          label: l10n.metricUv,
          value: '${weather.uvIndex}',
          descriptor: l10n.uvLabel(weather.uvDesc),
          palette: palette,
        ),
        MetricRow(
          label: l10n.metricRain,
          value: '${weather.rainProbability}%',
          descriptor: l10n.rainLabel(
            weather.rainIntensity,
            weather.rainProbability,
          ),
          palette: palette,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
