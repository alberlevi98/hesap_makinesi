import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_languages.dart';
import 'app_settings.dart';
import 'l10n/app_localizations.dart';
import 'screens/calculator_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await AppSettings.load();
  runApp(CalculatorApp(settings: settings));
}

const seedColor = Color(0xFF4C5FD5);

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key, required this.settings, this.home});

  final AppSettings settings;
  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return SettingsScope(
      settings: settings,
      child: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          // null = follow the device; resolved below with English fallback.
          locale: settings.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeListResolutionCallback: (deviceLocales, _) => resolveDeviceLocale(deviceLocales),
          themeMode: settings.themeMode,
          theme: _theme(Brightness.light),
          darkTheme: _theme(Brightness.dark),
          home: home ?? const CalculatorScreen(),
        ),
      ),
    );
  }

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness);
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(backgroundColor: scheme.surface, scrolledUnderElevation: 0),
      inputDecorationTheme: InputDecorationTheme(fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.6)),
    );
  }
}
