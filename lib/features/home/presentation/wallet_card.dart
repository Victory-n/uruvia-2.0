import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/status_chip.dart';

/// Wallet balance card. DUMMY: the wallet is on hold, so this shows a sample
/// balance and says so. It switches to real data when the wallet is built.
class WalletCard extends StatefulWidget {
  const WalletCard({super.key});

  static const sampleBalanceKobo = 12540000; // ₦125,400.00

  @override
  State<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard> {
  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: palette.hero,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Wallet balance', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
              const SizedBox(width: AppSpacing.sm),
              const StatusChip('Preview', tone: StatusTone.warning),
              const Spacer(),
              IconButton(
                tooltip: _hidden ? 'Show balance' : 'Hide balance',
                color: Colors.white,
                icon: Icon(_hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                onPressed: () => setState(() => _hidden = !_hidden),
              ),
            ],
          ),
          AmountText(WalletCard.sampleBalanceKobo, size: AmountSize.xl, hidden: _hidden, color: Colors.white),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Sample figures until the wallet goes live.',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: palette.hero),
                  onPressed: () => context.go(AppRoutes.wallet),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Fund'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70, width: 1.5),
                  ),
                  onPressed: () => context.go(AppRoutes.wallet),
                  icon: const Icon(Icons.arrow_upward_rounded),
                  label: const Text('Send'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
