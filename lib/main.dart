import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'data/caiyun_api.dart';
import 'data/city_search_api.dart';
import 'data/settings_store.dart';
import 'l10n/app_language.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_shell.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/settings_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final store = await SharedPreferencesSettingsStore.load();
  runApp(CloudlessApp(store: store));
}

class CloudlessApp extends StatefulWidget {
  const CloudlessApp({super.key, required this.store, this.client});

  final SettingsStore store;

  /// Optional HTTP client, injected by tests.
  final http.Client? client;

  @override
  State<CloudlessApp> createState() => _CloudlessAppState();
}

class _CloudlessAppState extends State<CloudlessApp>
    with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final CitySearchApi _citySearch;
  CaiyunApi? _api;
  String? _apiKey;
  String? _languageCode;
  bool _use24Hour = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _apiKey = widget.store.apiKey;
    _languageCode = widget.store.languageCode;
    _use24Hour = widget.store.use24Hour;
    _citySearch = CitySearchApi(client: widget.client);
    _api = _createApi();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _citySearch.dispose();
    _api?.dispose();
    super.dispose();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);
    // While following the system we rebuild the client so it picks up the new
    // Caiyun `lang` value.
    if (_overrideLanguage == null) _replaceApi();
  }

  CaiyunApi? _createApi() {
    final key = _apiKey;
    if (key == null || key.isEmpty) return null;
    return CaiyunApi(
      token: key,
      language: _caiyunLanguage,
      client: widget.client,
    );
  }

  /// Swaps in a client built from the current key and language.
  void _replaceApi() {
    setState(() {
      _api?.dispose();
      _api = _createApi();
    });
  }

  void _handleSaved(String key, String? languageCode, bool use24Hour) {
    setState(() {
      _api?.dispose();
      _apiKey = key;
      _languageCode = languageCode;
      _use24Hour = use24Hour;
      _api = _createApi();
    });
  }

  /// The explicitly selected language, or null when following the system.
  AppLanguage? get _overrideLanguage => appLanguageForCode(_languageCode);

  /// Language actually in effect: the override, or the best match for the
  /// system locale.
  AppLanguage get _language =>
      _overrideLanguage ??
      resolveAppLanguage(WidgetsBinding.instance.platformDispatcher.locale);

  /// Caiyun `lang` parameter for the active language.
  String get _caiyunLanguage => _language.caiyunLang;

  Future<void> _openSettings() {
    return _navigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(
          store: widget.store,
          client: widget.client,
          languageCode: _languageCode,
          use24Hour: _use24Hour,
          onSaved: _handleSaved,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final api = _api;

    // Adopts the system's Material You palette when available, so settings and
    // other palette-free UI follow the system theme. Falls back to a seeded
    // scheme on platforms that do not provide dynamic colors.
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) => MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: [
          for (final language in kAppLanguages) language.locale,
        ],
        locale: _overrideLanguage?.locale,
        theme: buildAppTheme(
          schemeFromSeed(lightDynamic?.primary, Brightness.light),
        ),
        darkTheme: buildAppTheme(
          schemeFromSeed(darkDynamic?.primary, Brightness.dark),
        ),
        themeMode: ThemeMode.system,
        home: api == null
            ? SettingsScreen(
                store: widget.store,
                client: widget.client,
                isFirstRun: true,
                languageCode: _languageCode,
                use24Hour: _use24Hour,
                onSaved: _handleSaved,
              )
            : SettingsScope(
                openSettings: _openSettings,
                child: HomeShell(
                  key: ValueKey('$_apiKey-${_language.locale.toLanguageTag()}'),
                  api: api,
                  citySearch: _citySearch,
                  store: widget.store,
                  use24Hour: _use24Hour,
                ),
              ),
      ),
    );
  }
}
