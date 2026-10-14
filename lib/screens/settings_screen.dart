import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data/caiyun_api.dart';
import '../data/cities.dart';
import '../data/settings_store.dart';
import '../theme/weather_palette.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.store,
    required this.onSaved,
    this.client,
    this.isFirstRun = false,
  });

  final SettingsStore store;
  final ValueChanged<String> onSaved;
  final http.Client? client;

  /// When true the screen is shown as the app root (no saved key yet) and
  /// cannot be dismissed.
  final bool isFirstRun;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _controller;
  bool _obscure = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.store.apiKey ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final key = _controller.text.trim();
    if (key.isEmpty) {
      setState(() => _error = 'enter an API key');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final api = CaiyunApi(token: key, client: widget.client);
    try {
      await api.fetch(cityCatalog.first);
    } on WeatherApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error.message;
      });
      return;
    } finally {
      api.dispose();
    }

    await widget.store.setApiKey(key);
    if (!mounted) return;
    widget.onSaved(key);
    if (!widget.isFirstRun && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    const palette = WeatherPalette.navy;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: widget.isFirstRun
          ? null
          : AppBar(
              backgroundColor: palette.background,
              foregroundColor: palette.foreground,
              elevation: 0,
              title: const Text('settings'),
            ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.isFirstRun) ...[
                      const SizedBox(height: 40),
                      Icon(
                        Icons.settings,
                        color: palette.foreground,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'set a valid API key to continue',
                        style: TextStyle(
                          color: palette.foreground,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                    Text(
                      'API key',
                      style: TextStyle(
                        color: palette.foreground,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controller,
                      obscureText: _obscure,
                      autocorrect: false,
                      enableSuggestions: false,
                      cursorColor: palette.foreground,
                      style: TextStyle(
                        color: palette.foreground,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        hintText: 'paste your token',
                        hintStyle: TextStyle(
                          color: palette.foreground.withValues(alpha: 0.5),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: palette.foreground,
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: palette.hairline, width: 1),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: palette.foreground, width: 2),
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: palette.foreground,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.foreground,
                    foregroundColor: palette.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: _saving
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: palette.background,
                          ),
                        )
                      : const Text(
                          'save',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
