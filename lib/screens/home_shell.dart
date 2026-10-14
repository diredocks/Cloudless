import 'package:flutter/material.dart';

import '../data/caiyun_api.dart';
import '../data/cities.dart';
import '../data/city_search_api.dart';
import '../data/settings_store.dart';
import '../l10n/app_localizations.dart';
import '../l10n/weather_l10n.dart';
import '../models/weather.dart';
import '../theme/weather_palette.dart';
import '../widgets/weather_bottom_nav.dart';
import 'search_screen.dart';
import 'today_screen.dart';
import 'weekly_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.api,
    required this.citySearch,
    required this.store,
    required this.onOpenSettings,
  });

  final CaiyunApi api;
  final CitySearchApi citySearch;
  final SettingsStore store;
  final VoidCallback onOpenSettings;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late List<CityLocation> _cities;
  late String _selectedCityId;
  WeatherTab _tab = WeatherTab.today;
  final Map<String, WeatherBundle> _bundles = {};
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    final saved = widget.store.cities;
    _cities = saved.isNotEmpty ? List.of(saved) : List.of(cityCatalog);
    final savedId = widget.store.selectedCityId;
    _selectedCityId = _cities.any((c) => c.id == savedId)
        ? savedId!
        : _cities.first.id;
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final entries = await Future.wait(
        _cities.map(
          (city) async => MapEntry(city.id, await widget.api.fetch(city)),
        ),
      );
      if (!mounted) return;
      setState(() {
        _bundles
          ..clear()
          ..addEntries(entries);
        _loading = false;
      });
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  void _selectCity(CityLocation city) {
    setState(() {
      _selectedCityId = city.id;
      _tab = WeatherTab.today;
    });
    widget.store.setSelectedCityId(city.id);
  }

  Future<bool> _addCity(CityLocation city) async {
    if (_cities.any((c) => c.id == city.id)) {
      _selectCity(city);
      return true;
    }

    final WeatherBundle bundle;
    try {
      bundle = await widget.api.fetch(city);
    } on Exception {
      return false;
    }
    if (!mounted) return false;

    setState(() {
      _cities = [..._cities, city];
      _bundles[city.id] = bundle;
    });
    await widget.store.setCities(_cities);
    return true;
  }

  void _removeCity(CityLocation city) {
    if (_cities.length <= 1) return;
    setState(() {
      _cities = _cities.where((c) => c.id != city.id).toList();
      _bundles.remove(city.id);
      if (_selectedCityId == city.id) {
        _selectedCityId = _cities.first.id;
      }
    });
    widget.store.setCities(_cities);
    widget.store.setSelectedCityId(_selectedCityId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final error = _error;

    final Widget content;
    if (error != null) {
      content = _StatusScreen(
        message: error is WeatherApiException
            ? l10n.weatherError(error)
            : '$error',
        onRetry: _loadAll,
        onOpenSettings: widget.onOpenSettings,
      );
    } else if (_loading) {
      content = _StatusScreen(
        message: l10n.loadingWeather,
        onOpenSettings: widget.onOpenSettings,
      );
    } else {
      content = _buildWeather();
    }

    return Scaffold(body: content);
  }

  Widget _buildWeather() {
    final city = _cities.firstWhere(
      (c) => c.id == _selectedCityId,
      orElse: () => _cities.first,
    );
    final bundle = _bundles[city.id]!;

    final palette = switch (_tab) {
      WeatherTab.weekly => bundle.weekly.palette,
      _ => bundle.current.palette,
    };

    final body = switch (_tab) {
      WeatherTab.today => TodayScreen(weather: bundle.current),
      WeatherTab.weekly => WeeklyScreen(weather: bundle.weekly),
      WeatherTab.search => SearchScreen(
        palette: palette,
        bundles: _bundles,
        cities: _cities,
        selectedCityId: city.id,
        searchApi: widget.citySearch,
        onSelected: _selectCity,
        onAdd: _addCity,
        onRemove: _removeCity,
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
                    key: ValueKey('${city.id}-$_tab'),
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
