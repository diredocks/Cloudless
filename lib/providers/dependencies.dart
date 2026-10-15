import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../data/local/settings_store.dart';

/// Root dependencies, overridden at startup (and by tests). They sit at the
/// bottom of the graph: nothing here depends on app state.
///
/// The store backing [settingsProvider].
final settingsStoreProvider = Provider<SettingsStore>(
  (ref) => throw UnimplementedError('settingsStoreProvider must be overridden'),
);

/// The HTTP client shared by the network clients, or null to let each client
/// own one. Overridden by tests to inject a mock.
final httpClientProvider = Provider<http.Client?>((ref) => null);
