import 'dart:async';

import 'package:flutter/material.dart';

import '../data/city_search_api.dart';
import '../l10n/app_localizations.dart';
import '../l10n/weather_l10n.dart';
import '../models/weather.dart';
import '../theme/weather_palette.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/hairline_row.dart';
import '../widgets/settings_button.dart';
import '../widgets/temperature_label.dart';
import '../widgets/weather_page.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.palette,
    required this.bundles,
    required this.cities,
    required this.selectedCityId,
    required this.searchApi,
    required this.onSelected,
    required this.onAdd,
    required this.onRemove,
    required this.onOpenSettings,
  });

  final WeatherPalette palette;
  final Map<String, WeatherBundle> bundles;

  /// The user's saved cities, in display order.
  final List<CityLocation> cities;

  final String selectedCityId;
  final CitySearchApi searchApi;
  final ValueChanged<CityLocation> onSelected;

  /// Persists [city] and loads its weather. Resolves to true when the city is
  /// now available.
  final Future<bool> Function(CityLocation city) onAdd;

  final ValueChanged<CityLocation> onRemove;
  final VoidCallback onOpenSettings;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  int _requestId = 0;
  String _query = '';
  List<CityLocation> _results = const [];
  bool _searching = false;
  bool _failed = false;
  String? _addingId;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  bool _isSaved(CityLocation city) => widget.cities.any((c) => c.id == city.id);

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();

    final query = value.trim();
    if (query.isEmpty) {
      _requestId++;
      setState(() {
        _results = const [];
        _searching = false;
        _failed = false;
      });
      return;
    }

    setState(() {
      _searching = true;
      _failed = false;
    });
    _debounce = Timer(const Duration(milliseconds: 300), () => _run(query));
  }

  Future<void> _run(String query) async {
    final id = ++_requestId;
    try {
      final results = await widget.searchApi.search(query);
      if (!mounted || id != _requestId) return;
      setState(() {
        _results = results;
        _searching = false;
      });
    } on CitySearchException {
      if (!mounted || id != _requestId) return;
      setState(() {
        _failed = true;
        _searching = false;
      });
    }
  }

  Future<void> _add(CityLocation city) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _addingId = city.id);
    final ok = await widget.onAdd(city);
    if (!mounted) return;

    if (ok) {
      // Reset the search so the newly saved city shows in the list.
      _debounce?.cancel();
      _requestId++;
      _controller.clear();
      setState(() {
        _addingId = null;
        _query = '';
        _results = const [];
        _searching = false;
        _failed = false;
      });
    } else {
      setState(() => _addingId = null);
      showAppSnack(context, l10n.cityAddFailed);
    }
  }

  Future<void> _confirmRemove(CityLocation city) async {
    final l10n = AppLocalizations.of(context);
    if (widget.cities.length <= 1) {
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
    widget.onRemove(city);
  }

  void _openCity(CityLocation city) {
    if (_isSaved(city)) {
      widget.onSelected(city);
    } else {
      _add(city);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = widget.palette;
    final query = _query.trim();

    return WeatherPage(
      children: (maxHeight) => [
        SettingsPageGap(
          height: maxHeight * 0.10,
          palette: palette,
          onOpenSettings: widget.onOpenSettings,
        ),
        _searchField(l10n, palette),
        const SizedBox(height: 20),
        if (query.isEmpty)
          ..._savedRows(palette)
        else
          ..._resultRows(l10n, palette),
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

  List<Widget> _savedRows(WeatherPalette palette) {
    return [
      for (var i = 0; i < widget.cities.length; i++)
        _CityRow(
          city: widget.cities[i],
          temperature: widget.bundles[widget.cities[i].id]?.current.temperature,
          palette: palette,
          selected: widget.cities[i].id == widget.selectedCityId,
          showTopBorder: i != 0,
          onTap: () => widget.onSelected(widget.cities[i]),
          onLongPress: () => _confirmRemove(widget.cities[i]),
        ),
    ];
  }

  List<Widget> _resultRows(AppLocalizations l10n, WeatherPalette palette) {
    if (_searching && _results.isEmpty) {
      return [_status(l10n.searchingCities, palette)];
    }
    if (_failed) {
      return [_status(l10n.searchFailed, palette)];
    }
    if (_results.isEmpty) {
      return [_status(l10n.noMatchingCities, palette)];
    }
    return [
      for (var i = 0; i < _results.length; i++)
        _CityRow(
          city: _results[i],
          temperature: widget.bundles[_results[i].id]?.current.temperature,
          palette: palette,
          selected: _results[i].id == widget.selectedCityId,
          showTopBorder: i != 0,
          onTap: () => _openCity(_results[i]),
          trailing: _resultTrailing(_results[i], palette),
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

  Widget _resultTrailing(CityLocation city, WeatherPalette palette) {
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
    if (_isSaved(city)) {
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
