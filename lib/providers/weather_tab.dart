import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The top-level weather views selectable from the bottom navigation.
enum WeatherTab { today, search, weekly, hourly }

/// The active weather tab. Ephemeral UI state, reset to today on each launch.
final weatherTabProvider = NotifierProvider<WeatherTabNotifier, WeatherTab>(
  WeatherTabNotifier.new,
);

class WeatherTabNotifier extends Notifier<WeatherTab> {
  @override
  WeatherTab build() => WeatherTab.today;

  void select(WeatherTab tab) => state = tab;
}
