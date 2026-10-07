import 'package:flutter/material.dart';

import '../core/number_format.dart';
import '../widgets/app_drawer.dart';
import '../widgets/common.dart';

class TipScreen extends StatefulWidget {
  const TipScreen({super.key});

  @override
  State<TipScreen> createState() => _TipScreenState();
}

class _TipScreenState extends State<TipScreen> {
  final _bill = TextEditingController();
  final _tip = TextEditingController(text: '10');
  int _people = 1;

  @override
  void dispose() {
    _bill.dispose();
    _tip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final n = context.numbers;
    final scheme = Theme.of(context).colorScheme;
    final bill = parseUserNumber(_bill.text);
    final tipPct = parseUserNumber(_tip.text) ?? 0;
    void refresh(String _) => setState(() {});

    Widget results() {
      if (bill == null) return const EmptyResults();
      final tip = bill * tipPct / 100;
      final total = bill + tip;
      return ResultCard(rows: [
        if (_people > 1) (l.perPerson, n.money(total / _people)),
        (l.total, n.money(total)),
        (l.tipAmount, n.money(tip)),
        if (_people > 1) (l.tipPerPerson, n.money(tip / _people)),
      ]);
    }

    return ToolScaffold(
      tool: Tool.tip,
      title: l.toolTip,
      body: FormList(children: [
        NumberField(label: l.billAmount, controller: _bill, onChanged: refresh),
        NumberField(label: l.tipPercent, controller: _tip, suffix: '%', onChanged: refresh),
        Wrap(
          spacing: 8,
          children: [
            for (final p in const [0, 5, 10, 15, 18, 20])
              ChoiceChip(
                label: Text('$p%'),
                selected: tipPct == p,
                onSelected: (_) => setState(() => _tip.text = '$p'),
              ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(child: Text(l.numberOfPeople, style: const TextStyle(fontSize: 16))),
              IconButton.filledTonal(
                onPressed: _people > 1 ? () => setState(() => _people--) : null,
                icon: const Icon(Icons.remove),
              ),
              SizedBox(
                width: 48,
                child: Text('$_people',
                    textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              ),
              IconButton.filledTonal(
                onPressed: _people < 99 ? () => setState(() => _people++) : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        results(),
      ]),
    );
  }
}
