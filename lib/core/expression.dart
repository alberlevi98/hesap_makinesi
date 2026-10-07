import 'dart:math' as math;

/// Thrown when an expression cannot be evaluated.
class ExpressionError implements Exception {
  const ExpressionError(this.message);
  final String message;

  @override
  String toString() => 'ExpressionError: $message';
}

enum AngleMode { degrees, radians }

/// Evaluates calculator expressions.
///
/// Supported syntax:
/// * numbers with `.` as decimal separator
/// * `+ - × ÷ * /`, unary minus, parentheses, `^` (power)
/// * postfix `%` and `!` (factorial)
/// * `√` (square root), `∛` (cube root)
/// * functions `sin cos tan asin acos atan ln log`
/// * constants `π` and `e`
/// * implicit multiplication: `2π`, `3(4+1)`, `(1+1)(2+2)`
///
/// Percent follows the usual pocket-calculator convention:
/// `a + b%` = `a + a·b/100`, `a - b%` = `a - a·b/100`, otherwise `b%` = `b/100`.
/// Unclosed parentheses are closed automatically.
class ExpressionEvaluator {
  ExpressionEvaluator({this.angleMode = AngleMode.degrees});

  final AngleMode angleMode;

  late List<_Token> _tokens;
  int _pos = 0;

  double evaluate(String input) {
    _tokens = _tokenize(input);
    _pos = 0;
    if (_tokens.isEmpty) throw const ExpressionError('empty');
    final result = _parseExpression().value;
    if (_pos < _tokens.length) {
      throw ExpressionError('unexpected ${_tokens[_pos].text}');
    }
    if (result.isNaN || result.isInfinite) {
      throw const ExpressionError('undefined');
    }
    return _cleanup(result);
  }

  /// Removes floating point noise such as `0.1+0.2 = 0.30000000000000004`
  /// and `sin(180°) = 1.2e-16`.
  static double _cleanup(double v) {
    if (v.abs() < 1e-12) return 0;
    final rounded = double.parse(v.toStringAsPrecision(12));
    return rounded;
  }

  // expression := term (('+' | '-') term)*
  _Value _parseExpression() {
    var left = _parseTerm();
    while (_peekIs('+') || _peekIs('-')) {
      final op = _next().text;
      final right = _parseTerm();
      final rightValue =
          right.isPercent ? left.value * right.percentOf : right.value;
      left = _Value(op == '+' ? left.value + rightValue : left.value - rightValue);
    }
    return left;
  }

  // term := power (('*' | '/' | implicit) power)*
  _Value _parseTerm() {
    var left = _parseUnary();
    while (true) {
      if (_peekIs('*') || _peekIs('/')) {
        final op = _next().text;
        final right = _parseUnary().value;
        if (op == '*') {
          left = _Value(left.value * right);
        } else {
          if (right == 0) throw const ExpressionError('division by zero');
          left = _Value(left.value / right);
        }
      } else if (_startsOperand()) {
        // Implicit multiplication, e.g. 2π or 3(1+2).
        final right = _parseUnary().value;
        left = _Value(left.value * right);
      } else {
        return left;
      }
    }
  }

  // unary := ('-' | '+') unary | power
  _Value _parseUnary() {
    if (_peekIs('-')) {
      _next();
      final v = _parseUnary();
      return _Value(-v.value, percentOf: -v.percentOf, isPercent: v.isPercent);
    }
    if (_peekIs('+')) {
      _next();
      return _parseUnary();
    }
    return _parsePower();
  }

  // power := postfix ('^' unary)?   (right associative)
  _Value _parsePower() {
    final base = _parsePostfix();
    if (_peekIs('^')) {
      _next();
      final exponent = _parseUnary().value;
      return _Value(math.pow(base.value, exponent).toDouble());
    }
    return base;
  }

  // postfix := primary ('!' | '%')*
  _Value _parsePostfix() {
    var v = _parsePrimary();
    while (_peekIs('!') || _peekIs('%')) {
      final op = _next().text;
      if (op == '!') {
        v = _Value(_factorial(v.value));
      } else {
        v = _Value(v.value / 100, percentOf: v.value / 100, isPercent: true);
      }
    }
    return v;
  }

  _Value _parsePrimary() {
    if (_pos >= _tokens.length) throw const ExpressionError('incomplete');
    final t = _next();
    switch (t.type) {
      case _TokenType.number:
        return _Value(t.number!);
      case _TokenType.constant:
        return _Value(t.text == 'π' ? math.pi : math.e);
      case _TokenType.lparen:
        final inner = _parseExpression();
        if (_peekIs(')')) _next(); // auto-close missing parentheses
        return _Value(inner.value);
      case _TokenType.function:
        final arg = _parseUnaryArgument();
        return _Value(_applyFunction(t.text, arg));
      default:
        throw ExpressionError('unexpected ${t.text}');
    }
  }

  /// Function arguments bind tightly: `√4+1` is `√(4)+1`, `sin30` is `sin(30)`.
  double _parseUnaryArgument() {
    if (_peekIs('-')) {
      _next();
      return -_parseUnaryArgument();
    }
    return _parsePower().value;
  }

  double _applyFunction(String name, double x) {
    double toRad(double v) => angleMode == AngleMode.degrees ? v * math.pi / 180 : v;
    double fromRad(double v) => angleMode == AngleMode.degrees ? v * 180 / math.pi : v;
    switch (name) {
      case '√':
        if (x < 0) throw const ExpressionError('domain');
        return math.sqrt(x);
      case '∛':
        return x < 0 ? -math.pow(-x, 1 / 3).toDouble() : math.pow(x, 1 / 3).toDouble();
      case 'sin':
        return math.sin(toRad(x));
      case 'cos':
        return math.cos(toRad(x));
      case 'tan':
        final c = math.cos(toRad(x));
        if (c.abs() < 1e-12) throw const ExpressionError('domain');
        return math.sin(toRad(x)) / c;
      case 'asin':
        if (x.abs() > 1) throw const ExpressionError('domain');
        return fromRad(math.asin(x));
      case 'acos':
        if (x.abs() > 1) throw const ExpressionError('domain');
        return fromRad(math.acos(x));
      case 'atan':
        return fromRad(math.atan(x));
      case 'ln':
        if (x <= 0) throw const ExpressionError('domain');
        return math.log(x);
      case 'log':
        if (x <= 0) throw const ExpressionError('domain');
        return math.log(x) / math.ln10;
    }
    throw ExpressionError('unknown function $name');
  }

  static double _factorial(double n) {
    if (n < 0 || n != n.roundToDouble() || n > 170) {
      throw const ExpressionError('domain');
    }
    var r = 1.0;
    for (var i = 2; i <= n; i++) {
      r *= i;
    }
    return r;
  }

  bool _peekIs(String text) => _pos < _tokens.length && _tokens[_pos].text == text;

  bool _startsOperand() {
    if (_pos >= _tokens.length) return false;
    final t = _tokens[_pos].type;
    return t == _TokenType.number ||
        t == _TokenType.constant ||
        t == _TokenType.lparen ||
        t == _TokenType.function;
  }

  _Token _next() => _tokens[_pos++];

  static const _functions = ['asin', 'acos', 'atan', 'sin', 'cos', 'tan', 'ln', 'log'];

  static List<_Token> _tokenize(String input) {
    final tokens = <_Token>[];
    var i = 0;
    while (i < input.length) {
      final c = input[i];
      if (c == ' ') {
        i++;
        continue;
      }
      if (_isDigit(c) || c == '.') {
        final start = i;
        while (i < input.length && (_isDigit(input[i]) || input[i] == '.')) {
          i++;
        }
        // Scientific notation produced by results, e.g. 1.5e-7.
        if (i < input.length &&
            input[i] == 'E' &&
            i + 1 < input.length &&
            (_isDigit(input[i + 1]) || input[i + 1] == '-' || input[i + 1] == '+')) {
          i += 2;
          while (i < input.length && _isDigit(input[i])) {
            i++;
          }
        }
        final text = input.substring(start, i);
        final value = double.tryParse(text.replaceAll('E', 'e'));
        if (value == null) throw ExpressionError('bad number $text');
        tokens.add(_Token(_TokenType.number, text, value));
        continue;
      }
      final fn = _functions.where((f) => input.startsWith(f, i)).firstOrNull;
      if (fn != null) {
        tokens.add(_Token(_TokenType.function, fn));
        i += fn.length;
        continue;
      }
      switch (c) {
        case '+':
        case '-':
        case '−':
          tokens.add(_Token(_TokenType.op, c == '−' ? '-' : c));
        case '*':
        case '×':
          tokens.add(const _Token(_TokenType.op, '*'));
        case '/':
        case '÷':
          tokens.add(const _Token(_TokenType.op, '/'));
        case '^':
        case '%':
        case '!':
          tokens.add(_Token(_TokenType.op, c));
        case '(':
          tokens.add(const _Token(_TokenType.lparen, '('));
        case ')':
          tokens.add(const _Token(_TokenType.rparen, ')'));
        case 'π':
        case 'e':
          tokens.add(_Token(_TokenType.constant, c));
        case '√':
        case '∛':
          tokens.add(_Token(_TokenType.function, c));
        default:
          throw ExpressionError('unexpected $c');
      }
      i++;
    }
    return tokens;
  }

  static bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
}

enum _TokenType { number, op, lparen, rparen, function, constant }

class _Token {
  const _Token(this.type, this.text, [this.number]);
  final _TokenType type;
  final String text;
  final double? number;
}

class _Value {
  const _Value(this.value, {this.percentOf = 0, this.isPercent = false});
  final double value;

  /// For `b%`, the fraction b/100 used when applied to a left operand.
  final double percentOf;
  final bool isPercent;
}
