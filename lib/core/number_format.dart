import 'package:intl/intl.dart';

/// Locale-aware number formatting that always uses Western digits (0-9),
/// so results match the calculator keypad, but keeps the locale's decimal
/// and grouping separators (e.g. `1,234.5`, `1.234,5`, `12,34,567`).
class LocaleNumbers {
  LocaleNumbers(String locale)
      : _locale = Intl.verifiedLocale(locale, NumberFormat.localeExists,
                onFailure: (_) => 'en') ??
            'en' {
    final symbols = NumberFormat.decimalPattern(_locale).symbols;
    decimalSeparator = symbols.DECIMAL_SEP;
    groupSeparator = symbols.GROUP_SEP;
    _zeroDigit = symbols.ZERO_DIGIT;
  }

  final String _locale;
  late final String decimalSeparator;
  late final String groupSeparator;
  late final String _zeroDigit;

  /// Formats a calculator result with up to [maxFractionDigits] decimals.
  /// Very large or very small values use scientific notation.
  String format(double value, {int maxFractionDigits = 10}) {
    if (value.isNaN || value.isInfinite) return '—';
    final abs = value.abs();
    if (abs != 0 && (abs >= 1e15 || abs < 1e-9)) {
      final s = value.toStringAsExponential(8);
      final parts = s.split('e');
      var mantissa = parts[0];
      if (mantissa.contains('.')) {
        mantissa = mantissa.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
      }
      return '${mantissa.replaceAll('.', decimalSeparator)}E${parts[1].replaceFirst('+', '')}';
    }
    final f = NumberFormat.decimalPattern(_locale)
      ..minimumFractionDigits = 0
      ..maximumFractionDigits = maxFractionDigits;
    return _toWestern(f.format(value));
  }

  /// Formats money-like values with exactly two decimals.
  String money(double value) {
    final f = NumberFormat.decimalPattern(_locale)
      ..minimumFractionDigits = 2
      ..maximumFractionDigits = 2;
    return _toWestern(f.format(value));
  }

  /// Formats an integer count (e.g. days) with grouping.
  String integer(num value) => _toWestern(NumberFormat.decimalPattern(_locale).format(value));

  /// Shows a raw calculator expression (which uses `.` internally) with the
  /// locale decimal separator, e.g. `3.5×2` → `3,5×2` in Turkish.
  /// Integer parts are grouped and `-` is shown as a proper minus sign.
  String displayExpression(String expression) {
    final grouped = expression.replaceAllMapped(RegExp(r'(?<![0-9.E])([0-9]+)(\.[0-9]*)?'), (m) {
      final intPart = m[1]!;
      final frac = m[2] ?? '';
      final groupedInt = intPart.length > 3 && intPart.length <= 18
          ? integer(int.parse(intPart))
          : intPart;
      return groupedInt + frac.replaceFirst('.', decimalSeparator);
    });
    return grouped.replaceAll('-', '−');
  }

  String _toWestern(String s) {
    if (_zeroDigit == '0') return s;
    final zero = _zeroDigit.codeUnitAt(0);
    return String.fromCharCodes(s.codeUnits.map((c) => c >= zero && c <= zero + 9 ? 48 + c - zero : c));
  }
}

/// Parses user input that may use either `.` or `,` as decimal separator.
/// Returns null for empty or invalid input.
double? parseUserNumber(String input) {
  var s = input.trim().replaceAll(' ', '').replaceAll(' ', '').replaceAll(' ', '');
  if (s.isEmpty) return null;
  final lastDot = s.lastIndexOf('.');
  final lastComma = s.lastIndexOf(',');
  if (lastDot >= 0 && lastComma >= 0) {
    // Both present: the last one is the decimal separator.
    if (lastComma > lastDot) {
      s = s.replaceAll('.', '').replaceAll(',', '.');
    } else {
      s = s.replaceAll(',', '');
    }
  } else if (lastComma >= 0) {
    s = s.replaceAll(',', '.');
  }
  return double.tryParse(s);
}
