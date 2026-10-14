import 'package:flutter/material.dart';

import '../models/weather.dart';
import '../theme/weather_palette.dart';

class WeeklyScreen extends StatelessWidget {
  const WeeklyScreen({super.key, required this.weather});

  final WeeklyWeather weather;

  @override
  Widget build(BuildContext context) {
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
                    weather.location,
                    style: TextStyle(
                      color: palette.foreground,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    weather.summary,
                    style: TextStyle(
                      color: palette.foreground,
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
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
                  forecast.day,
                  style: TextStyle(
                    color: palette.foreground,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
                Text(
                  forecast.condition,
                  style: TextStyle(
                    color: palette.foreground,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          _TempLabel(
            temperature: forecast.temperature,
            color: palette.foreground,
          ),
        ],
      ),
    );
  }
}

class _TempLabel extends StatelessWidget {
  const _TempLabel({required this.temperature, required this.color});

  final int temperature;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '$temperature',
          style: TextStyle(
            color: color,
            fontSize: 46,
            fontWeight: FontWeight.w900,
            height: 1.0,
            letterSpacing: -2,
          ),
        ),
        Text(
          '\u00B0',
          style: TextStyle(
            color: color,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
