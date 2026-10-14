import 'package:flutter/material.dart';

import '../data/mock_weather.dart';
import '../widgets/weather_bottom_nav.dart';
import 'search_screen.dart';
import 'today_screen.dart';
import 'weekly_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _cityIndex = 0;
  WeatherTab _tab = WeatherTab.today;

  @override
  Widget build(BuildContext context) {
    final city = mockCities[_cityIndex];
    final weekly = mockWeekly[city.name]!;

    final palette = switch (_tab) {
      WeatherTab.weekly => weekly.palette,
      _ => city.current.palette,
    };

    final body = switch (_tab) {
      WeatherTab.today => TodayScreen(weather: city.current),
      WeatherTab.weekly => WeeklyScreen(weather: weekly),
      WeatherTab.search => SearchScreen(
          palette: palette,
          selectedCity: city.name,
          onSelected: (selected) {
            setState(() {
              _cityIndex = mockCities.indexOf(selected);
              _tab = WeatherTab.today;
            });
          },
        ),
    };

    return Scaffold(
      body: AnimatedContainer(
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
      ),
    );
  }
}
