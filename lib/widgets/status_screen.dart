import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../theme/weather_palette.dart';
import 'settings_button.dart';

/// Full-screen status used while the weather is loading or after a failure.
///
/// Shows a spinner when [onRetry] is null, otherwise a message and a retry
/// action. The settings button stays available in both states.
class StatusScreen extends StatelessWidget {
  const StatusScreen({
    super.key,
    required this.message,
    required this.onOpenSettings,
    this.onRetry,
  });

  final String message;
  final VoidCallback onOpenSettings;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const palette = WeatherPalette.sky;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: palette.systemUiOverlayStyle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        color: palette.background,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 12),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SettingsButton(
                    palette: palette,
                    onOpenSettings: onOpenSettings,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onRetry == null)
                        CircularProgressIndicator(color: palette.foreground),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: palette.text(size: 18, weight: FontWeight.w700),
                        ),
                      ),
                      if (onRetry != null) ...[
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: onRetry,
                          child: Text(
                            l10n.tryAgain,
                            style: palette.text(
                              size: 16,
                              weight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
