import 'package:flutter/material.dart';

class WeatherPalette {
  const WeatherPalette({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;

  Color get subtle => foreground.withValues(alpha: 0.65);
  Color get hairline => foreground.withValues(alpha: 0.55);

  static const orange = WeatherPalette(
    background: Color(0xFFE1541D),
    foreground: Color(0xFFFBEFCE),
  );

  static const forest = WeatherPalette(
    background: Color(0xFF0A4A17),
    foreground: Color(0xFFC7F0BF),
  );

  static const mint = WeatherPalette(
    background: Color(0xFFC9EFA6),
    foreground: Color(0xFF0A4A17),
  );

  static const navy = WeatherPalette(
    background: Color(0xFF202A5C),
    foreground: Color(0xFFFBE9E0),
  );

  static const sky = WeatherPalette(
    background: Color(0xFFCDE7F6),
    foreground: Color(0xFF1B1B5E),
  );

  static const blue = WeatherPalette(
    background: Color(0xFF2F7BF6),
    foreground: Color(0xFFCFE7F5),
  );
}
