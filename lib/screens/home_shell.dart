import 'package:flutter/material.dart';

import '../data/caiyun_api.dart';
import '../data/cities.dart';
import '../models/weather.dart';
import '../theme/weather_palette.dart';
import '../widgets/weather_bottom_nav.dart';
import 'search_screen.dart';
import 'today_screen.dart';
import 'weekly_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.api});

  final CaiyunApi api;

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

  @override
  void dispose() {
    widget.api.dispose();
    super.dispose();
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
    return Scaffold(
      body: FutureBuilder<Map<String, WeatherBundle>>(
        future: _bundles,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _StatusScreen(
              message: '${snapshot.error}',
              onRetry: _reload,
            );
          }
          if (!snapshot.hasData) {
            return const _StatusScreen(message: 'loading weather\u2026');
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
        child: Column(
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
      ),
    );
  }
}

class _StatusScreen extends StatelessWidget {
  const _StatusScreen({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    const palette = WeatherPalette.sky;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      color: palette.background,
      child: SafeArea(
        child: Center(
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
                  style: TextStyle(
                    color: palette.foreground,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onRetry,
                  child: Text(
                    'try again',
                    style: TextStyle(
                      color: palette.foreground,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
