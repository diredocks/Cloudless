import 'package:cloudless_app/data/local/settings_store.dart';
import 'package:cloudless_app/models/city.dart';
import 'package:cloudless_app/models/settings.dart';

/// The first catalog entry, used by tests that need a concrete [CityLocation].
final CityLocation beijingCity = cityCatalog.first;

/// In-memory [SettingsStore] for widget tests.
class MemorySettingsStore implements SettingsStore {
  MemorySettingsStore([
    String? apiKey,
    String? languageCode,
    bool use24Hour = false,
  ]) : _settings = Settings(
         apiKey: apiKey,
         languageCode: languageCode,
         use24Hour: use24Hour,
       );

  Settings _settings;

  @override
  Settings get settings => _settings;

  @override
  Future<void> save(Settings settings) async => _settings = settings;
}
