import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Seed used for the fallback scheme on platforms without system (Material
/// You) colors, e.g. desktop or Android below 12.
const _fallbackSeedColor = Color(0xFF202A5C);

/// Seeds a [ColorScheme] from the system's dynamic (Material You) accent
/// [seedColor], falling back to the brand seed when [seedColor] is null (e.g.
/// desktop or Android below 12).
ColorScheme schemeFromSeed(Color? seedColor, Brightness brightness) =>
    ColorScheme.fromSeed(
      seedColor: seedColor ?? _fallbackSeedColor,
      brightness: brightness,
    );

/// Builds the app-wide Material 3 theme from [scheme].
///
/// Everything that does not carry a weather (business) palette - the settings
/// screen, status screens, dialogs, snack bars and standard controls - draws
/// its colors from here. [scheme] is usually the system's Material You palette,
/// so that UI follows the system theme automatically.
ThemeData buildAppTheme(ColorScheme scheme) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    splashFactory: NoSplash.splashFactory,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      systemOverlayStyle: appSystemUiOverlayStyle(scheme),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: const UnderlineInputBorder(),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
    ),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(
          fallbackColor: scheme.surface,
        ),
      },
    ),
  );
}

/// Status bar style matching the theme's [ColorScheme.surface], so the system
/// chrome blends into the screen instead of falling back to the light default.
SystemUiOverlayStyle appSystemUiOverlayStyle(ColorScheme scheme) {
  final isLight = scheme.surface.computeLuminance() > 0.5;
  return SystemUiOverlayStyle(
    statusBarColor: scheme.surface,
    statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
    statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
  );
}
