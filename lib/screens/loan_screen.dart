import 'package:flutter/material.dart';

import '../core/loan.dart';
import '../core/number_format.dart';
import '../widgets/app_drawer.dart';
import '../widgets/common.dart';

class LoanScreen extends StatefulWidget {
  const LoanScreen({super.key});

  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {
  final _amount = TextEditingController();
  final _rate = TextEditingController();
  final _months = TextEditingController();
  RepaymentMethod _method = RepaymentMethod.equalInstallment;

  @override
  void dispose() {
    _amount.dispose();
    _rate.dispose();
    _months.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final n = context.numbers;
    final scheme = Theme.of(context).colorScheme;
    void refresh(String _) => setState(() {});

    final amount = parseUserNumber(_amount.text);
    final rate = parseUserNumber(_rate.text);
    final months = int.tryParse(_months.text);
    final valid = amount != null && amount > 0 && rate != null && months != null && months > 0 && months <= 600;
    final result = valid
        ? calculateLoan(principal: amount, annualRatePercent: rate, months: months, method: _method)
        : null;

    final form = <Widget>[
      SegmentedButton<RepaymentMethod>(
        segments: [
          ButtonSegment(value: RepaymentMethod.equalInstallment, label: Text(l.equalInstallment)),
          ButtonSegment(value: RepaymentMethod.equalPrincipal, label: Text(l.equalPrincipal)),
        ],
        selected: {_method},
        showSelectedIcon: false,
        onSelectionChanged: (s) => setState(() => _method = s.first),
      ),
      NumberField(label: l.loanAmount, controller: _amount, onChanged: refresh),
      Row(children: [
        Expanded(child: NumberField(label: l.interestRate, controller: _rate, suffix: '%', onChanged: refresh)),
        const SizedBox(width: 12),
        Expanded(
          child: NumberField(label: l.termMonths, controller: _months, allowDecimal: false, onChanged: refresh),
        ),
      ]),
      if (result == null)
        const EmptyResults()
      else
        ResultCard(rows: [
          if (_method == RepaymentMethod.equalInstallment)
            (l.monthlyPayment, n.money(result.firstPayment))
          else ...[
            (l.firstPayment, n.money(result.firstPayment)),
            (l.lastPayment, n.money(result.lastPayment)),
          ],
          (l.totalPayment, n.money(result.totalPayment)),
          (l.totalInterest, n.money(result.totalInterest)),
        ]),
      if (result != null)
        Text(l.paymentSchedule,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
    ];

    TextStyle headerStyle = TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant, fontSize: 12);
    Widget cell(String s, {TextStyle? style, int flex = 4}) => Expanded(
          flex: flex,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 6),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerEnd,
              child: Text(s, style: style ?? const TextStyle(fontSize: 13), maxLines: 1),
            ),
          ),
        );

    return ToolScaffold(
      tool: Tool.loan,
      title: l.toolLoan,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverList.list(children: [
              for (final w in form) Padding(padding: const EdgeInsets.only(bottom: 14), child: w),
            ]),
          ),
          if (result != null) ...[
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(children: [
                    cell(l.colMonth, style: headerStyle, flex: 2),
                    cell(l.colPayment, style: headerStyle),
                    cell(l.colPrincipal, style: headerStyle),
                    cell(l.colInterest, style: headerStyle),
                    cell(l.colBalance, style: headerStyle, flex: 5),
                  ]),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList.builder(
                itemCount: result.schedule.length,
                itemBuilder: (context, i) {
                  final p = result.schedule[i];
                  return Container(
                    color: i.isEven ? scheme.surfaceContainerLow : scheme.surfaceContainer,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                    child: Row(children: [
                      cell(n.integer(p.number), flex: 2),
                      cell(n.money(p.payment)),
                      cell(n.money(p.principal)),
                      cell(n.money(p.interest)),
                      cell(n.money(p.balance), flex: 5),
                    ]),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
