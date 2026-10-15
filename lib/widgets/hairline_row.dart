import 'package:flutter/material.dart';

import '../theme/weather_palette.dart';

/// A list row separated from the one above by a hairline.
///
/// When [showTopBorder] is false the divider is transparent, so stacked rows
/// keep a uniform height without drawing a line above the first item.
class HairlineRow extends StatelessWidget {
  const HairlineRow({
    super.key,
    required this.palette,
    required this.child,
    this.showTopBorder = true,
    this.padding = const EdgeInsets.symmetric(vertical: 14),
  });

  final WeatherPalette palette;
  final Widget child;
  final bool showTopBorder;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: showTopBorder ? palette.hairline : Colors.transparent,
            width: 1,
          ),
        ),
      ),
      child: child,
    );
  }
}
