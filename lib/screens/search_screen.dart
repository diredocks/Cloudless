import 'package:flutter/material.dart';

import '../data/cities.dart';
import '../models/weather.dart';
import '../theme/weather_palette.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.palette,
    required this.bundles,
    required this.selectedCityId,
    required this.onSelected,
  });

  final WeatherPalette palette;
  final Map<String, WeatherBundle> bundles;
  final String selectedCityId;
  final ValueChanged<CityLocation> onSelected;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final results = cityCatalog
        .where((c) => c.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: constraints.maxHeight * 0.10),
                  TextField(
                    controller: _controller,
                    onChanged: (value) => setState(() => _query = value),
                    cursorColor: palette.foreground,
                    style: TextStyle(
                      color: palette.foreground,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: InputDecoration(
                      hintText: 'search a city',
                      hintStyle: TextStyle(
                        color: palette.foreground.withValues(alpha: 0.6),
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: palette.foreground,
                        size: 30,
                      ),
                      prefixIconConstraints:
                          const BoxConstraints(minWidth: 44),
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: palette.hairline, width: 1),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: palette.foreground, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (var i = 0; i < results.length; i++)
                    _CityRow(
                      city: results[i],
                      temperature: widget.bundles[results[i].id]
                          ?.current
                          .temperature,
                      palette: palette,
                      selected: results[i].id == widget.selectedCityId,
                      showTopBorder: i != 0,
                      onTap: () => widget.onSelected(results[i]),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
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
  });

  final CityLocation city;
  final int? temperature;
  final WeatherPalette palette;
  final bool selected;
  final bool showTopBorder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: showTopBorder ? palette.hairline : Colors.transparent,
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                city.name,
                style: TextStyle(
                  color: palette.foreground,
                  fontSize: 26,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            if (temperature != null)
              Text(
                '$temperature\u00B0',
                style: TextStyle(
                  color: palette.foreground,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
