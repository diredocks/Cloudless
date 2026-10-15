import 'package:flutter/material.dart';

import '../theme/weather_palette.dart';
import 'hairline_row.dart';

class MetricRow extends StatelessWidget {
  const MetricRow({
    super.key,
    required this.label,
    required this.value,
    required this.descriptor,
    required this.palette,
    this.showTopBorder = true,
  });

  final String label;
  final String value;
  final String descriptor;
  final WeatherPalette palette;
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
                  label,
                  style: palette.text(
                    size: 17,
                    weight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: palette.text(
                    size: 21,
                    weight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Text(
            descriptor,
            textAlign: TextAlign.right,
            style: palette.text(
              size: 40,
              weight: FontWeight.w900,
              height: 1.0,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }
}
