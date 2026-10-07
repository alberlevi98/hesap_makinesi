import 'package:flutter/material.dart';

import '../core/number_format.dart';
import '../widgets/app_drawer.dart';
import '../widgets/common.dart';

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  bool _imperial = false;
  final _heightCm = TextEditingController();
  final _weightKg = TextEditingController();
  final _feet = TextEditingController();
  final _inches = TextEditingController();
  final _pounds = TextEditingController();

  @override
  void dispose() {
    for (final c in [_heightCm, _weightKg, _feet, _inches, _pounds]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _bmi() {
    double? heightM;
    double? weightKg;
    if (_imperial) {
      final ft = parseUserNumber(_feet.text) ?? 0;
      final inch = parseUserNumber(_inches.text) ?? 0;
      final totalIn = ft * 12 + inch;
      heightM = totalIn > 0 ? totalIn * 0.0254 : null;
      final lb = parseUserNumber(_pounds.text);
      weightKg = lb == null ? null : lb * 0.45359237;
    } else {
      final cm = parseUserNumber(_heightCm.text);
      heightM = cm == null || cm <= 0 ? null : cm / 100;
      weightKg = parseUserNumber(_weightKg.text);
    }
    if (heightM == null || weightKg == null || weightKg <= 0) return null;
    return weightKg / (heightM * heightM);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final n = context.numbers;
    final scheme = Theme.of(context).colorScheme;
    void refresh(String _) => setState(() {});
    final bmi = _bmi();

    final (category, color) = switch (bmi) {
      null => ('', scheme.outline),
      < 18.5 => (l.bmiUnderweight, Colors.blue.shade600),
      < 25 => (l.bmiNormal, Colors.green.shade600),
      < 30 => (l.bmiOverweight, Colors.orange.shade700),
      _ => (l.bmiObese, Colors.red.shade600),
    };

    return ToolScaffold(
      tool: Tool.bmi,
      title: l.toolBmi,
      body: FormList(children: [
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(value: false, label: Text(l.metric)),
            ButtonSegment(value: true, label: Text(l.imperial)),
          ],
          selected: {_imperial},
          onSelectionChanged: (s) => setState(() => _imperial = s.first),
        ),
        if (!_imperial) ...[
          NumberField(label: l.height, controller: _heightCm, suffix: 'cm', onChanged: refresh),
          NumberField(label: l.weight, controller: _weightKg, suffix: 'kg', onChanged: refresh),
        ] else ...[
          Row(children: [
            Expanded(child: NumberField(label: l.height, controller: _feet, suffix: 'ft', onChanged: refresh)),
            const SizedBox(width: 12),
            Expanded(child: NumberField(label: '', controller: _inches, suffix: 'in', onChanged: refresh)),
          ]),
          NumberField(label: l.weight, controller: _pounds, suffix: 'lb', onChanged: refresh),
        ],
        if (bmi == null)
          const EmptyResults()
        else
          Card(
            elevation: 0,
            color: scheme.primaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                Text(l.yourBmi, style: TextStyle(color: scheme.onPrimaryContainer)),
                Text(n.format(bmi, maxFractionDigits: 1),
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: color)),
                Text(category, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: color)),
                const SizedBox(height: 16),
                _Gauge(bmi: bmi),
              ]),
            ),
          ),
        Text(l.bmiNote, style: TextStyle(color: scheme.outline, fontSize: 12), textAlign: TextAlign.center),
      ]),
    );
  }
}

/// Horizontal band 15–40 with WHO thresholds and a marker for the value.
class _Gauge extends StatelessWidget {
  const _Gauge({required this.bmi});
  final double bmi;

  @override
  Widget build(BuildContext context) {
    const min = 15.0, max = 40.0;
    final pos = ((bmi.clamp(min, max) - min) / (max - min));
    return Directionality(
      textDirection: TextDirection.ltr,
      child: LayoutBuilder(builder: (context, c) {
        final w = c.maxWidth;
        double x(double v) => (v - min) / (max - min) * w;
        return SizedBox(
          height: 28,
          child: Stack(children: [
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              height: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  SizedBox(width: x(18.5), child: ColoredBox(color: Colors.blue.shade400)),
                  SizedBox(width: x(25) - x(18.5), child: ColoredBox(color: Colors.green.shade400)),
                  SizedBox(width: x(30) - x(25), child: ColoredBox(color: Colors.orange.shade400)),
                  Expanded(child: ColoredBox(color: Colors.red.shade400)),
                ]),
              ),
            ),
            Positioned(
              left: (pos * w - 3).clamp(0, w - 6),
              top: 2,
              child: Container(
                width: 6,
                height: 24,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ]),
        );
      }),
    );
  }
}
