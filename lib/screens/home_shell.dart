import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../l10n/weather_l10n.dart';
import '../models/weather_tab.dart';
import '../providers/services.dart';
import '../providers/weather_controller.dart';
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
    return Scaffold(
      body: ref
          .watch(weatherControllerProvider)
          .when(
            loading: () => StatusScreen(message: l10n.loadingWeather),
            error: (error, _) => StatusScreen(
              message: l10n.weatherErrorText(error),
              onRetry: () => ref.invalidate(weatherControllerProvider),
            ),
            data: (session) => _WeatherView(session: session),
          ),
    );
  }
}

class _WeatherView extends ConsumerWidget {
  const _WeatherView({required this.session});

  final WeatherState session;

  /// Pull-to-refresh: reloads the current cities without blanking the screen,
  /// reporting failures through a SnackBar instead.
  Future<void> _refresh(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(weatherControllerProvider.notifier).refresh();
    } on Exception catch (error) {
      if (!context.mounted) return;
      showAppSnack(context, l10n.weatherErrorText(error));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final use24Hour = ref.watch(
      settingsProvider.select((settings) => settings.use24Hour),
    );
    final city = session.selectedCity;
    final bundle = session.bundles[city.id]!;

    final palette = switch (session.tab) {
      WeatherTab.weekly => bundle.weekly.palette,
      WeatherTab.hourly => bundle.hourly.palette,
      _ => bundle.current.palette,
    };

    final body = switch (session.tab) {
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
                    key: ValueKey('${city.id}-${session.tab}'),
                    child: body,
                  ),
                ),
              ),
              WeatherBottomNav(
                palette: palette,
                currentTab: session.tab,
                onSelected: (tab) =>
                    ref.read(weatherControllerProvider.notifier).selectTab(tab),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
