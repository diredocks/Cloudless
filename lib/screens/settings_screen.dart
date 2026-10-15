import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../data/caiyun_api.dart';
import '../data/cities.dart';
import '../data/settings_store.dart';
import '../l10n/app_language.dart';
import '../l10n/app_localizations.dart';
import '../l10n/weather_l10n.dart';
import '../theme/weather_palette.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.store,
    required this.onSaved,
    this.client,
    this.languageCode,
    this.isFirstRun = false,
  });

  final SettingsStore store;

  /// Called after the settings have been persisted with the new API key and
  /// language override (`null` follows the system).
  final void Function(String apiKey, String? languageCode) onSaved;

  final http.Client? client;

  /// Current language code (see [kAppLanguages]) or null to follow the system.
  final String? languageCode;

  /// When true the screen is shown as the app root (no saved key yet) and
  /// cannot be dismissed.
  final bool isFirstRun;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _controller;
  late String? _languageCode;
  bool _obscure = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.store.apiKey ?? '');
    _languageCode = widget.languageCode;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectLanguage(String? code) => setState(() => _languageCode = code);

  /// Checks [key] against the weather service. Returns the localized error to
  /// show, or null when the key works.
  Future<String?> _validateKey(String key) async {
    final l10n = AppLocalizations.of(context);
    final api = CaiyunApi(token: key, client: widget.client);
    try {
      await api.fetch(cityCatalog.first);
      return null;
    } on WeatherApiException catch (error) {
      return l10n.weatherError(error);
    } finally {
      api.dispose();
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final key = _controller.text.trim();
    if (key.isEmpty) {
      setState(() => _error = l10n.errorEnterApiKey);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final error = await _validateKey(key);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _saving = false;
        _error = error;
      });
      return;
    }

    await widget.store.setApiKey(key);
    await widget.store.setLanguageCode(_languageCode);
    if (!mounted) return;
    widget.onSaved(key, _languageCode);
    if (!widget.isFirstRun && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const palette = WeatherPalette.navy;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: palette.systemUiOverlayStyle,
      child: Scaffold(
        backgroundColor: palette.background,
        appBar: widget.isFirstRun
            ? null
            : AppBar(
                backgroundColor: palette.background,
                foregroundColor: palette.foreground,
                systemOverlayStyle: palette.systemUiOverlayStyle,
                elevation: 0,
                title: Text(l10n.settingsTitle),
              ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 16,
                  ),
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
                          l10n.firstRunTitle,
                          style: palette.text(
                            size: 30,
                            weight: FontWeight.w900,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.firstRunPrompt,
                          style: palette.text(
                            size: 18,
                            weight: FontWeight.w600,
                            height: 1.3,
                            color: palette.foreground.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                      Text(
                        l10n.apiKeyLabel,
                        style: palette.text(size: 17, weight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _controller,
                        obscureText: _obscure,
                        autocorrect: false,
                        enableSuggestions: false,
                        cursorColor: palette.foreground,
                        style: palette.text(size: 20, weight: FontWeight.w700),
                        decoration: InputDecoration(
                          hintText: l10n.apiKeyHint,
                          hintStyle: palette.text(
                            size: 20,
                            weight: FontWeight.w700,
                            color: palette.foreground.withValues(alpha: 0.5),
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
                            borderSide: BorderSide(
                              color: palette.hairline,
                              width: 1,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: palette.foreground,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: palette.text(
                            size: 16,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      Text(
                        l10n.languageLabel,
                        style: palette.text(size: 17, weight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      _LanguageDropdown(
                        value: _languageCode,
                        palette: palette,
                        onChanged: _selectLanguage,
                      ),
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
                        : Text(
                            l10n.save,
                            style: const TextStyle(
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
      ),
    );
  }
}

class _LanguageDropdown extends StatelessWidget {
  const _LanguageDropdown({
    required this.value,
    required this.palette,
    required this.onChanged,
  });

  static const String _system = 'system';

  final String? value;
  final WeatherPalette palette;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: palette.hairline, width: 1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value ?? _system,
          isExpanded: true,
          dropdownColor: palette.background,
          iconEnabledColor: palette.foreground,
          borderRadius: BorderRadius.circular(4),
          style: palette.text(size: 20, weight: FontWeight.w700),
          items: [
            DropdownMenuItem(value: _system, child: Text(l10n.languageSystem)),
            for (final language in kAppLanguages)
              DropdownMenuItem(
                value: language.locale.languageCode,
                child: Text(language.nativeName),
              ),
          ],
          onChanged: (selection) =>
              onChanged(selection == _system ? null : selection),
        ),
      ),
    );
  }
}
