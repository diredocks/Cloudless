import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/remote/caiyun_api.dart';
import '../data/remote/weather_api_exception.dart';
import '../l10n/app_language.dart';
import '../l10n/app_localizations.dart';
import '../l10n/weather_l10n.dart';
import '../models/cities.dart';
import '../models/settings.dart';
import '../providers/dependencies.dart';
import '../providers/settings.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key, this.isFirstRun = false});

  /// When true the screen is shown as the app root (no saved key yet) and
  /// cannot be dismissed.
  final bool isFirstRun;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _controller;
  late String? _languageCode;
  late bool _use24Hour;
  bool _obscure = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _controller = TextEditingController(text: settings.apiKey ?? '');
    _languageCode = settings.languageCode;
    _use24Hour = settings.use24Hour;
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
    final api = CaiyunApi(token: key, client: ref.read(httpClientProvider));
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

    final current = ref.read(settingsProvider);
    final settings = Settings(
      apiKey: key,
      languageCode: _languageCode,
      use24Hour: _use24Hour,
      cities: current.cities,
      selectedCityId: current.selectedCityId,
    );
    await ref.read(settingsProvider.notifier).save(settings);
    if (!mounted) return;
    if (!widget.isFirstRun && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: appSystemUiOverlayStyle(scheme),
      child: Scaffold(
        appBar: _appBar(l10n),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 16,
                  ),
                  child: _form(l10n, scheme),
                ),
              ),
              _bottomBar(l10n, scheme),
            ],
          ),
        ),
      ),
    );
  }

  /// No app bar during first run, so the prompt cannot be dismissed.
  PreferredSizeWidget? _appBar(AppLocalizations l10n) {
    if (widget.isFirstRun) return null;
    return AppBar(title: Text(l10n.settingsTitle));
  }

  Widget _form(AppLocalizations l10n, ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._firstRunHeader(l10n, scheme),
        Text(
          l10n.apiKeyLabel,
          style: TextStyle(
            color: scheme.onSurface,
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
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: l10n.apiKeyHint,
            hintStyle: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
            ),
          ),
        ),
        ..._errorNotice(scheme),
        const SizedBox(height: 32),
        Text(
          l10n.languageLabel,
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        _LanguageDropdown(value: _languageCode, onChanged: _selectLanguage),
        const SizedBox(height: 32),
        Text(
          l10n.timeFormatLabel,
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        _TimeFormatToggle(
          value: _use24Hour,
          onChanged: (value) => setState(() => _use24Hour = value),
        ),
      ],
    );
  }

  /// The intro block shown only when there is no saved API key yet.
  List<Widget> _firstRunHeader(AppLocalizations l10n, ColorScheme scheme) {
    if (!widget.isFirstRun) return const [];
    return [
      const SizedBox(height: 40),
      Icon(Icons.settings, color: scheme.primary, size: 64),
      const SizedBox(height: 16),
      Text(
        l10n.firstRunTitle,
        style: TextStyle(
          color: scheme.onSurface,
          fontSize: 30,
          fontWeight: FontWeight.w900,
          height: 1.1,
          letterSpacing: -0.5,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        l10n.firstRunPrompt,
        style: TextStyle(
          color: scheme.onSurfaceVariant,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      ),
      const SizedBox(height: 40),
    ];
  }

  /// The validation error, shown below the API key field when present.
  List<Widget> _errorNotice(ColorScheme scheme) {
    final error = _error;
    if (error == null) return const [];
    return [
      const SizedBox(height: 12),
      Text(
        error,
        style: TextStyle(
          color: scheme.error,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ];
  }

  Widget _bottomBar(AppLocalizations l10n, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton(
          onPressed: _saving ? null : _save,
          child: _saveButtonChild(l10n, scheme),
        ),
      ),
    );
  }

  Widget _saveButtonChild(AppLocalizations l10n, ColorScheme scheme) {
    if (_saving) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: scheme.onPrimary,
        ),
      );
    }
    return Text(
      l10n.save,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
    );
  }
}

class _TimeFormatToggle extends StatelessWidget {
  const _TimeFormatToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: scheme.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value ? l10n.timeFormat24 : l10n.timeFormatAmPm,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _LanguageDropdown extends StatelessWidget {
  const _LanguageDropdown({required this.value, required this.onChanged});

  static const String _system = 'system';

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: scheme.outlineVariant, width: 1),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value ?? _system,
          isExpanded: true,
          dropdownColor: scheme.surfaceContainer,
          iconEnabledColor: scheme.onSurfaceVariant,
          borderRadius: BorderRadius.circular(4),
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
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
