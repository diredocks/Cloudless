import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'data/caiyun_api.dart';
import 'data/settings_store.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_shell.dart';
import 'screens/settings_screen.dart';

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

class _CloudlessAppState extends State<CloudlessApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  String? _apiKey;
  String? _languageCode;

  @override
  void initState() {
    super.initState();
    _apiKey = widget.store.apiKey;
    _languageCode = widget.store.languageCode;
  }

  void _handleSaved(String key, String? languageCode) {
    setState(() {
      _apiKey = key;
      _languageCode = languageCode;
    });
  }

  /// Locale used for API-bound `lang` and widget keys: the explicit choice, or
  /// the system language when following it.
  String get _effectiveLanguageCode =>
      _languageCode ??
      WidgetsBinding.instance.platformDispatcher.locale.languageCode;

  /// Caiyun `lang` parameter for the current locale.
  String get _caiyunLanguage =>
      _effectiveLanguageCode == 'zh' ? 'zh_CN' : 'en_US';

  Future<void> _openSettings() {
    return _navigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(
          store: widget.store,
          client: widget.client,
          languageCode: _languageCode,
          onSaved: _handleSaved,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiKey = _apiKey;

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _languageCode == null ? null : Locale(_languageCode!),
      theme: ThemeData(
        useMaterial3: true,
        splashFactory: NoSplash.splashFactory,
        fontFamily: null,
      ),
      home: (apiKey == null || apiKey.isEmpty)
          ? SettingsScreen(
              store: widget.store,
              client: widget.client,
              isFirstRun: true,
              languageCode: _languageCode,
              onSaved: _handleSaved,
            )
          : HomeShell(
              key: ValueKey('$apiKey-$_effectiveLanguageCode'),
              api: CaiyunApi(
                token: apiKey,
                language: _caiyunLanguage,
                client: widget.client,
              ),
              onOpenSettings: _openSettings,
            ),
    );
  }
}
