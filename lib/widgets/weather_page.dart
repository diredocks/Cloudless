import 'package:flutter/material.dart';

import '../theme/weather_palette.dart';
import 'settings_button.dart';

/// Shared page skeleton for the weather tabs.
///
/// Lays out [children] in the app's padded, left-aligned column inside a
/// scroll view that always accepts a pull-to-refresh drag, even when the
/// content is shorter than the viewport. [children] receives the available
/// height so pages can size their top spacing proportionally. Set
/// [intrinsicHeight] when a child uses [Spacer] and therefore needs a bounded
/// height.
class WeatherPage extends StatelessWidget {
  const WeatherPage({
    super.key,
    required this.children,
    this.intrinsicHeight = false,
    this.topGap,
    this.palette,
  }) : assert(
         topGap == null || palette != null,
         'A palette is required to render the top settings gap.',
       );

  final List<Widget> Function(double maxHeight) children;
  final bool intrinsicHeight;

  /// Fraction of the viewport height reserved above the content for the
  /// settings button. When set, [palette] must also be provided.
  final double? topGap;

  /// Palette used by the settings button in the top gap.
  final WeatherPalette? palette;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: _padded(constraints.maxHeight),
          ),
        );
      },
    );
  }

  Widget _padded(double maxHeight) {
    final gap = topGap;
    final column = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (gap != null)
            SettingsPageGap(
              height: maxHeight * gap,
              color: palette!.foreground,
            ),
          ...children(maxHeight),
        ],
      ),
    );
    return intrinsicHeight ? IntrinsicHeight(child: column) : column;
  }
}
