import 'dart:math' as math;

enum RepaymentMethod { equalInstallment, equalPrincipal }

class LoanPeriod {
  const LoanPeriod(this.number, this.payment, this.principal, this.interest, this.balance);
  final int number;
  final double payment;
  final double principal;
  final double interest;
  final double balance;
}

class LoanResult {
  const LoanResult(this.schedule);
  final List<LoanPeriod> schedule;

  double get totalPayment => schedule.fold(0, (s, p) => s + p.payment);
  double get totalInterest => schedule.fold(0, (s, p) => s + p.interest);
  double get firstPayment => schedule.isEmpty ? 0 : schedule.first.payment;
  double get lastPayment => schedule.isEmpty ? 0 : schedule.last.payment;
}

/// Builds a monthly amortization schedule.
/// [annualRatePercent] is the nominal yearly rate, e.g. 12 for 12%.
LoanResult calculateLoan({
  required double principal,
  required double annualRatePercent,
  required int months,
  required RepaymentMethod method,
}) {
  if (principal <= 0 || months <= 0 || annualRatePercent < 0) {
    return const LoanResult([]);
  }
  final r = annualRatePercent / 100 / 12;
  final schedule = <LoanPeriod>[];
  var balance = principal;

  if (method == RepaymentMethod.equalInstallment) {
    final payment = r == 0 ? principal / months : principal * r / (1 - math.pow(1 + r, -months));
    for (var i = 1; i <= months; i++) {
      final interest = balance * r;
      var principalPart = payment - interest;
      if (i == months) principalPart = balance; // absorb rounding
      balance -= principalPart;
      schedule.add(LoanPeriod(i, principalPart + interest, principalPart, interest, balance.abs() < 1e-6 ? 0 : balance));
    }
  } else {
    final principalPart = principal / months;
    for (var i = 1; i <= months; i++) {
      final interest = balance * r;
      balance -= principalPart;
      schedule.add(LoanPeriod(i, principalPart + interest, principalPart, interest, balance.abs() < 1e-6 ? 0 : balance));
    }
  }
  return LoanResult(schedule);
}
