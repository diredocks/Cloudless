import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/city.dart';
import 'settings.dart';

/// The user's cities, falling back to the default catalog before any are saved.
final appCitiesProvider = Provider<List<CityLocation>>((ref) {
  final cities = ref.watch(
    settingsProvider.select((settings) => settings.cities),
  );
  return cities.isNotEmpty ? cities : cityCatalog;
});

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
