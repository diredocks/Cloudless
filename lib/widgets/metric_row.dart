import 'package:flutter/material.dart';

import '../theme/weather_palette.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: showTopBorder
                ? palette.hairline
                : Colors.transparent,
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
                  label,
                  style: TextStyle(
                    color: palette.foreground,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: palette.foreground,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Text(
            descriptor,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: palette.foreground,
              fontSize: 40,
              fontWeight: FontWeight.w900,
              height: 1.0,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }
}

class BigTemperature extends StatelessWidget {
  const BigTemperature({
    super.key,
    required this.value,
    required this.color,
    this.fontSize = 130,
  });

  final int value;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            height: 1.0,
            letterSpacing: -4,
          ),
        ),
        Text(
          '\u00B0',
          style: TextStyle(
            color: color,
            fontSize: fontSize * 0.62,
            fontWeight: FontWeight.w900,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
