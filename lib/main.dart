import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'data/local/settings_store.dart';
import 'l10n/app_language.dart';
import 'l10n/app_localizations.dart';
import 'providers/api.dart';
import 'providers/cities.dart';
import 'providers/dependencies.dart';
import 'providers/settings.dart';
import 'providers/weather.dart';
import 'screens/home_shell.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final store = await SharedPreferencesSettingsStore.load();
  runApp(CloudlessApp(store: store));
}

class CloudlessApp extends StatelessWidget {
  const CloudlessApp({super.key, required this.store, this.client});

  final SettingsStore store;

  /// Optional HTTP client, injected by tests.
  final http.Client? client;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      // Riverpod retries failed providers automatically; the app surfaces
      // errors through its own retry UI instead.
      retry: (retryCount, error) => null,
      overrides: [
        settingsStoreProvider.overrideWithValue(store),
        httpClientProvider.overrideWithValue(client),
      ],
      child: const _CloudlessAppView(),
    );
  }
}

class _CloudlessAppView extends ConsumerStatefulWidget {
  const _CloudlessAppView();

  @override
  ConsumerState<_CloudlessAppView> createState() => _CloudlessAppViewState();
}

class _CloudlessAppViewState extends ConsumerState<_CloudlessAppView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);
    // While following the system, refresh the resolved language so the Caiyun
    // client is rebuilt with the new `lang` value.
    if (ref.read(settingsProvider).languageCode == null) {
      ref.invalidate(appLanguageProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final overrideLanguage = appLanguageForCode(
      ref.watch(settingsProvider.select((settings) => settings.languageCode)),
    );
    final hasApiKey = ref.watch(caiyunApiProvider) != null;

    // Adopts the system's Material You palette when available, so settings and
    // other palette-free UI follow the system theme. Falls back to a seeded
    // scheme on platforms that do not provide dynamic colors.
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) => MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: [
          for (final language in kAppLanguages) language.locale,
        ],
        locale: overrideLanguage?.locale,
        theme: buildAppTheme(
          schemeFromSeed(lightDynamic?.primary, Brightness.light),
        ),
        darkTheme: buildAppTheme(
          schemeFromSeed(darkDynamic?.primary, Brightness.dark),
        ),
        themeMode: ThemeMode.system,
        home: hasApiKey
            ? const _EagerInitialization(child: HomeShell())
            : const SettingsScreen(isFirstRun: true),
      ),
    );
  }
}

/// Fetches every saved city up front so the app behaves eagerly, like a
/// pre-loaded forecast.
///
/// Watching each city's bundle in a consumer placed high in the tree triggers
/// the requests and keeps the providers alive. It deliberately returns [child]
/// unchanged so that bundle updates only rebuild this shell, not the app.
class _EagerInitialization extends ConsumerWidget {
  const _EagerInitialization({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    for (final city in ref.watch(appCitiesProvider)) {
      ref.watch(weatherBundleProvider(city));
    }
    return child;
  }
}
