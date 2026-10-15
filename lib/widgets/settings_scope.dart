import 'package:flutter/widgets.dart';

/// Exposes the app's "open settings" action to descendants.
///
/// The settings button lives inside each weather page's scroll view, so an
/// [InheritedWidget] keeps the callback out of every page's constructor.
class SettingsScope extends InheritedWidget {
  const SettingsScope({
    super.key,
    required this.openSettings,
    required super.child,
  });

  final VoidCallback openSettings;

  static VoidCallback of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SettingsScope>();
    assert(scope != null, 'No SettingsScope found in context');
    return scope!.openSettings;
  }

  @override
  bool updateShouldNotify(SettingsScope oldWidget) =>
      openSettings != oldWidget.openSettings;
}
