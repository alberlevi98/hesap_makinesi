import 'package:flutter/material.dart';

import '../core/number_format.dart';
import '../widgets/app_drawer.dart';
import '../widgets/common.dart';

class PercentageScreen extends StatefulWidget {
  const PercentageScreen({super.key});

  @override
  State<PercentageScreen> createState() => _PercentageScreenState();
}

class _PercentageScreenState extends State<PercentageScreen> {
  final _c = List.generate(6, (_) => TextEditingController());

  @override
  void dispose() {
    for (final c in _c) {
      c.dispose();
    }
    super.dispose();
  }

  double? _v(int i) => parseUserNumber(_c[i].text);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final n = context.numbers;
    final scheme = Theme.of(context).colorScheme;

    String? ofResult() {
      final x = _v(0), y = _v(1);
      return x == null || y == null ? null : n.format(x * y / 100, maxFractionDigits: 6);
    }

    String? whatResult() {
      final x = _v(2), y = _v(3);
      return x == null || y == null || y == 0 ? null : '${n.format(x / y * 100, maxFractionDigits: 4)}%';
    }

    (String, bool)? changeResult() {
      final x = _v(4), y = _v(5);
      if (x == null || y == null || x == 0) return null;
      final change = (y - x) / x.abs() * 100;
      return ('${change > 0 ? '+' : ''}${n.format(change, maxFractionDigits: 4)}%', change >= 0);
    }

    final change = changeResult();

    Widget section(String title, int a, int b, String? result, {String? note, Color? color}) => Card(
          elevation: 0,
          color: scheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: NumberField(label: 'X', controller: _c[a], onChanged: (_) => setState(() {}))),
                  const SizedBox(width: 12),
                  Expanded(child: NumberField(label: 'Y', controller: _c[b], onChanged: (_) => setState(() {}))),
                ]),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('${l.result}:', style: TextStyle(color: scheme.outline)),
                    const Spacer(),
                    if (note != null) Text('$note  ', style: TextStyle(color: color)),
                    Text(result ?? '—',
                        textDirection: TextDirection.ltr,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color ?? scheme.primary)),
                  ],
                ),
              ],
            ),
          ),
        );

    return ToolScaffold(
      tool: Tool.percentage,
      title: l.toolPercentage,
      body: FormList(children: [
        section(l.pctOfTitle, 0, 1, ofResult()),
        section(l.pctWhatTitle, 2, 3, whatResult()),
        section(
          l.pctChangeTitle,
          4,
          5,
          change?.$1,
          note: change == null ? null : (change.$2 ? l.pctIncrease : l.pctDecrease),
          color: change == null ? null : (change.$2 ? Colors.green.shade600 : scheme.error),
        ),
      ]),
    );
  }
}
