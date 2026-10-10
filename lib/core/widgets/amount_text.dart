
import 'package:flutter/material.dart';

import '../utils/money.dart';

enum AmountSize { xl, l, m }

/// Shows a naira amount from integer kobo in the Inter tabular style.
/// [hidden] masks it as "₦ ••••••" (the balance eye toggle).
/// [signed] adds + or − so colour is never the only signal for credits and debits.
class AmountText extends StatelessWidget {
  const AmountText(
    this.kobo, {
    super.key,
    this.size = AmountSize.m,
    this.hidden = false,
    this.showKobo = true,
    this.signed = false,
    this.color,
  });

  final int kobo;
  final AmountSize size;
  final bool hidden;
  final bool showKobo;
  final bool signed;
  final Color? color;

  static const maskedText = '₦ ••••••';

  String get formatted {
    if (hidden) return maskedText;
    final text = formatNaira(kobo, showKobo: showKobo);
    if (kobo < 0) return text.replaceFirst('-', '−');
    if (signed && kobo > 0) return '+$text';
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyMedium!;
    final style = (switch (size) {
      AmountSize.xl => base.copyWith(fontSize: 32, height: 40 / 32, fontWeight: FontWeight.w700),
      AmountSize.l => base.copyWith(fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w600),
      AmountSize.m => base.copyWith(fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w600),
    })
        .copyWith(fontFeatures: const [FontFeature.tabularFigures()], color: color);
    return Text(
      formatted,
      style: style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      semanticsLabel: hidden ? 'Amount hidden' : null,
    );
  }
}
