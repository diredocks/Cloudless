import 'package:flutter/material.dart';

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
  });

  final List<Widget> Function(double maxHeight) children;
  final bool intrinsicHeight;

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
    final column = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children(maxHeight),
      ),
    );
    return intrinsicHeight ? IntrinsicHeight(child: column) : column;
  }
}
