import 'package:flutter/material.dart';

import '../app_settings.dart';
import '../widgets/common.dart';

/// Lists past calculations. Tapping an entry returns its expression.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final settings = SettingsScope.of(context);
    final numbers = context.numbers;
    final history = settings.history;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.history, style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              tooltip: l.clearHistory,
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => confirmClearHistory(context),
            ),
        ],
      ),
      body: history.isEmpty
          ? Center(child: Text(l.historyEmpty, style: TextStyle(color: scheme.outline)))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: history.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final e = history[i];
                final value = double.tryParse(e.result);
                return Material(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.pop(context, e.expression),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(numbers.displayExpression(e.expression),
                                      style: TextStyle(fontSize: 16, color: scheme.outline)),
                                  const SizedBox(height: 4),
                                  Text(
                                    value == null ? e.result : numbers.format(value),
                                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.north_west, color: scheme.outline, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

Future<void> confirmClearHistory(BuildContext context) async {
  final l = context.l10n;
  final settings = SettingsScope.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(l.clearHistoryConfirm),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l.delete)),
      ],
    ),
  );
  if (ok == true) settings.clearHistory();
}
