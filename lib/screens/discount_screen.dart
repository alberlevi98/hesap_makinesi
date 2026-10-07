import 'package:flutter/material.dart';

import '../core/number_format.dart';
import '../widgets/app_drawer.dart';
import '../widgets/common.dart';

class DiscountScreen extends StatefulWidget {
  const DiscountScreen({super.key});

  @override
  State<DiscountScreen> createState() => _DiscountScreenState();
}

class _DiscountScreenState extends State<DiscountScreen> {
  final _price = TextEditingController();
  final _discount = TextEditingController();
  final _tax = TextEditingController();

  @override
  void dispose() {
    _price.dispose();
    _discount.dispose();
    _tax.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final n = context.numbers;
    final price = parseUserNumber(_price.text);
    final discount = parseUserNumber(_discount.text) ?? 0;
    final tax = parseUserNumber(_tax.text) ?? 0;
    void refresh(String _) => setState(() {});

    Widget results() {
      if (price == null) return const EmptyResults();
      final saved = price * discount / 100;
      final afterDiscount = price - saved;
      final taxAmount = afterDiscount * tax / 100;
      return ResultCard(rows: [
        (l.finalPrice, n.money(afterDiscount + taxAmount)),
        (l.youSave, n.money(saved)),
        if (tax != 0) (l.taxAmount, n.money(taxAmount)),
      ]);
    }

    return ToolScaffold(
      tool: Tool.discount,
      title: l.toolDiscount,
      body: FormList(children: [
        NumberField(label: l.originalPrice, controller: _price, onChanged: refresh),
        Row(children: [
          Expanded(child: NumberField(label: l.discountPercent, controller: _discount, suffix: '%', onChanged: refresh)),
          const SizedBox(width: 12),
          Expanded(child: NumberField(label: l.taxPercent, controller: _tax, suffix: '%', onChanged: refresh)),
        ]),
        Wrap(
          spacing: 8,
          children: [
            for (final p in const [10, 20, 25, 30, 50, 70])
              ActionChip(
                label: Text('$p%'),
                onPressed: () => setState(() => _discount.text = '$p'),
              ),
          ],
        ),
        results(),
      ]),
    );
  }
}
