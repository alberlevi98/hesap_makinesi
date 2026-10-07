import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../screens/bmi_screen.dart';
import '../screens/calculator_screen.dart';
import '../screens/date_screen.dart';
import '../screens/discount_screen.dart';
import '../screens/loan_screen.dart';
import '../screens/percentage_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/tip_screen.dart';
import '../screens/unit_screen.dart';

enum Tool { calculator, units, percentage, discount, tip, loan, date, bmi, settings }

extension ToolInfo on Tool {
  IconData get icon => switch (this) {
        Tool.calculator => Icons.calculate_outlined,
        Tool.units => Icons.straighten,
        Tool.percentage => Icons.percent,
        Tool.discount => Icons.sell_outlined,
        Tool.tip => Icons.restaurant_outlined,
        Tool.loan => Icons.account_balance_outlined,
        Tool.date => Icons.event_outlined,
        Tool.bmi => Icons.monitor_weight_outlined,
        Tool.settings => Icons.settings_outlined,
      };

  String label(AppLocalizations l) => switch (this) {
        Tool.calculator => l.toolCalculator,
        Tool.units => l.toolUnitConverter,
        Tool.percentage => l.toolPercentage,
        Tool.discount => l.toolDiscount,
        Tool.tip => l.toolTip,
        Tool.loan => l.toolLoan,
        Tool.date => l.toolDate,
        Tool.bmi => l.toolBmi,
        Tool.settings => l.settings,
      };

  Widget build() => switch (this) {
        Tool.calculator => const CalculatorScreen(),
        Tool.units => const UnitScreen(),
        Tool.percentage => const PercentageScreen(),
        Tool.discount => const DiscountScreen(),
        Tool.tip => const TipScreen(),
        Tool.loan => const LoanScreen(),
        Tool.date => const DateScreen(),
        Tool.bmi => const BmiScreen(),
        Tool.settings => const SettingsScreen(),
      };
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.current});
  final Tool current;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    Widget item(Tool tool) {
      final selected = tool == current;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: ListTile(
          leading: Icon(tool.icon),
          title: Text(tool.label(l)),
          selected: selected,
          selectedColor: scheme.onSecondaryContainer,
          selectedTileColor: scheme.secondaryContainer,
          shape: const StadiumBorder(),
          onTap: () {
            Navigator.pop(context);
            if (selected) return;
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, _, _) => tool.build(),
                transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
              ),
            );
          },
        ),
      );
    }

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(14)),
                    child: Icon(Icons.calculate_rounded, color: scheme.onPrimary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(l.appTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            _header(context, l.sectionCalculators),
            item(Tool.calculator),
            item(Tool.units),
            item(Tool.percentage),
            item(Tool.discount),
            _header(context, l.sectionEveryday),
            item(Tool.tip),
            item(Tool.loan),
            item(Tool.date),
            item(Tool.bmi),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 28, vertical: 8), child: Divider()),
            item(Tool.settings),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.fromLTRB(28, 16, 16, 8),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
      );
}
