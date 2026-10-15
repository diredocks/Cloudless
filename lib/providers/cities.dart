import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/city.dart';
import 'dependencies.dart';

/// The user's persisted cities and selection: the source of truth for the saved
/// city list, written through to the [CitiesStore].
final cityListProvider = NotifierProvider<CityListNotifier, CityList>(
  CityListNotifier.new,
);

/// Holds the saved [CityList] and writes changes through to the [CitiesStore].
class CityListNotifier extends Notifier<CityList> {
  @override
  CityList build() {
    // Seed the default catalog when nothing is saved, so the in-memory state is
    // the single source of truth for the saved cities.
    final stored = ref.read(citiesStoreProvider).cityList;
    return stored.cities.isEmpty
        ? stored.copyWith(cities: cityCatalog)
        : stored;
  }

  /// Selects [city] as the active one.
  Future<void> select(CityLocation city) =>
      _write(state.copyWith(selectedCityId: city.id));

  /// Adds [city] to the saved list, unless it is already there.
  Future<void> add(CityLocation city) {
    if (state.cities.any((c) => c.id == city.id)) return Future.value();
    return _write(state.copyWith(cities: [...state.cities, city]));
  }

  /// Removes [city], keeping at least one city and moving the selection to the
  /// first remaining city when the removed one was selected.
  Future<void> remove(CityLocation city) {
    final cities = state.cities;
    if (cities.length <= 1) return Future.value();
    final remaining = cities.where((c) => c.id != city.id).toList();
    final selectedCityId = state.selectedCityId == city.id
        ? remaining.first.id
        : state.selectedCityId;
    return _write(
      state.copyWith(cities: remaining, selectedCityId: selectedCityId),
    );
  }

  /// Updates the state optimistically, then persists it.
  Future<void> _write(CityList next) async {
    state = next;
    await ref.read(citiesStoreProvider).save(next);
  }
}

/// The user's saved cities. [CityListNotifier] seeds the default catalog when
/// none are stored, so the list is always populated.
final appCitiesProvider = Provider<List<CityLocation>>(
  (ref) => ref.watch(cityListProvider.select((list) => list.cities)),
);

/// The active city, resolved against [appCitiesProvider]. Falls back to the
/// first city when the stored selection is unset or no longer present.
final selectedCityProvider = Provider<CityLocation>((ref) {
  final cities = ref.watch(appCitiesProvider);
  final selectedId = ref.watch(
    cityListProvider.select((list) => list.selectedCityId),
  );
  return cities.firstWhere(
    (city) => city.id == selectedId,
    orElse: () => cities.first,
  );
});
