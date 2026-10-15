import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/city.dart';
import '../models/weather_bundle.dart';
import 'api.dart';

/// The weather bundle for [city], fetched through the Caiyun client.
///
/// The provider is keyed by [CityLocation] (by id) and rebuilt — hence
/// refetched — whenever the client changes, e.g. after a new API key or
/// language. Kept alive so switching tabs or back to a city does not refetch.
final weatherBundleProvider =
    FutureProvider.family<WeatherBundle, CityLocation>((ref, city) {
      final api = ref.watch(caiyunApiProvider);
      if (api == null) {
        throw StateError('Weather requested without an API key');
      }
      return api.fetch(city);
    });
