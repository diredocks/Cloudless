import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/city.dart';
import 'settings.dart';

/// The user's saved cities. [SettingsNotifier] seeds the default catalog when
/// none are stored, so the settings state is always populated.
final appCitiesProvider = Provider<List<CityLocation>>(
  (ref) => ref.watch(settingsProvider.select((settings) => settings.cities)),
);

/// The active city, resolved against [appCitiesProvider]. Falls back to the
/// first city when the stored selection is unset or no longer present.
final selectedCityProvider = Provider<CityLocation>((ref) {
  final cities = ref.watch(appCitiesProvider);
  final selectedId = ref.watch(
    settingsProvider.select((settings) => settings.selectedCityId),
  );
  return cities.firstWhere(
    (city) => city.id == selectedId,
    orElse: () => cities.first,
  );
});
