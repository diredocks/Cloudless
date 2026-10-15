import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/caiyun_api.dart';
import '../data/city_search_api.dart';
import 'dependencies.dart';
import 'settings.dart';

/// The Caiyun weather client, rebuilt whenever the API key or language changes.
/// Null until an API key has been configured.
final caiyunApiProvider = Provider<CaiyunApi?>((ref) {
  final key = ref.watch(settingsProvider.select((settings) => settings.apiKey));
  if (key == null || key.isEmpty) return null;
  final api = CaiyunApi(
    token: key,
    language: ref.watch(appLanguageProvider).caiyunLang,
    client: ref.watch(httpClientProvider),
  );
  ref.onDispose(api.dispose);
  return api;
});

/// The area-search client used by the city search feature.
final citySearchApiProvider = Provider<CitySearchApi>((ref) {
  final api = CitySearchApi(client: ref.watch(httpClientProvider));
  ref.onDispose(api.dispose);
  return api;
});
