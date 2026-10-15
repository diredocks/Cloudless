import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WeatherPalette {
  const WeatherPalette({required this.background, required this.foreground});

  final Color background;
  final Color foreground;

  /// Hairline color for row dividers and field underlines.
  Color get hairline => foreground.withValues(alpha: 0.55);

  /// Android status bar style matching [background], so it blends into the
  /// screen instead of falling back to the system's light default.
  SystemUiOverlayStyle get systemUiOverlayStyle {
    final isLight = background.computeLuminance() > 0.5;
    return SystemUiOverlayStyle(
      statusBarColor: background,
      statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
      statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
    );
  }

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

  /// Neutral background used before data loads and for unknown conditions.
  static const sky = WeatherPalette(
    background: Color(0xFFCDE7F6),
    foreground: Color(0xFF1B1B5E),
  );

  // --- Weather conditions -------------------------------------------------
  // One palette per Caiyun sky condition, keyed in `skycons.dart`.

  static const sunny = WeatherPalette(
    background: Color(0xFFE1541D),
    foreground: Color(0xFFFBEFCE),
  );

  static const clearNight = WeatherPalette(
    background: Color(0xFF17204D),
    foreground: Color(0xFFDCE3FF),
  );

  static const partlyCloudyDay = WeatherPalette(
    background: Color(0xFF4A90D9),
    foreground: Color(0xFFEAF4FF),
  );

  static const partlyCloudyNight = WeatherPalette(
    background: Color(0xFF2A2F6E),
    foreground: Color(0xFFE0E4FF),
  );

  static const cloudy = WeatherPalette(
    background: Color(0xFF5F7189),
    foreground: Color(0xFFEEF3F9),
  );

  static const lightHaze = WeatherPalette(
    background: Color(0xFFC08A3E),
    foreground: Color(0xFFFFF3DC),
  );

  static const moderateHaze = WeatherPalette(
    background: Color(0xFFA46E28),
    foreground: Color(0xFFFDEBD0),
  );

  static const heavyHaze = WeatherPalette(
    background: Color(0xFF7C4E1E),
    foreground: Color(0xFFF7DFC0),
  );

  static const fog = WeatherPalette(
    background: Color(0xFF8E9BA8),
    foreground: Color(0xFFF3F6FA),
  );

  static const dust = WeatherPalette(
    background: Color(0xFFA6825A),
    foreground: Color(0xFFFDF0DF),
  );

  static const sand = WeatherPalette(
    background: Color(0xFFB58C34),
    foreground: Color(0xFFFFF6DE),
  );

  static const wind = WeatherPalette(
    background: Color(0xFF2FA3A0),
    foreground: Color(0xFFE1FBFA),
  );

  static const lightRain = WeatherPalette(
    background: Color(0xFF5AA6D8),
    foreground: Color(0xFFEAF5FF),
  );

  static const rain = WeatherPalette(
    background: Color(0xFF3478B8),
    foreground: Color(0xFFE4F0FF),
  );

  static const heavyRain = WeatherPalette(
    background: Color(0xFF1F5590),
    foreground: Color(0xFFDBE8FA),
  );

  static const storm = WeatherPalette(
    background: Color(0xFF322A5A),
    foreground: Color(0xFFE7E2FF),
  );

  static const lightSnow = WeatherPalette(
    background: Color(0xFFB9D6F0),
    foreground: Color(0xFF10304F),
  );

  static const snow = WeatherPalette(
    background: Color(0xFF8FBEE4),
    foreground: Color(0xFF0D2B47),
  );

  static const heavySnow = WeatherPalette(
    background: Color(0xFF4E86BC),
    foreground: Color(0xFFF0F8FF),
  );

  static const blizzard = WeatherPalette(
    background: Color(0xFF33587F),
    foreground: Color(0xFFEAF4FF),
  );
}
