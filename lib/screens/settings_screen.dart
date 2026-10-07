import 'package:flutter/material.dart';

import '../app_languages.dart';
import '../app_settings.dart';
import '../widgets/app_drawer.dart';
import '../widgets/common.dart';
import 'history_screen.dart';

const appVersion = '1.0.0';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final settings = SettingsScope.of(context);
    final code = settings.languageCode;
    final languageName =
        code == null ? l.systemDefault : appLanguages.firstWhere((x) => x.code == code).nativeName;

    return ToolScaffold(
      tool: Tool.settings,
      title: l.settings,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l.language),
            subtitle: Text(languageName),
            onTap: () => showLanguagePicker(context),
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l.theme),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(value: ThemeMode.system, label: Text(l.themeSystem)),
                  ButtonSegment(value: ThemeMode.light, label: Text(l.themeLight)),
                  ButtonSegment(value: ThemeMode.dark, label: Text(l.themeDark)),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (s) => settings.setThemeMode(s.first),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined),
            title: Text(l.clearHistory),
            enabled: settings.history.isNotEmpty,
            onTap: () => confirmClearHistory(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l.version),
            subtitle: const Text(appVersion),
          ),
        ],
      ),
    );
  }
}
