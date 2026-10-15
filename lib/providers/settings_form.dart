import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/settings.dart';
import 'settings.dart';

/// The [SettingsDraft] edited on the settings screen. Seeded from the persisted
/// settings each time the screen mounts and discarded when it closes.
final settingsFormProvider =
    NotifierProvider.autoDispose<SettingsFormNotifier, SettingsDraft>(
      SettingsFormNotifier.new,
    );

class SettingsFormNotifier extends Notifier<SettingsDraft> {
  @override
  SettingsDraft build() => SettingsDraft.from(ref.watch(settingsProvider));

  /// Sets the preferred language, or null to follow the system.
  void setLanguage(String? code) => state = state.withLanguage(code);

  /// Sets whether hourly times use a 24-hour clock.
  void setUse24Hour(bool value) => state = state.withUse24Hour(value);
}
