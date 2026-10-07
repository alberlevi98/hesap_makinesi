import 'package:flutter/material.dart';

import '../core/number_format.dart';
import '../core/units.dart';
import '../l10n/app_localizations.dart';
import '../widgets/app_drawer.dart';
import '../widgets/common.dart';

class UnitScreen extends StatefulWidget {
  const UnitScreen({super.key});

  @override
  State<UnitScreen> createState() => _UnitScreenState();
}

class _UnitScreenState extends State<UnitScreen> {
  UnitCategory _category = UnitCategory.length;
  late Unit _from;
  late Unit _to;
  final _value = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _selectCategory(UnitCategory.length);
  }

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  void _selectCategory(UnitCategory c) {
    final list = units[c]!;
    _category = c;
    // Pick a sensible default pair: the first metric unit and its common counterpart.
    final defaults = switch (c) {
      UnitCategory.length => ('centimeter', 'inch'),
      UnitCategory.area => ('squareMeter', 'squareFoot'),
      UnitCategory.volume => ('liter', 'gallonUs'),
      UnitCategory.mass => ('kilogram', 'pound'),
      UnitCategory.temperature => ('celsius', 'fahrenheit'),
      UnitCategory.speed => ('kilometerPerHour', 'milePerHour'),
      UnitCategory.time => ('hour', 'minute'),
      UnitCategory.data => ('gigabyte', 'megabyte'),
    };
    _from = list.firstWhere((u) => u.id == defaults.$1);
    _to = list.firstWhere((u) => u.id == defaults.$2);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final numbers = context.numbers;
    final scheme = Theme.of(context).colorScheme;
    final input = parseUserNumber(_value.text);
    final output = input == null ? null : convert(input, _from, _to);
    final unitList = units[_category]!;

    return ToolScaffold(
      tool: Tool.units,
      title: l.toolUnitConverter,
      body: FormList(children: [
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final c in UnitCategory.values)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ChoiceChip(
                    label: Text(categoryName(l, c)),
                    selected: c == _category,
                    onSelected: (_) => setState(() => _selectCategory(c)),
                  ),
                ),
            ],
          ),
        ),
        _unitDropdown(l, unitList, _from, (u) => setState(() => _from = u)),
        NumberField(
          key: const Key('unitInput'),
          label: _from.symbol,
          controller: _value,
          allowDecimal: true,
          onChanged: (_) => setState(() {}),
        ),
        Center(
          child: IconButton.filledTonal(
            tooltip: l.swap,
            icon: const Icon(Icons.swap_vert),
            onPressed: () => setState(() {
              final t = _from;
              _from = _to;
              _to = t;
              if (output != null) _value.text = rawInput(output);
            }),
          ),
        ),
        _unitDropdown(l, unitList, _to, (u) => setState(() => _to = u)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    output == null ? '—' : numbers.format(output, maxFractionDigits: 8),
                    key: const Key('unitOutput'),
                    textDirection: TextDirection.ltr,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: scheme.onPrimaryContainer),
                  ),
                ),
              ),
              Text(_to.symbol, style: TextStyle(fontSize: 18, color: scheme.onPrimaryContainer)),
            ],
          ),
        ),
        Text(
          '1 ${_from.symbol} = ${numbers.format(convert(1, _from, _to), maxFractionDigits: 8)} ${_to.symbol}',
          textAlign: TextAlign.end,
          textDirection: TextDirection.ltr,
          style: TextStyle(color: scheme.outline),
        ),
      ]),
    );
  }

  Widget _unitDropdown(AppLocalizations l, List<Unit> list, Unit value, ValueChanged<Unit> onChanged) {
    return DropdownButtonFormField<Unit>(
      initialValue: value,
      key: ValueKey('${_category.name}-${value.id}-${identityHashCode(list)}'),
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
      items: [
        for (final u in list)
          DropdownMenuItem(value: u, child: Text('${unitName(l, u.id)} (${u.symbol})', overflow: TextOverflow.ellipsis)),
      ],
      onChanged: (u) {
        if (u != null) onChanged(u);
      },
    );
  }
}

/// Plain number for putting a result back into an input field.
String rawInput(double v) {
  final s = v.toStringAsPrecision(10);
  final d = double.parse(s);
  if (d == d.roundToDouble() && d.abs() < 1e15) return d.toInt().toString();
  return d.toString();
}

String categoryName(AppLocalizations l, UnitCategory c) => switch (c) {
      UnitCategory.length => l.unitCatLength,
      UnitCategory.area => l.unitCatArea,
      UnitCategory.volume => l.unitCatVolume,
      UnitCategory.mass => l.unitCatMass,
      UnitCategory.temperature => l.unitCatTemperature,
      UnitCategory.speed => l.unitCatSpeed,
      UnitCategory.time => l.unitCatTime,
      UnitCategory.data => l.unitCatData,
    };

String unitName(AppLocalizations l, String id) => switch (id) {
      'millimeter' => l.unit_millimeter,
      'centimeter' => l.unit_centimeter,
      'meter' => l.unit_meter,
      'kilometer' => l.unit_kilometer,
      'inch' => l.unit_inch,
      'foot' => l.unit_foot,
      'yard' => l.unit_yard,
      'mile' => l.unit_mile,
      'nauticalMile' => l.unit_nauticalMile,
      'squareCentimeter' => l.unit_squareCentimeter,
      'squareMeter' => l.unit_squareMeter,
      'hectare' => l.unit_hectare,
      'squareKilometer' => l.unit_squareKilometer,
      'squareFoot' => l.unit_squareFoot,
      'acre' => l.unit_acre,
      'squareMile' => l.unit_squareMile,
      'milliliter' => l.unit_milliliter,
      'liter' => l.unit_liter,
      'cubicMeter' => l.unit_cubicMeter,
      'teaspoon' => l.unit_teaspoon,
      'tablespoon' => l.unit_tablespoon,
      'cup' => l.unit_cup,
      'fluidOunce' => l.unit_fluidOunce,
      'gallonUs' => l.unit_gallonUs,
      'gallonUk' => l.unit_gallonUk,
      'milligram' => l.unit_milligram,
      'gram' => l.unit_gram,
      'kilogram' => l.unit_kilogram,
      'tonne' => l.unit_tonne,
      'ounce' => l.unit_ounce,
      'pound' => l.unit_pound,
      'stone' => l.unit_stone,
      'celsius' => l.unit_celsius,
      'fahrenheit' => l.unit_fahrenheit,
      'kelvin' => l.unit_kelvin,
      'meterPerSecond' => l.unit_meterPerSecond,
      'kilometerPerHour' => l.unit_kilometerPerHour,
      'milePerHour' => l.unit_milePerHour,
      'knot' => l.unit_knot,
      'second' => l.unit_second,
      'minute' => l.unit_minute,
      'hour' => l.unit_hour,
      'day' => l.unit_day,
      'week' => l.unit_week,
      'year' => l.unit_year,
      'byte' => l.unit_byte,
      'kilobyte' => l.unit_kilobyte,
      'megabyte' => l.unit_megabyte,
      'gigabyte' => l.unit_gigabyte,
      'terabyte' => l.unit_terabyte,
      _ => id,
    };
