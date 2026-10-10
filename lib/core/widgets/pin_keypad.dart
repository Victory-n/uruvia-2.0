import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';
import '../../app/theme/tokens.dart';

/// Row of dots showing how many PIN digits have been entered.
class PinDots extends StatelessWidget {
  const PinDots({super.key, required this.length, required this.filled, this.error = false});

  final int length;
  final int filled;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;
    final color = error ? StatusColors.error : palette.action;
    return Semantics(
      label: 'PIN, $filled of $length digits entered',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < length; i++)
              Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < filled ? color : Colors.transparent,
                  border: Border.all(color: i < filled ? color : AppColors.border, width: 1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Numeric keypad for PINs: 1 to 9, then fingerprint (optional), 0 and delete.
class PinKeypad extends StatelessWidget {
  const PinKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    this.onBiometric,
    this.enabled = true,
  });

  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback? onBiometric;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in const [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
          Row(children: [for (final d in row) Expanded(child: _digit(context, d))]),
        Row(
          children: [
            Expanded(
              child: onBiometric == null
                  ? const SizedBox(height: 72)
                  : _icon(context, Icons.fingerprint_rounded, 'Use fingerprint', onBiometric!),
            ),
            Expanded(child: _digit(context, 0)),
            Expanded(child: _icon(context, Icons.backspace_outlined, 'Delete', onBackspace)),
          ],
        ),
      ],
    );
  }

  Widget _digit(BuildContext context, int digit) {
    return SizedBox(
      height: 72,
      child: Semantics(
        button: true,
        label: '$digit',
        onTap: enabled ? () => onDigit(digit) : null,
        excludeSemantics: true,
        child: InkResponse(
          radius: 36,
          onTap: enabled ? () => onDigit(digit) : null,
          child: Center(
            child: Text('$digit', style: Theme.of(context).textTheme.headlineMedium),
          ),
        ),
      ),
    );
  }

  Widget _icon(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return SizedBox(
      height: 72,
      child: IconButton(
        tooltip: label,
        iconSize: 28,
        onPressed: enabled ? onTap : null,
        icon: Icon(icon),
      ),
    );
  }
}
