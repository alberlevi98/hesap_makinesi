import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hesap_makinesi/app_languages.dart';
import 'package:hesap_makinesi/app_settings.dart';
import 'package:hesap_makinesi/l10n/app_localizations.dart';
import 'package:hesap_makinesi/main.dart';
import 'package:hesap_makinesi/widgets/app_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppSettings> freshSettings([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  return AppSettings.load();
}

Future<void> tapKey(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).last);
  await tester.pump();
}

void main() {
  testWidgets('falls back to English for unsupported device languages', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('sv'), Locale('nl')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(CalculatorApp(settings: await freshSettings()));
    await tester.pumpAndSettle();
    expect(find.text('Calculator'), findsWidgets);
  });

  testWidgets('follows the device language when supported', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('sv'), Locale('tr', 'TR')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(CalculatorApp(settings: await freshSettings()));
    await tester.pumpAndSettle();
    expect(find.text('Hesap Makinesi'), findsWidgets);
  });

  testWidgets('language can be changed from the main screen and is remembered', (tester) async {
    final settings = await freshSettings();
    await tester.pumpWidget(CalculatorApp(settings: settings));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('languageButton')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Deutsch'), 200, scrollable: find.byType(Scrollable).last);
    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();
    expect(find.text('Rechner'), findsWidgets);
    expect(settings.languageCode, 'de');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('language'), 'de');
  });

  testWidgets('calculates with Turkish decimal separator and saves history', (tester) async {
    final settings = await freshSettings({'language': 'tr'});
    await tester.pumpWidget(CalculatorApp(settings: settings));
    await tester.pumpAndSettle();
    for (final k in ['9', '+', '5', '%']) {
      await tapKey(tester, k);
    }
    expect(find.text('= 9,45'), findsOneWidget);
    await tester.tap(find.byKey(const Key('equals')));
    await tester.pump();
    expect(settings.history.first.expression, '9+5%');
    expect(settings.history.first.result, '9.45');
    await tapKey(tester, ','); // decimal key shows the Turkish separator
  });

  testWidgets('Arabic is right-to-left but the keypad stays left-to-right', (tester) async {
    final settings = await freshSettings({'language': 'ar'});
    await tester.pumpWidget(CalculatorApp(settings: settings));
    await tester.pumpAndSettle();
    final scaffoldDir = Directionality.of(tester.element(find.byType(AppBar)));
    expect(scaffoldDir, TextDirection.rtl);
    final seven = tester.getCenter(find.text('7'));
    final nine = tester.getCenter(find.text('9'));
    expect(seven.dx < nine.dx, isTrue);
  });

  for (final lang in appLanguages) {
    testWidgets('every screen renders in ${lang.code}', (tester) async {
      tester.view.physicalSize = const Size(360 * 3, 720 * 3); // small phone
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final settings = await freshSettings({'language': lang.code, 'scientific': true});
      for (final tool in Tool.values) {
        await tester.pumpWidget(CalculatorApp(settings: settings, home: tool.build()));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '${lang.code} ${tool.name}');
        final l = AppLocalizations.of(tester.element(find.byType(Scaffold).first));
        expect(find.text(tool.label(l)), findsWidgets);
      }
      // Drawer opens without overflow.
      await tester.pumpWidget(CalculatorApp(settings: settings));
      await tester.pumpAndSettle();
      final state = tester.firstState<ScaffoldState>(find.byType(Scaffold));
      state.openDrawer();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
