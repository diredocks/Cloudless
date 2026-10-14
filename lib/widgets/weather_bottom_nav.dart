import 'package:flutter/material.dart';

import '../theme/weather_palette.dart';

enum WeatherTab { today, search, weekly }

class WeatherBottomNav extends StatelessWidget {
  const WeatherBottomNav({
    super.key,
    required this.palette,
    required this.currentTab,
    required this.onSelected,
  });

  final WeatherPalette palette;
  final WeatherTab currentTab;
  final ValueChanged<WeatherTab> onSelected;

  static const _items = <WeatherTab, (IconData, String)>{
    WeatherTab.today: (Icons.wb_sunny_outlined, 'today'),
    WeatherTab.search: (Icons.search, 'search'),
    WeatherTab.weekly: (Icons.calendar_month_outlined, 'weekly'),
  };

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: bottomInset > 0 ? 0 : 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: palette.hairline, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: _items.entries.map((entry) {
              final selected = entry.key == currentTab;
              final (icon, label) = entry.value;
              final color = selected
                  ? palette.foreground
                  : palette.foreground.withValues(alpha: 0.6);
              return Expanded(
                child: InkResponse(
                  onTap: () => onSelected(entry.key),
                  radius: 40,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: color, size: 30),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontSize: 14,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
