import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_languages.dart';
import '../app_settings.dart';
import '../core/number_format.dart';
import '../l10n/app_localizations.dart';
import 'app_drawer.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  LocaleNumbers get numbers => LocaleNumbers(Localizations.localeOf(this).languageCode);
}

/// Scaffold used by every tool screen: title, drawer and language button.
class ToolScaffold extends StatelessWidget {
  const ToolScaffold({
    super.key,
    required this.tool,
    required this.title,
    required this.body,
    this.actions = const [],
  });

  final Tool tool;
  final String title;
  final Widget body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [...actions, const LanguageButton(), const SizedBox(width: 4)],
      ),
      drawer: AppDrawer(current: tool),
      body: SafeArea(top: false, child: body),
    );
  }
}

/// Globe button showing the current language; opens the language picker.
class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return TextButton.icon(
      key: const Key('languageButton'),
      onPressed: () => showLanguagePicker(context),
      icon: const Icon(Icons.language, size: 20),
      label: Text(code.toUpperCase()),
    );
  }
}

Future<void> showLanguagePicker(BuildContext context) {
  final settings = SettingsScope.of(context);
  final l10n = context.l10n;
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      final selected = settings.languageCode;
      Widget tile(String? code, String name, {String? subtitle}) => ListTile(
            title: Text(name),
            subtitle: subtitle == null ? null : Text(subtitle),
            trailing: selected == code ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
            onTap: () {
              settings.setLanguage(code);
              Navigator.pop(context);
            },
          );
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (context, controller) => ListView(
          controller: controller,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(l10n.language, style: Theme.of(context).textTheme.titleLarge),
            ),
            tile(null, l10n.systemDefault),
            const Divider(),
            for (final lang in appLanguages) tile(lang.code, lang.nativeName),
          ],
        ),
      );
    },
  );
}

/// Numeric text field accepting `.` or `,` as decimal separator.
class NumberField extends StatelessWidget {
  const NumberField({
    super.key,
    required this.label,
    required this.controller,
    this.suffix,
    this.onChanged,
    this.allowDecimal = true,
  });

  final String label;
  final TextEditingController controller;
  final String? suffix;
  final ValueChanged<String>? onChanged;
  final bool allowDecimal;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(allowDecimal ? RegExp(r'[0-9.,]') : RegExp(r'[0-9]')),
      ],
      textDirection: TextDirection.ltr,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}

/// Card listing labelled results; the first row is emphasised.
class ResultCard extends StatelessWidget {
  const ResultCard({super.key, required this.rows, this.title});

  final String? title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: scheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title ?? context.l10n.results,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: scheme.onPrimaryContainer)),
            const SizedBox(height: 8),
            for (var i = 0; i < rows.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(rows[i].$1,
                          style: TextStyle(fontSize: 16, color: scheme.onPrimaryContainer)),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerEnd,
                        child: Text(
                          rows[i].$2,
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            fontSize: i == 0 ? 26 : 20,
                            fontWeight: FontWeight.w700,
                            color: i == 0 ? scheme.primary : scheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Shown instead of results while inputs are incomplete.
class EmptyResults extends StatelessWidget {
  const EmptyResults({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        context.l10n.enterValues,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.outline),
      ),
    );
  }
}

/// Standard padding and spacing for form-style tool screens.
class FormList extends StatelessWidget {
  const FormList({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        for (final c in children) Padding(padding: const EdgeInsets.only(bottom: 14), child: c),
      ],
    );
  }
}
