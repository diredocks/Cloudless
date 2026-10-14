import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'data/caiyun_api.dart';
import 'data/settings_store.dart';
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

  @override
  void initState() {
    super.initState();
    _apiKey = widget.store.apiKey;
  }

  void _handleSaved(String key) => setState(() => _apiKey = key);

  Future<void> _openSettings() {
    return _navigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(
          store: widget.store,
          client: widget.client,
          onSaved: _handleSaved,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiKey = _apiKey;

    return MaterialApp(
      title: 'cloudless',
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
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
              onSaved: _handleSaved,
            )
          : HomeShell(
              key: ValueKey(apiKey),
              api: CaiyunApi(token: apiKey, client: widget.client),
              onOpenSettings: _openSettings,
            ),
    );
  }
}
