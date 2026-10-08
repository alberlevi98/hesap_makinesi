import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_settings.dart';
import '../core/calculator_input.dart';
import '../core/expression.dart';
import '../widgets/app_drawer.dart';
import '../widgets/common.dart';
import 'history_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _input = CalculatorInput();
  bool _error = false;

  void _apply(void Function() edit) {
    HapticFeedback.selectionClick();
    setState(() {
      _error = false;
      edit();
    });
  }

  void _equals() {
    final settings = SettingsScope.of(context);
    HapticFeedback.selectionClick();
    if (_input.expression.isEmpty) return;
    final value = _input.tryEvaluate(settings.angleMode);
    setState(() {
      if (value == null) {
        _error = true;
        return;
      }
      final raw = rawNumber(value);
      settings.addHistory(_input.expression, raw);
      _input.load(raw);
    });
  }

  Future<void> _openHistory() async {
    final expression = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const HistoryScreen()),
    );
    if (expression != null) {
      setState(() {
        _error = false;
        _input.load(expression);
        _input.justEvaluated = false;
      });
    }
  }

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.copied), duration: const Duration(seconds: 1)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final settings = SettingsScope.of(context);
    final numbers = context.numbers;
    final scheme = Theme.of(context).colorScheme;

    final preview = _input.hasOperation && !_input.justEvaluated ? _input.tryEvaluate(settings.angleMode) : null;
    final shownExpression = _input.expression.isEmpty ? '0' : numbers.displayExpression(_input.expression);
    final evaluatedValue = _input.justEvaluated ? double.tryParse(_input.expression) : null;
    final mainText = evaluatedValue != null ? numbers.format(evaluatedValue) : shownExpression;

    return ToolScaffold(
      tool: Tool.calculator,
      title: l.toolCalculator,
      actions: [
        IconButton(
          key: const Key('historyButton'),
          tooltip: l.history,
          onPressed: _openHistory,
          icon: const Icon(Icons.history),
        ),
      ],
      body: Directionality(
        // Math is written left-to-right in every language, including Arabic and Urdu.
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            Expanded(
              flex: settings.scientific ? 3 : 4,
              child: GestureDetector(
                onLongPress: () => _copy(mainText),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  alignment: Alignment.bottomRight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: SingleChildScrollView(
                          reverse: true,
                          child: _ExpressionText(
                            key: const Key('display'),
                            text: mainText,
                            color: scheme.onSurface,
                            accent: scheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 36,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            _error ? l.error : (preview != null ? '= ${numbers.format(preview)}' : ''),
                            key: const Key('preview'),
                            style: TextStyle(
                              fontSize: 28,
                              color: _error ? scheme.error : scheme.outline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _toolbar(context, settings),
            Expanded(
              flex: settings.scientific ? 8 : 6,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Column(children: [
                  if (settings.scientific) ..._scientificRows(context, settings),
                  ..._basicRows(context, numbers.decimalSeparator),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolbar(BuildContext context, AppSettings settings) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: Row(
        children: [
          // Chips take the remaining width (and shrink for long labels);
          // the backspace button stays at the trailing edge above ÷.
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: ActionChip(
                    key: const Key('modeToggle'),
                    avatar: Icon(settings.scientific ? Icons.functions : Icons.calculate_outlined, size: 18),
                    label: Text(
                      settings.scientific ? l.modeScientific : l.modeBasic,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: () => settings.setScientific(!settings.scientific),
                  ),
                ),
                if (settings.scientific) ...[
                  const SizedBox(width: 8),
                  ActionChip(
                    key: const Key('angleToggle'),
                    label: Text(settings.angleMode == AngleMode.degrees ? 'DEG' : 'RAD'),
                    onPressed: () => settings.setAngleMode(
                        settings.angleMode == AngleMode.degrees ? AngleMode.radians : AngleMode.degrees),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            key: const Key('backspace'),
            onPressed: () => _apply(_input.backspace),
            onLongPress: () => _apply(_input.clear),
            icon: const Icon(Icons.backspace_outlined),
            color: scheme.primary,
          ),
        ],
      ),
    );
  }

  List<Widget> _scientificRows(BuildContext context, AppSettings settings) {
    Widget fn(String label, void Function() action) => _Key(label: label, kind: _KeyKind.function, onTap: () => _apply(action));
    return [
      _row([
        fn('sin', () => _input.function('sin')),
        fn('cos', () => _input.function('cos')),
        fn('tan', () => _input.function('tan')),
        fn('ln', () => _input.function('ln')),
        fn('log', () => _input.function('log')),
      ]),
      _row([
        fn('sin⁻¹', () => _input.function('asin')),
        fn('cos⁻¹', () => _input.function('acos')),
        fn('tan⁻¹', () => _input.function('atan')),
        fn('√', () => _input.function('√')),
        fn('∛', () => _input.function('∛')),
      ]),
      _row([
        fn('x²', _input.square),
        fn('xʸ', () => _input.operator('^')),
        fn('x!', _input.factorial),
        fn('π', () => _input.constant('π')),
        fn('e', () => _input.constant('e')),
      ]),
    ];
  }

  List<Widget> _basicRows(BuildContext context, String decimalSeparator) {
    Widget d(String digit) => _Key(label: digit, onTap: () => _apply(() => _input.digit(digit)));
    Widget op(String label, String value) =>
        _Key(label: label, kind: _KeyKind.operator, onTap: () => _apply(() => _input.operator(value)));
    return [
      _row([
        _Key(label: 'AC', kind: _KeyKind.clear, onTap: () => _apply(_input.clear)),
        _Key(label: '( )', kind: _KeyKind.operator, onTap: () => _apply(_input.parenthesis)),
        _Key(label: '%', kind: _KeyKind.operator, onTap: () => _apply(_input.percent)),
        op('÷', '÷'),
      ]),
      _row([d('7'), d('8'), d('9'), op('×', '×')]),
      _row([d('4'), d('5'), d('6'), op('−', '-')]),
      _row([d('1'), d('2'), d('3'), op('+', '+')]),
      _row([
        _Key(label: '+/−', onTap: () => _apply(_input.toggleSign)),
        d('0'),
        _Key(label: decimalSeparator, onTap: () => _apply(_input.decimalPoint)),
        _Key(key: const Key('equals'), label: '=', kind: _KeyKind.equals, onTap: _equals),
      ]),
    ];
  }

  Widget _row(List<Widget> keys) => Expanded(child: Row(children: [for (final k in keys) Expanded(child: k)]));
}

/// Display text with operators tinted in the accent color.
class _ExpressionText extends StatelessWidget {
  const _ExpressionText({super.key, required this.text, required this.color, required this.accent});
  final String text;
  final Color color;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final length = text.length;
    final size = length <= 8 ? 64.0 : length <= 12 ? 52.0 : length <= 18 ? 40.0 : 32.0;
    final spans = <TextSpan>[];
    for (final ch in text.characters) {
      final isOp = '+−×÷^%()!√∛'.contains(ch);
      spans.add(TextSpan(text: ch, style: TextStyle(color: isOp ? accent : color)));
    }
    return Text.rich(
      TextSpan(children: spans),
      textAlign: TextAlign.right,
      style: TextStyle(fontSize: size, fontWeight: FontWeight.w600, height: 1.15),
    );
  }
}

enum _KeyKind { digit, operator, function, clear, equals }

class _Key extends StatelessWidget {
  const _Key({super.key, required this.label, required this.onTap, this.kind = _KeyKind.digit});

  final String label;
  final VoidCallback onTap;
  final _KeyKind kind;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (kind) {
      _KeyKind.digit => (scheme.surfaceContainerHigh, scheme.onSurface),
      _KeyKind.operator => (scheme.secondaryContainer, scheme.onSecondaryContainer),
      _KeyKind.function => (scheme.surfaceContainer, scheme.primary),
      _KeyKind.clear => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      _KeyKind.equals => (scheme.primary, scheme.onPrimary),
    };
    final fontSize = kind == _KeyKind.function ? 18.0 : 28.0;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(kind == _KeyKind.equals ? 24 : 999),
        child: InkWell(
          borderRadius: BorderRadius.circular(kind == _KeyKind.equals ? 24 : 999),
          onTap: onTap,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Text(label, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500, color: fg)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
