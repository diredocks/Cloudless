import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/remote/caiyun_api.dart';
import '../data/remote/weather_api_exception.dart';
import '../l10n/app_language.dart';
import '../l10n/app_localizations.dart';
import '../l10n/weather_l10n.dart';
import '../models/city.dart';
import '../models/settings.dart';
import '../providers/dependencies.dart';
import '../providers/settings.dart';
import '../providers/settings_form.dart';
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
  bool _obscure = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(settingsFormProvider).apiKey,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
    final draft = ref.read(settingsFormProvider);
    final key = draft.apiKey.trim();
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

    final settings = draft.toSettings();
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
    final draft = ref.watch(settingsFormProvider);
    final form = ref.read(settingsFormProvider.notifier);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: appSystemUiOverlayStyle(scheme),
      child: Scaffold(
        // No app bar during first run, so the prompt cannot be dismissed.
        appBar: widget.isFirstRun
            ? null
            : AppBar(title: Text(l10n.settingsTitle)),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 16,
                  ),
                  child: _form(l10n, scheme, draft, form),
                ),
              ),
              _bottomBar(l10n, scheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _form(
    AppLocalizations l10n,
    ColorScheme scheme,
    SettingsDraft draft,
    SettingsFormNotifier form,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._firstRunHeader(l10n, scheme),
        _FieldLabel(text: l10n.apiKeyLabel),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          onChanged: form.setApiKey,
          obscureText: _obscure,
          autocorrect: false,
          enableSuggestions: false,
          style: _optionStyle(scheme),
          decoration: InputDecoration(
            hintText: l10n.apiKeyHint,
            hintStyle: _optionStyle(scheme)
                .copyWith(color: scheme.onSurfaceVariant),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
            ),
          ),
        ),
        ..._errorNotice(scheme),
        const SizedBox(height: 32),
        _FieldLabel(text: l10n.languageLabel),
        const SizedBox(height: 4),
        _SettingsField(
          child: _LanguageDropdown(
            value: draft.languageCode,
            onChanged: form.setLanguage,
          ),
        ),
        const SizedBox(height: 32),
        _FieldLabel(text: l10n.timeFormatLabel),
        const SizedBox(height: 4),
        _SettingsField(
          child: _TimeFormatToggle(
            value: draft.use24Hour,
            onChanged: form.setUse24Hour,
          ),
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

/// The bold value style shared by the editable fields.
TextStyle _optionStyle(ColorScheme scheme) => TextStyle(
  color: scheme.onSurface,
  fontSize: 20,
  fontWeight: FontWeight.w700,
);

/// A bold section heading above an editable field.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// The hairline-divided slot an editable field sits in.
class _SettingsField extends StatelessWidget {
  const _SettingsField({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: child,
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
    return Row(
      children: [
        Expanded(
          child: Text(
            value ? l10n.timeFormat24 : l10n.timeFormatAmPm,
            style: _optionStyle(scheme),
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
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
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value ?? _system,
        isExpanded: true,
        dropdownColor: scheme.surfaceContainer,
        iconEnabledColor: scheme.onSurfaceVariant,
        borderRadius: BorderRadius.circular(4),
        style: _optionStyle(scheme),
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
    );
  }
}
