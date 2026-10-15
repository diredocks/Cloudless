import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/weather_palette.dart';
import 'settings_scope.dart';

/// A settings button docked in a weather page's top gap.
///
/// It lives inside the page's scroll view, so it scrolls away with the
/// forecast instead of staying pinned to the screen.
class SettingsPageGap extends StatelessWidget {
  const SettingsPageGap({
    super.key,
    required this.height,
    required this.palette,
  });

  /// Height of the empty gap the button sits at the top of.
  final double height;

  final WeatherPalette palette;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // The page adds 22px of horizontal padding; pull the button back by
          // 10px so its right edge sits 12px from the screen, matching the
          // status screen's margin.
          Positioned(
            top: 8,
            right: -10,
            child: SettingsButton(palette: palette),
          ),
        ],
      ),
    );
  }
}

/// The settings entry point shown over every weather screen.
///
/// Tapping it briefly reveals the "long press" hint; a long press opens the
/// settings screen via [SettingsScope].
class SettingsButton extends StatefulWidget {
  const SettingsButton({super.key, required this.palette});

  final WeatherPalette palette;

  @override
  State<SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<SettingsButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offset;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _offset = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 1),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 24),
    ]).animate(_controller);
    _opacity = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSettingsHint() {
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final openSettings = SettingsScope.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final visible = _controller.value > 0;
            return Opacity(
              opacity: visible ? _opacity.value : 0,
              child: Transform.translate(
                offset: Offset(_offset.value, 0),
                child: child,
              ),
            );
          },
          child: Text(
            l10n.settingsHintSnack,
            style: TextStyle(color: widget.palette.foreground, fontSize: 16),
          ),
        ),
        const SizedBox(width: 4),
        InkResponse(
          radius: 28,
          onTap: _showSettingsHint,
          onLongPress: openSettings,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.settings_outlined,
              color: widget.palette.foreground,
              size: 26,
            ),
          ),
        ),
      ],
    );
  }
}
