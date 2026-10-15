import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../l10n/weather_l10n.dart';
import '../models/city.dart';
import '../providers/cities.dart';
import '../providers/city_search.dart';
import '../providers/settings.dart';
import '../providers/weather.dart';
import '../providers/weather_tab.dart';
import '../theme/weather_palette.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/hairline_row.dart';
import '../widgets/temperature_label.dart';
import '../widgets/weather_page.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, required this.palette});

  final WeatherPalette palette;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';
  String? _addingId;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isSaved(List<CityLocation> cities, CityLocation city) =>
      cities.any((c) => c.id == city.id);

  /// Temperature for [city] when it is already saved (and therefore fetched),
  /// otherwise null.
  int? _temperature(List<CityLocation> cities, CityLocation city) {
    if (!_isSaved(cities, city)) return null;
    return ref.watch(weatherBundleProvider(city)).value?.current.temperature;
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
  }

  Future<void> _add(CityLocation city) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _addingId = city.id);

    // Validate by fetching the city's weather before saving it.
    var ok = true;
    try {
      await ref.read(weatherBundleProvider(city).future);
    } on Exception {
      ok = false;
    }
    if (!mounted) return;

    if (!ok) {
      setState(() => _addingId = null);
      showAppSnack(context, l10n.cityAddFailed);
      return;
    }

    await ref.read(settingsProvider.notifier).addCity(city);
    if (!mounted) return;

    // Reset the search so the newly saved city shows in the list.
    _controller.clear();
    setState(() {
      _addingId = null;
      _query = '';
    });
  }

  Future<void> _confirmRemove(CityLocation city, int cityCount) async {
    final l10n = AppLocalizations.of(context);
    if (cityCount <= 1) {
      showAppSnack(context, l10n.keepOneCity);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCityTitle),
        content: Text(l10n.deleteCityMessage(l10n.cityName(city))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(settingsProvider.notifier).removeCity(city);
  }

  void _openCity(List<CityLocation> cities, CityLocation city) {
    if (!_isSaved(cities, city)) {
      _add(city);
      return;
    }
    _selectCity(city);
  }

  /// Selects [city] and returns to today, matching the picker flow.
  void _selectCity(CityLocation city) {
    ref.read(settingsProvider.notifier).selectCity(city);
    ref.read(weatherTabProvider.notifier).select(WeatherTab.today);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = widget.palette;
    final cities = ref.watch(appCitiesProvider);
    final selectedCityId = ref.watch(
      settingsProvider.select((settings) => settings.selectedCityId),
    );
    final query = _query.trim();
    final results = ref.watch(citySearchResultsProvider(_query));

    return WeatherPage(
      topGap: 0.10,
      palette: palette,
      children: (maxHeight) => [
        _searchField(l10n, palette),
        const SizedBox(height: 20),
        if (query.isEmpty)
          ..._savedRows(palette, cities, selectedCityId)
        else
          ..._resultRows(l10n, palette, cities, selectedCityId, results),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _searchField(AppLocalizations l10n, WeatherPalette palette) {
    return TextField(
      controller: _controller,
      onChanged: _onQueryChanged,
      cursorColor: palette.foreground,
      style: palette.text(size: 28, weight: FontWeight.w800),
      decoration: InputDecoration(
        hintText: l10n.searchCityHint,
        hintStyle: palette.text(
          size: 28,
          weight: FontWeight.w800,
          color: palette.muted,
        ),
        prefixIcon: Icon(Icons.search, color: palette.foreground, size: 30),
        prefixIconConstraints: const BoxConstraints(minWidth: 44),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: palette.hairline, width: 1),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: palette.foreground, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  List<Widget> _savedRows(
    WeatherPalette palette,
    List<CityLocation> cities,
    String? selectedCityId,
  ) {
    return [
      for (var i = 0; i < cities.length; i++)
        _CityRow(
          city: cities[i],
          temperature: _temperature(cities, cities[i]),
          palette: palette,
          selected: cities[i].id == selectedCityId,
          showTopBorder: i != 0,
          onTap: () => _selectCity(cities[i]),
          onLongPress: () => _confirmRemove(cities[i], cities.length),
        ),
    ];
  }

  List<Widget> _resultRows(
    AppLocalizations l10n,
    WeatherPalette palette,
    List<CityLocation> cities,
    String? selectedCityId,
    AsyncValue<List<CityLocation>> results,
  ) {
    if (results.isLoading && !results.hasValue) {
      return [_status(l10n.searchingCities, palette)];
    }
    if (results.hasError) {
      return [_status(l10n.searchFailed, palette)];
    }
    final matches = results.value ?? const <CityLocation>[];
    if (matches.isEmpty) {
      return [_status(l10n.noMatchingCities, palette)];
    }
    return [
      for (var i = 0; i < matches.length; i++)
        _CityRow(
          city: matches[i],
          temperature: _temperature(cities, matches[i]),
          palette: palette,
          selected: matches[i].id == selectedCityId,
          showTopBorder: i != 0,
          onTap: () => _openCity(cities, matches[i]),
          trailing: _resultTrailing(cities, matches[i], palette),
        ),
    ];
  }

  Widget _status(String text, WeatherPalette palette) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        text,
        style: palette.text(
          size: 18,
          weight: FontWeight.w700,
          color: palette.muted,
        ),
      ),
    );
  }

  Widget _resultTrailing(
    List<CityLocation> cities,
    CityLocation city,
    WeatherPalette palette,
  ) {
    if (_addingId == city.id) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: palette.foreground,
        ),
      );
    }
    if (_isSaved(cities, city)) {
      return Icon(Icons.check, color: palette.muted, size: 24);
    }
    return Icon(Icons.add, color: palette.foreground, size: 26);
  }
}

class _CityRow extends StatelessWidget {
  const _CityRow({
    required this.city,
    required this.temperature,
    required this.palette,
    required this.selected,
    required this.showTopBorder,
    required this.onTap,
    this.onLongPress,
    this.trailing,
  });

  final CityLocation city;
  final int? temperature;
  final WeatherPalette palette;
  final bool selected;
  final bool showTopBorder;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: HairlineRow(
        palette: palette,
        showTopBorder: showTopBorder,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                l10n.cityName(city),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: palette.text(
                  size: 26,
                  weight: selected ? FontWeight.w900 : FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            if (temperature != null)
              TemperatureLabel(
                value: temperature!,
                color: palette.foreground,
                fontSize: 34,
                degreeScale: 1,
                letterSpacing: -1,
              ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}
