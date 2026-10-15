import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../l10n/weather_l10n.dart';
import '../models/weather.dart';
import '../models/weather_tab.dart';
import '../providers/settings.dart';
import '../providers/weather.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/status_screen.dart';
import '../widgets/weather_bottom_nav.dart';
import 'hourly_screen.dart';
import 'search_screen.dart';
import 'today_screen.dart';
import 'weekly_screen.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final city = ref.watch(selectedCityProvider);

    return Scaffold(
      body: ref
          .watch(weatherBundleProvider(city))
          .when(
            loading: () => StatusScreen(message: l10n.loadingWeather),
            error: (error, _) => StatusScreen(
              message: l10n.weatherErrorText(error),
              onRetry: () => ref.invalidate(weatherBundleProvider(city)),
            ),
            data: (bundle) => _WeatherView(city: city, bundle: bundle),
          ),
    );
  }
}

class _WeatherView extends ConsumerWidget {
  const _WeatherView({required this.city, required this.bundle});

  final CityLocation city;
  final WeatherBundle bundle;

  /// Pull-to-refresh: reloads every saved city without blanking the screen,
  /// reporting failures through a SnackBar instead.
  Future<void> _refresh(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final cities = ref.read(appCitiesProvider);
    try {
      for (final city in cities) {
        ref.invalidate(weatherBundleProvider(city));
      }
      await Future.wait([
        for (final city in cities) ref.read(weatherBundleProvider(city).future),
      ]);
    } on Exception catch (error) {
      if (!context.mounted) return;
      showAppSnack(context, l10n.weatherErrorText(error));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(weatherTabProvider);
    final use24Hour = ref.watch(
      settingsProvider.select((settings) => settings.use24Hour),
    );

    final palette = switch (tab) {
      WeatherTab.weekly => bundle.weekly.palette,
      WeatherTab.hourly => bundle.hourly.palette,
      _ => bundle.current.palette,
    };

    final body = switch (tab) {
      WeatherTab.today => TodayScreen(weather: bundle.current),
      WeatherTab.weekly => WeeklyScreen(weather: bundle.weekly),
      WeatherTab.hourly => HourlyScreen(
        weather: bundle.hourly,
        use24Hour: use24Hour,
      ),
      WeatherTab.search => SearchScreen(palette: palette),
    };

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: palette.systemUiOverlayStyle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        color: palette.background,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _refresh(context, ref),
                  color: palette.background,
                  backgroundColor: palette.foreground,
                  child: KeyedSubtree(
                    key: ValueKey('${city.id}-$tab'),
                    child: body,
                  ),
                ),
              ),
              WeatherBottomNav(
                palette: palette,
                currentTab: tab,
                onSelected: (tab) =>
                    ref.read(weatherTabProvider.notifier).select(tab),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
