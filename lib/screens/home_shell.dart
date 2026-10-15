import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/caiyun_api.dart';
import '../data/city_search_api.dart';
import '../data/settings_store.dart';
import '../l10n/app_localizations.dart';
import '../l10n/weather_l10n.dart';
import '../models/settings.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/status_screen.dart';
import '../widgets/weather_bottom_nav.dart';
import 'hourly_screen.dart';
import 'search_screen.dart';
import 'today_screen.dart';
import 'weather_controller.dart';
import 'weekly_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.api,
    required this.citySearch,
    required this.store,
    required this.settings,
  });

  final CaiyunApi api;
  final CitySearchApi citySearch;
  final SettingsStore store;

  /// The user's persisted settings, used for display options.
  final Settings settings;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late final WeatherController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WeatherController(api: widget.api, store: widget.store);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Pull-to-refresh: reloads the current cities without blanking the screen,
  /// reporting failures through a SnackBar instead.
  Future<void> _refresh() async {
    final l10n = AppLocalizations.of(context);
    try {
      await _controller.refresh();
    } on Exception catch (error) {
      if (!mounted) return;
      showAppSnack(context, l10n.weatherErrorText(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => Scaffold(
        body: _content(AppLocalizations.of(context)),
      ),
    );
  }

  Widget _content(AppLocalizations l10n) {
    final error = _controller.error;
    if (error != null) {
      return StatusScreen(
        message: l10n.weatherErrorText(error),
        onRetry: _controller.load,
      );
    }
    if (_controller.loading) {
      return StatusScreen(message: l10n.loadingWeather);
    }
    return _buildWeather();
  }

  Widget _buildWeather() {
    final controller = _controller;
    final city = controller.selectedCity;
    final bundle = controller.bundles[city.id]!;

    final palette = switch (controller.tab) {
      WeatherTab.weekly => bundle.weekly.palette,
      WeatherTab.hourly => bundle.hourly.palette,
      _ => bundle.current.palette,
    };

    final body = switch (controller.tab) {
      WeatherTab.today => TodayScreen(weather: bundle.current),
      WeatherTab.weekly => WeeklyScreen(weather: bundle.weekly),
      WeatherTab.hourly => HourlyScreen(
        weather: bundle.hourly,
        use24Hour: widget.settings.use24Hour,
      ),
      WeatherTab.search => SearchScreen(
        palette: palette,
        bundles: controller.bundles,
        cities: controller.cities,
        selectedCityId: city.id,
        searchApi: widget.citySearch,
        onSelected: controller.selectCity,
        onAdd: controller.addCity,
        onRemove: controller.removeCity,
      ),
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
                  onRefresh: _refresh,
                  color: palette.background,
                  backgroundColor: palette.foreground,
                  child: KeyedSubtree(
                    key: ValueKey('${city.id}-${controller.tab}'),
                    child: body,
                  ),
                ),
              ),
              WeatherBottomNav(
                palette: palette,
                currentTab: controller.tab,
                onSelected: controller.selectTab,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
