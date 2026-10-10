import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/money.dart';
import '../../app/theme/tokens.dart';
import 'app_text_field.dart';

/// Allows digits and at most one dot with two decimals, e.g. 1500.25
final _amountFormatter = TextInputFormatter.withFunction((oldValue, newValue) {
  return RegExp(r'^\d*\.?\d{0,2}$').hasMatch(newValue.text) ? newValue : oldValue;
});

/// Amount input with the naira prefix and optional quick-amount chips.
/// Reports the value as integer kobo ([onChangedKobo] gets null while empty or incomplete).
class AmountField extends StatelessWidget {
  const AmountField({
    super.key,
    required this.controller,
    this.label = 'Amount',
    this.helper,
    this.errorText,
    this.onChangedKobo,
    this.quickAmountsKobo = const [],
    this.enabled = true,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String label;
  final String? helper;
  final String? errorText;
  final ValueChanged<int?>? onChangedKobo;
  final List<int> quickAmountsKobo;
  final bool enabled;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: label,
          controller: controller,
          helper: helper,
          errorText: errorText,
          enabled: enabled,
          autofocus: autofocus,
          prefixText: '₦ ',
          hint: '0.00',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [_amountFormatter],
          textStyle: theme.textTheme.titleLarge?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          onChanged: (text) => onChangedKobo?.call(parseNairaToKobo(text)),
        ),
        if (quickAmountsKobo.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final kobo in quickAmountsKobo)
                ActionChip(
                  label: Text(formatNaira(kobo, showKobo: false)),
                  onPressed: enabled
                      ? () {
                          controller.text = (kobo ~/ 100).toString();
                          controller.selection = TextSelection.collapsed(offset: controller.text.length);
                          onChangedKobo?.call(kobo);
                        }
                      : null,
                ),
            ],
          ),
        ],
      ],
    );
  }
}
