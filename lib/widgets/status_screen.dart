import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'settings_button.dart';

/// Full-screen status used while the weather is loading or after a failure.
///
/// Shows a spinner when [onRetry] is null, otherwise a message and a retry
/// action. The settings button stays available in both states.
class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: appSystemUiOverlayStyle(scheme),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        color: scheme.surface,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 12),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SettingsButton(color: scheme.onSurface),
                ),
              ),
              Expanded(child: _centeredContent(l10n, scheme)),
            ],
          ),
        ),
      ),
    );
  }

  /// A spinner while loading, or the message with a retry action on failure.
  Widget _centeredContent(AppLocalizations l10n, ColorScheme scheme) {
    final isError = onRetry != null;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isError) const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (isError) _retryButton(l10n),
        ],
      ),
    );
  }

  Widget _retryButton(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextButton(
        onPressed: onRetry,
        child: Text(
          l10n.tryAgain,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
