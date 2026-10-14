import 'package:flutter/material.dart';

import '../data/caiyun_api.dart';
import '../data/cities.dart';
import '../l10n/app_localizations.dart';
import '../l10n/weather_l10n.dart';
import '../models/weather.dart';
import '../theme/weather_palette.dart';
import '../widgets/weather_bottom_nav.dart';
import 'search_screen.dart';
import 'today_screen.dart';
import 'weekly_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.api, required this.onOpenSettings});

  final CaiyunApi api;
  final VoidCallback onOpenSettings;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _cityIndex = 0;
  WeatherTab _tab = WeatherTab.today;
  late Future<Map<String, WeatherBundle>> _bundles;

  @override
  void initState() {
    super.initState();
    _bundles = _loadAll();
  }

  Future<Map<String, WeatherBundle>> _loadAll() async {
    final entries = await Future.wait(
      cityCatalog.map(
        (city) async => MapEntry(city.id, await widget.api.fetch(city)),
      ),
    );
    return Map.fromEntries(entries);
  }

  void _reload() {
    setState(() => _bundles = _loadAll());
  }

  void _selectCity(CityLocation city) {
    setState(() {
      _cityIndex = cityCatalog.indexOf(city);
      _tab = WeatherTab.today;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: FutureBuilder<Map<String, WeatherBundle>>(
        future: _bundles,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            final error = snapshot.error;
            return _StatusScreen(
              message: error is WeatherApiException
                  ? l10n.weatherError(error)
                  : '$error',
              onRetry: _reload,
              onOpenSettings: widget.onOpenSettings,
            );
          }
          if (!snapshot.hasData) {
            return _StatusScreen(
              message: l10n.loadingWeather,
              onOpenSettings: widget.onOpenSettings,
            );
          }
          return _buildWeather(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildWeather(Map<String, WeatherBundle> bundles) {
    final city = cityCatalog[_cityIndex];
    final bundle = bundles[city.id]!;

    final palette = switch (_tab) {
      WeatherTab.weekly => bundle.weekly.palette,
      _ => bundle.current.palette,
    };

    final body = switch (_tab) {
      WeatherTab.today => TodayScreen(weather: bundle.current),
      WeatherTab.weekly => WeeklyScreen(weather: bundle.weekly),
      WeatherTab.search => SearchScreen(
        palette: palette,
        bundles: bundles,
        selectedCityId: city.id,
        onSelected: _selectCity,
      ),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      color: palette.background,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: KeyedSubtree(
                    key: ValueKey('$_cityIndex-$_tab'),
                    child: body,
                  ),
                ),
                WeatherBottomNav(
                  palette: palette,
                  currentTab: _tab,
                  onSelected: (tab) => setState(() => _tab = tab),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 12,
              child: _SettingsButton(
                palette: palette,
                onOpenSettings: widget.onOpenSettings,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton({required this.palette, required this.onOpenSettings});

  final WeatherPalette palette;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InkResponse(
      radius: 28,
      onTap: () {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(l10n.settingsHintSnack),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
      },
      onLongPress: onOpenSettings,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          Icons.settings_outlined,
          color: palette.foreground,
          size: 26,
        ),
      ),
    );
  }
}

class _StatusScreen extends StatelessWidget {
  const _StatusScreen({
    required this.message,
    required this.onOpenSettings,
    this.onRetry,
  });

  final String message;
  final VoidCallback onOpenSettings;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const palette = WeatherPalette.sky;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      color: palette.background,
      child: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onRetry == null)
                    CircularProgressIndicator(color: palette.foreground),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: palette.text(size: 18, weight: FontWeight.w700),
                    ),
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: onRetry,
                      child: Text(
                        l10n.tryAgain,
                        style: palette.text(size: 16, weight: FontWeight.w800),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 12,
              child: _SettingsButton(
                palette: palette,
                onOpenSettings: onOpenSettings,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
