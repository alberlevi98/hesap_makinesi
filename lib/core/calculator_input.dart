import 'expression.dart';

/// Editing logic for the calculator display. The expression is kept in a
/// raw form using `.` as decimal separator and `× ÷ - +` as operators.
class CalculatorInput {
  String expression = '';

  /// True right after `=`: typing a digit starts a new expression,
  /// typing an operator continues from the result.
  bool justEvaluated = false;

  static const _operators = ['+', '-', '×', '÷', '^'];
  static const _functionTokens = [
    'asin(', 'acos(', 'atan(', 'sin(', 'cos(', 'tan(', 'ln(', 'log(', '√(', '∛(',
  ];

  String get _last => expression.isEmpty ? '' : expression[expression.length - 1];

  bool get _endsWithOperand =>
      expression.isNotEmpty && (RegExp(r'[0-9.)%!πe]$').hasMatch(expression) && !_endsWithExponentMarker);

  bool get _endsWithExponentMarker => RegExp(r'[0-9]E[+-]?$').hasMatch(expression);

  void _startFreshIfNeeded() {
    if (justEvaluated) {
      expression = '';
      justEvaluated = false;
    }
  }

  void digit(String d) {
    _startFreshIfNeeded();
    if (RegExp(r'[)%!πe]$').hasMatch(expression)) expression += '×';
    // Avoid leading zeros like "007".
    final current = RegExp(r'[0-9.]*$').stringMatch(expression) ?? '';
    if (current == '0') {
      expression = expression.substring(0, expression.length - 1);
    }
    expression += d;
  }

  void decimalPoint() {
    _startFreshIfNeeded();
    final current = RegExp(r'[0-9.]*$').stringMatch(expression) ?? '';
    if (current.contains('.')) return;
    if (current.isEmpty) {
      if (RegExp(r'[)%!πe]$').hasMatch(expression)) expression += '×';
      expression += '0';
    }
    expression += '.';
  }

  void operator(String op) {
    justEvaluated = false;
    if (expression.isEmpty) {
      if (op == '-') expression = '-';
      return;
    }
    if (expression.endsWith('(')) {
      if (op == '-') expression += '-';
      return;
    }
    if (_operators.contains(_last)) {
      if (expression.length == 1) return; // lone leading minus
      expression = expression.substring(0, expression.length - 1) + op;
      return;
    }
    if (_last == '.') expression += '0';
    expression += op;
  }

  void percent() {
    justEvaluated = false;
    if (_endsWithOperand && _last != '%') expression += '%';
  }

  void factorial() {
    justEvaluated = false;
    if (_endsWithOperand) expression += '!';
  }

  void square() {
    justEvaluated = false;
    if (_endsWithOperand) expression += '^2';
  }

  void constant(String c) {
    _startFreshIfNeeded();
    if (_endsWithOperand) expression += '×';
    expression += c;
  }

  void function(String name) {
    _startFreshIfNeeded();
    if (_endsWithOperand) expression += '×';
    expression += '$name(';
  }

  /// Inserts `(` or `)` depending on context.
  void parenthesis() {
    _startFreshIfNeeded();
    final open = '('.allMatches(expression).length - ')'.allMatches(expression).length;
    if (open > 0 && _endsWithOperand) {
      expression += ')';
    } else {
      if (_endsWithOperand) expression += '×';
      expression += '(';
    }
  }

  /// Toggles the sign of the number at the end of the expression.
  void toggleSign() {
    justEvaluated = false;
    final match = RegExp(r'[0-9.]+(E[+-]?[0-9]+)?$').firstMatch(expression);
    if (match == null) {
      if (expression.endsWith('(-')) {
        expression = expression.substring(0, expression.length - 2);
      } else if (expression.isEmpty || expression.endsWith('(') || _operators.contains(_last)) {
        expression += '(-';
      }
      return;
    }
    final start = match.start;
    final before = expression.substring(0, start);
    final number = expression.substring(start);
    if (before.endsWith('(-')) {
      expression = before.substring(0, before.length - 2) + number;
    } else if (before == '-') {
      expression = number;
    } else {
      expression = '$before(-$number';
    }
  }

  void backspace() {
    justEvaluated = false;
    if (expression.isEmpty) return;
    for (final f in _functionTokens) {
      if (expression.endsWith(f)) {
        expression = expression.substring(0, expression.length - f.length);
        return;
      }
    }
    expression = expression.substring(0, expression.length - 1);
  }

  void clear() {
    expression = '';
    justEvaluated = false;
  }

  /// Replaces the expression (e.g. from history).
  void load(String value) {
    expression = value;
    justEvaluated = true;
  }

  /// Returns the value, or null when the expression is incomplete/invalid.
  double? tryEvaluate(AngleMode mode) {
    if (expression.isEmpty) return null;
    try {
      return ExpressionEvaluator(angleMode: mode).evaluate(expression);
    } on ExpressionError {
      return null;
    }
  }

  /// Whether a live preview is worth showing (i.e. there is an operation).
  bool get hasOperation =>
      RegExp(r'[+×÷^%!(√∛πa-z]|.-').hasMatch(expression) && !RegExp(r'^-?[0-9.]+(E[+-]?[0-9]+)?$').hasMatch(expression);
}

/// Converts a result to the raw expression form used by [CalculatorInput].
String rawNumber(double v) {
  if (v == v.roundToDouble() && v.abs() < 1e15) return v.toInt().toString();
  return v.toString().replaceAll('e', 'E');
}
