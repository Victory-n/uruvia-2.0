import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../application/wallet_controller.dart';
import 'wallet_widgets.dart';

/// Screen 15. DUMMY: sample balance and transactions.
class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final wallet = ref.watch(walletProvider);
    final recent = wallet.transactions.take(5).toList();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pageMargin),
          children: [
            const PreviewBanner(),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(color: palette.hero, borderRadius: BorderRadius.circular(AppRadius.card)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Wallet balance', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                      const Spacer(),
                      IconButton(
                        tooltip: _hidden ? 'Show balance' : 'Hide balance',
                        color: Colors.white,
                        icon: Icon(_hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        onPressed: () => setState(() => _hidden = !_hidden),
                      ),
                    ],
                  ),
                  AmountText(wallet.info.balanceKobo, size: AmountSize.xl, hidden: _hidden, color: Colors.white),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${wallet.info.bankName} · ${wallet.info.accountNumber}',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: palette.hero),
                          onPressed: () => context.push(AppRoutes.walletFund),
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
                          onPressed: () => context.push(AppRoutes.walletSend),
                          icon: const Icon(Icons.arrow_upward_rounded),
                          label: const Text('Send'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            Row(
              children: [
                Expanded(child: Text('Recent activity', style: theme.textTheme.titleMedium)),
                TextButton(
                  onPressed: () => context.push(AppRoutes.walletTransactions),
                  child: const Text('See all'),
                ),
              ],
            ),
            if (recent.isEmpty)
              const EmptyState(icon: Icons.receipt_long_outlined, title: 'No transactions yet')
            else
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    for (var i = 0; i < recent.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      WalletTxTile(
                        tx: recent[i],
                        onTap: () => context.push(AppRoutes.walletTransaction(recent[i].id)),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
