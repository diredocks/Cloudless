import 'package:flutter/material.dart';

import '../models/weather.dart';
import '../widgets/metric_row.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, required this.weather});

  final CurrentWeather weather;

  @override
  Widget build(BuildContext context) {
    final palette = weather.palette;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: constraints.maxHeight * 0.14),
                    Text(
                      weather.location,
                      style: TextStyle(
                        color: palette.foreground,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    BigTemperature(
                      value: weather.temperature,
                      color: palette.foreground,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      weather.summary,
                      style: TextStyle(
                        color: palette.foreground,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        height: 1.08,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Spacer(),
                    MetricRow(
                      label: 'feels like',
                      value: weather.feelsLikeValue,
                      descriptor: weather.feelsLikeLabel,
                      palette: palette,
                    ),
                    MetricRow(
                      label: 'wind',
                      value: weather.windValue,
                      descriptor: weather.windLabel,
                      palette: palette,
                    ),
                    MetricRow(
                      label: 'uv index',
                      value: weather.uvValue,
                      descriptor: weather.uvLabel,
                      palette: palette,
                    ),
                    MetricRow(
                      label: 'rain',
                      value: weather.rainValue,
                      descriptor: weather.rainLabel,
                      palette: palette,
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
