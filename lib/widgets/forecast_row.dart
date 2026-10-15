import 'package:flutter/material.dart';

import '../theme/weather_palette.dart';
import 'hairline_row.dart';

/// A forecast list row: a two-line label on the left and a trailing value
/// (usually a [TemperatureLabel]) on the right.
class ForecastRow extends StatelessWidget {
  const ForecastRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.palette,
    required this.trailing,
    this.showTopBorder = true,
  });

  final String title;
  final String subtitle;
  final WeatherPalette palette;
  final Widget trailing;
  final bool showTopBorder;

  @override
  Widget build(BuildContext context) {
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
                  title,
                  style: palette.text(
                    size: 22,
                    weight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
                Text(
                  subtitle,
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
          trailing,
        ],
      ),
    );
  }
}
