import 'package:flutter/material.dart';

/// An integer temperature rendered with a smaller degree sign on the baseline.
///
/// Used for the hero reading, the forecast rows and the city list so the
/// number/degree layout lives in one place.
class TemperatureLabel extends StatelessWidget {
  const TemperatureLabel({
    super.key,
    required this.value,
    required this.color,
    this.fontSize = 130,
    this.degreeScale = 0.62,
    this.letterSpacing = -4,
  });

  final int value;
  final Color color;
  final double fontSize;

  /// Degree sign size relative to [fontSize].
  final double degreeScale;

  final double letterSpacing;

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
            letterSpacing: letterSpacing,
          ),
        ),
        Text(
          '\u00B0',
          style: TextStyle(
            color: color,
            fontSize: fontSize * degreeScale,
            fontWeight: FontWeight.w900,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
