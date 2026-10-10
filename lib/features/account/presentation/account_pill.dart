import 'package:flutter/material.dart';

import '../../../app/theme/app_palette.dart';
import '../domain/account_type.dart';

/// Small "Individual" or "Business" pill. [onHero] is the translucent
/// white version used on the coloured header.
class AccountPill extends StatelessWidget {
  const AccountPill({super.key, required this.type, this.onHero = false});

  final AccountType type;
  final bool onHero;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;
    final label = type == AccountType.business ? 'Business' : 'Individual';
    final bg = onHero ? Colors.white.withValues(alpha: 0.2) : palette.tint;
    final fg = onHero ? Colors.white : palette.action;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}
