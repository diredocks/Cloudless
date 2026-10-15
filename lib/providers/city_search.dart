import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/weather.dart';
import 'api.dart';

/// Debounce applied before a city search hits the network.
const citySearchDebounce = Duration(milliseconds: 300);

/// The cities matching [query], debounced and cancelled following Riverpod's
/// network-request guidance: https://riverpod.dev/docs/how_to/cancel
///
/// Each keyword is its own auto-disposed provider. Changing the query (or
/// leaving the search screen) disposes the previous one, and the pending delay
/// aborts before the request is sent.
final citySearchResultsProvider = FutureProvider.autoDispose
    .family<List<CityLocation>, String>((ref, query) async {
      final keyword = query.trim();
      if (keyword.isEmpty) return const [];

      // Capture whether this build was discarded, then wait out the debounce.
      // If it was, throw to abort: Riverpod catches exceptions raised after
      // disposal and ignores them.
      var didDispose = false;
      ref.onDispose(() => didDispose = true);
      await Future<void>.delayed(citySearchDebounce);
      if (didDispose) throw Exception('City search cancelled');

      return ref.read(citySearchApiProvider).search(keyword);
    });
