import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
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

  static const _icons = <WeatherTab, IconData>{
    WeatherTab.today: Icons.wb_sunny_outlined,
    WeatherTab.search: Icons.search,
    WeatherTab.weekly: Icons.calendar_month_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: bottomInset > 0 ? 0 : 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0),
          ],
          stops: const [0, 0.85],
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: WeatherTab.values.map((tab) {
              final selected = tab == currentTab;
              final color = selected ? palette.foreground : palette.muted;
              return Expanded(
                child: InkResponse(
                  onTap: () => onSelected(tab),
                  radius: 40,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_icons[tab], color: color, size: 30),
                      const SizedBox(height: 4),
                      Text(
                        _label(l10n, tab),
                        style: palette.text(
                          size: 14,
                          weight: selected ? FontWeight.w700 : FontWeight.w600,
                          color: color,
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

  String _label(AppLocalizations l10n, WeatherTab tab) => switch (tab) {
    WeatherTab.today => l10n.navToday,
    WeatherTab.search => l10n.navSearch,
    WeatherTab.weekly => l10n.navWeekly,
  };
}
