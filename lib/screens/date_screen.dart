import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/dates.dart';
import '../widgets/app_drawer.dart';
import '../widgets/common.dart';

class DateScreen extends StatefulWidget {
  const DateScreen({super.key});

  @override
  State<DateScreen> createState() => _DateScreenState();
}

class _DateScreenState extends State<DateScreen> {
  bool _addMode = false;
  bool _subtract = false;
  late DateTime _start;
  late DateTime _end;
  final _days = TextEditingController(text: '30');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _start = DateTime(now.year, now.month, now.day);
    _end = DateTime(now.year + 1, now.month, now.day);
  }

  @override
  void dispose() {
    _days.dispose();
    super.dispose();
  }

  Future<DateTime?> _pick(DateTime initial) => showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(1900),
        lastDate: DateTime(2200),
      );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final n = context.numbers;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final fmt = DateFormat.yMMMEd(locale);

    Widget dateTile(String label, DateTime value, ValueChanged<DateTime> onPicked) => Material(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          child: ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            leading: const Icon(Icons.event),
            title: Text(label),
            subtitle: Text(fmt.format(value), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            onTap: () async {
              final d = await _pick(value);
              if (d != null) setState(() => onPicked(d));
            },
          ),
        );

    final children = <Widget>[
      SegmentedButton<bool>(
        segments: [
          ButtonSegment(value: false, label: Text(l.dateDifference), icon: const Icon(Icons.date_range)),
          ButtonSegment(value: true, label: Text(l.dateAddSubtract), icon: const Icon(Icons.more_time)),
        ],
        selected: {_addMode},
        onSelectionChanged: (s) => setState(() => _addMode = s.first),
      ),
      dateTile(l.startDate, _start, (d) => _start = d),
    ];

    if (!_addMode) {
      final diff = dateDifference(_start, _end);
      children.addAll([
        dateTile(l.endDate, _end, (d) => _end = d),
        ResultCard(rows: [
          ('${l.years} / ${l.months} / ${l.days}',
              '${n.integer(diff.years)} / ${n.integer(diff.months)} / ${n.integer(diff.days)}'),
          (l.totalDays, n.integer(diff.totalDays)),
          (l.weeks, n.format(diff.totalDays / 7, maxFractionDigits: 2)),
        ]),
      ]);
    } else {
      final days = int.tryParse(_days.text);
      children.addAll([
        Row(children: [
          Expanded(
            child: NumberField(
              label: l.days,
              controller: _days,
              allowDecimal: false,
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 12),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: false, label: Text(l.add), icon: const Icon(Icons.add)),
              ButtonSegment(value: true, label: Text(l.subtract), icon: const Icon(Icons.remove)),
            ],
            showSelectedIcon: false,
            selected: {_subtract},
            onSelectionChanged: (s) => setState(() => _subtract = s.first),
          ),
        ]),
        if (days == null || days > 100000)
          const EmptyResults()
        else
          ResultCard(rows: [
            (l.resultDate, DateFormat.yMMMEd(locale).format(addDays(_start, _subtract ? -days : days))),
          ]),
      ]);
    }

    return ToolScaffold(tool: Tool.date, title: l.toolDate, body: FormList(children: children));
  }
}
