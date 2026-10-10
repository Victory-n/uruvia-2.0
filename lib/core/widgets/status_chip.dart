import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';
import '../../app/theme/tokens.dart';

/// Meaning of a status chip. Chips always carry text, never colour alone.
///
/// success: Paid, Completed. info: Partially paid. brand: Sent, Reserved.
/// warning: Due soon, Low stock, Pending. error: Overdue, Out of stock, Failed.
/// neutral: Draft, Cancelled.
enum StatusTone { success, info, brand, warning, error, neutral }

class StatusChip extends StatelessWidget {
  const StatusChip(this.label, {super.key, this.tone = StatusTone.neutral});

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;
    final (Color bg, Color fg) = switch (tone) {
      StatusTone.success => (AppColors.successBg, StatusColors.success),
      StatusTone.info => (AppColors.infoBg, AppColors.infoText),
      StatusTone.brand => (palette.tint, palette.action),
      StatusTone.warning => (AppColors.warningBg, StatusColors.warningText),
      StatusTone.error => (AppColors.errorBg, StatusColors.errorText),
      StatusTone.neutral => (AppColors.neutralBg, AppColors.neutralText),
    };
    return DecoratedBox(
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.chip)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: fg, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
