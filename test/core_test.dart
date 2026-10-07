import 'package:flutter_test/flutter_test.dart';
import 'package:hesap_makinesi/core/calculator_input.dart';
import 'package:hesap_makinesi/core/dates.dart';
import 'package:hesap_makinesi/core/expression.dart';
import 'package:hesap_makinesi/core/loan.dart';
import 'package:hesap_makinesi/core/number_format.dart';
import 'package:hesap_makinesi/core/units.dart';

double eval(String s, [AngleMode m = AngleMode.degrees]) => ExpressionEvaluator(angleMode: m).evaluate(s);

void main() {
  group('ExpressionEvaluator', () {
    test('basic arithmetic and precedence', () {
      expect(eval('2+3×4'), 14);
      expect(eval('(2+3)×4'), 20);
      expect(eval('10÷4'), 2.5);
      expect(eval('-5+2'), -3);
      expect(eval('2^3^2'), 512);
      expect(eval('-2^2'), -4);
      expect(eval('0.1+0.2'), 0.3);
    });

    test('percent follows calculator convention', () {
      expect(eval('9+5%'), closeTo(9.45, 1e-12));
      expect(eval('200-10%'), 180);
      expect(eval('50×10%'), 5);
      expect(eval('5%'), 0.05);
      expect(eval('200÷50%'), 400);
    });

    test('scientific functions', () {
      expect(eval('sin(30)'), closeTo(0.5, 1e-12));
      expect(eval('sin(π)', AngleMode.radians), 0);
      expect(eval('cos(π)+tan(π÷4)', AngleMode.radians), closeTo(0, 1e-12));
      expect(eval('ln(e^(9))+log(100)'), 11);
      expect(eval('√(16)+∛(27)'), 7);
      expect(eval('√4+1'), 3);
      expect(eval('5!'), 120);
      expect(eval('asin(1)'), 90);
    });

    test('implicit multiplication and auto-closed parentheses', () {
      expect(eval('2π'), closeTo(6.283185307, 1e-9));
      expect(eval('3(1+2)'), 9);
      expect(eval('(1+1)(2+2)'), 8);
      expect(eval('2×(3+4'), 14);
    });

    test('errors', () {
      expect(() => eval('1÷0'), throwsA(isA<ExpressionError>()));
      expect(() => eval('√(-1)'), throwsA(isA<ExpressionError>()));
      expect(() => eval('2+'), throwsA(isA<ExpressionError>()));
      expect(() => eval('tan(90)'), throwsA(isA<ExpressionError>()));
    });

    test('scientific notation from previous results', () {
      expect(eval('1.5E-7×2'), closeTo(3e-7, 1e-20));
      expect(eval('1E+21+1'), 1e21);
    });
  });

  group('CalculatorInput', () {
    test('typing and operators', () {
      final i = CalculatorInput();
      for (final d in ['1', '2']) {
        i.digit(d);
      }
      i.operator('+');
      i.operator('×'); // replaces previous operator
      i.digit('3');
      expect(i.expression, '12×3');
      expect(i.tryEvaluate(AngleMode.degrees), 36);
    });

    test('decimal point and leading zero', () {
      final i = CalculatorInput()
        ..decimalPoint()
        ..digit('5')
        ..decimalPoint();
      expect(i.expression, '0.5');
      final j = CalculatorInput()
        ..digit('0')
        ..digit('7');
      expect(j.expression, '7');
    });

    test('smart parenthesis', () {
      final i = CalculatorInput()
        ..digit('2')
        ..parenthesis()
        ..digit('3')
        ..operator('+')
        ..digit('4')
        ..parenthesis();
      expect(i.expression, '2×(3+4)');
    });

    test('toggle sign', () {
      final i = CalculatorInput()
        ..digit('5')
        ..operator('+')
        ..digit('3')
        ..toggleSign();
      expect(i.expression, '5+(-3');
      expect(i.tryEvaluate(AngleMode.degrees), 2);
      i.toggleSign();
      expect(i.expression, '5+3');
    });

    test('backspace removes whole function names', () {
      final i = CalculatorInput()..function('sin');
      expect(i.expression, 'sin(');
      i.backspace();
      expect(i.expression, '');
    });

    test('digit after evaluation starts fresh, operator continues', () {
      final i = CalculatorInput()..load('42');
      i.digit('1');
      expect(i.expression, '1');
      i.load('42');
      i.operator('+');
      expect(i.expression, '42+');
    });

    test('rawNumber', () {
      expect(rawNumber(3), '3');
      expect(rawNumber(2.5), '2.5');
      expect(rawNumber(1.5e-7), '1.5E-7');
    });
  });

  group('Loan', () {
    test('equal installment (annuity)', () {
      final r = calculateLoan(principal: 100000, annualRatePercent: 12, months: 12, method: RepaymentMethod.equalInstallment);
      expect(r.firstPayment, closeTo(8884.88, 0.01));
      expect(r.schedule.last.balance, 0);
      expect(r.totalInterest, closeTo(6618.55, 0.05));
    });

    test('equal principal matches reference screenshot', () {
      final r = calculateLoan(principal: 1000000, annualRatePercent: 3.2, months: 240, method: RepaymentMethod.equalPrincipal);
      expect(r.schedule[0].payment, closeTo(6833.33, 0.01));
      expect(r.schedule[1].payment, closeTo(6822.22, 0.01));
      expect(r.totalInterest, closeTo(321333.33, 0.01));
    });

    test('zero interest', () {
      final r = calculateLoan(principal: 1200, annualRatePercent: 0, months: 12, method: RepaymentMethod.equalInstallment);
      expect(r.firstPayment, 100);
      expect(r.totalInterest, 0);
    });
  });

  group('Units', () {
    Unit u(UnitCategory c, String id) => units[c]!.firstWhere((x) => x.id == id);
    test('length and temperature', () {
      expect(convert(32.5, u(UnitCategory.length, 'centimeter'), u(UnitCategory.length, 'inch')), closeTo(12.79527559, 1e-6));
      expect(convert(100, u(UnitCategory.temperature, 'celsius'), u(UnitCategory.temperature, 'fahrenheit')), closeTo(212, 1e-9));
      expect(convert(0, u(UnitCategory.temperature, 'kelvin'), u(UnitCategory.temperature, 'celsius')), closeTo(-273.15, 1e-9));
      expect(convert(1, u(UnitCategory.data, 'gigabyte'), u(UnitCategory.data, 'megabyte')), 1024);
    });

    test('unit ids are unique', () {
      final ids = units.values.expand((l) => l).map((x) => x.id).toList();
      expect(ids.toSet().length, ids.length);
    });
  });

  group('Dates', () {
    test('difference', () {
      final d = dateDifference(DateTime(2024, 1, 31), DateTime(2024, 3, 1));
      expect([d.years, d.months, d.days, d.totalDays], [0, 1, 1, 30]);
      final e = dateDifference(DateTime(2026, 10, 7), DateTime(2020, 2, 29));
      expect([e.years, e.months, e.days], [6, 7, 8]);
    });

    test('add days across DST and leap years', () {
      expect(addDays(DateTime(2024, 2, 28), 1), DateTime(2024, 2, 29));
      expect(addDays(DateTime(2026, 3, 28), 2), DateTime(2026, 3, 30));
      expect(addDays(DateTime(2026, 1, 1), -1), DateTime(2025, 12, 31));
    });
  });

  group('LocaleNumbers', () {
    test('separators per locale with Western digits', () {
      expect(LocaleNumbers('en').format(1234567.5), '1,234,567.5');
      expect(LocaleNumbers('tr').format(1234567.5), '1.234.567,5');
      expect(LocaleNumbers('de').money(1321333.333), '1.321.333,33');
      expect(LocaleNumbers('hi').format(1234567), '12,34,567');
      expect(LocaleNumbers('bn').format(1234.5), isNot(contains('১')));
      expect(LocaleNumbers('ar').format(1234.5), isNot(contains('١')));
    });

    test('expression display', () {
      expect(LocaleNumbers('tr').displayExpression('1234.5×2-1'), '1.234,5×2−1');
      expect(LocaleNumbers('en').displayExpression('sin(30)+1000'), 'sin(30)+1,000');
    });

    test('scientific notation for extremes', () {
      expect(LocaleNumbers('en').format(1.5e20), '1.5E20');
      expect(LocaleNumbers('tr').format(2.5e-12), '2,5E-12');
    });

    test('parseUserNumber accepts both separators', () {
      expect(parseUserNumber('12,5'), 12.5);
      expect(parseUserNumber('12.5'), 12.5);
      expect(parseUserNumber('1.234,5'), 1234.5);
      expect(parseUserNumber('1,234.5'), 1234.5);
      expect(parseUserNumber(''), null);
      expect(parseUserNumber('abc'), null);
    });
  });
}
