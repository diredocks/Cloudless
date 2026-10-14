import 'package:flutter/material.dart';

class WeatherPalette {
  const WeatherPalette({required this.background, required this.foreground});

  final Color background;
  final Color foreground;

  /// Hairline color for row dividers and field underlines.
  Color get hairline => foreground.withValues(alpha: 0.55);

  /// Muted foreground used for secondary text.
  Color get muted => foreground.withValues(alpha: 0.6);

  /// A foreground-colored [TextStyle], so screens do not repeat the color.
  TextStyle text({
    double? size,
    FontWeight? weight,
    double? height,
    double? letterSpacing,
    Color? color,
  }) => TextStyle(
    color: color ?? foreground,
    fontSize: size,
    fontWeight: weight,
    height: height,
    letterSpacing: letterSpacing,
  );

  static const orange = WeatherPalette(
    background: Color(0xFFE1541D),
    foreground: Color(0xFFFBEFCE),
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
