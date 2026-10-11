import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/sub_page.dart';
import '../application/wallet_controller.dart';
import '../domain/wallet_models.dart';
import 'wallet_widgets.dart';

enum _Filter { all, moneyIn, moneyOut }

/// Screen 18 (list). DUMMY.
class WalletTransactionsScreen extends ConsumerStatefulWidget {
  const WalletTransactionsScreen({super.key});

  @override
  ConsumerState<WalletTransactionsScreen> createState() => _WalletTransactionsScreenState();
}

class _WalletTransactionsScreenState extends ConsumerState<WalletTransactionsScreen> {
  _Filter _filter = _Filter.all;

  static const _labels = {_Filter.all: 'All', _Filter.moneyIn: 'Money in', _Filter.moneyOut: 'Money out'};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final all = ref.watch(walletProvider).transactions;
    final txs = all.where((t) {
      return switch (_filter) {
        _Filter.all => true,
        _Filter.moneyIn => t.isCredit,
        _Filter.moneyOut => !t.isCredit,
      };
    }).toList();
    final groups = groupByDay(txs);

    return SubPage(
      title: 'Transactions',
      fallbackRoute: AppRoutes.wallet,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.pageMargin, AppSpacing.md, AppSpacing.pageMargin, 0),
            child: Row(
              children: [
                for (final f in _Filter.values) ...[
                  ChoiceChip(
                    label: Text(_labels[f]!),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
              ],
            ),
          ),
          Expanded(
            child: txs.isEmpty
                ? const EmptyState(icon: Icons.receipt_long_outlined, title: 'No transactions here')
                : ListView(
                    padding: const EdgeInsets.all(AppSpacing.pageMargin),
                    children: [
                      for (final entry in groups.entries) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.sm),
                          child: Text(formatDayHeader(entry.key),
                              style: theme.textTheme.labelLarge?.copyWith(color: AppColors.inkSoft)),
                        ),
                        AppCard(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          child: Column(
                            children: [
                              for (var i = 0; i < entry.value.length; i++) ...[
                                if (i > 0) const Divider(height: 1),
                                WalletTxTile(
                                  tx: entry.value[i],
                                  onTap: () => context.push(AppRoutes.walletTransaction(entry.value[i].id)),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Screen 18 (detail). DUMMY.
class WalletTransactionScreen extends ConsumerWidget {
  const WalletTransactionScreen({super.key, required this.txId});
  final String txId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tx = ref.watch(walletProvider).byId(txId);
    if (tx == null) {
      return const SubPage(
        title: 'Transaction',
        fallbackRoute: AppRoutes.walletTransactions,
        body: EmptyState(icon: Icons.search_off_rounded, title: 'Transaction not found'),
      );
    }
    final failed = tx.status == WalletTxStatus.failed;
    return SubPage(
      title: 'Transaction',
      fallbackRoute: AppRoutes.walletTransactions,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pageMargin),
        children: [
          const PreviewBanner(),
          const SizedBox(height: AppSpacing.xxl),
          Center(
            child: AmountText(
              failed ? tx.amountKobo : (tx.isCredit ? tx.amountKobo : -tx.amountKobo),
              size: AmountSize.xl,
              signed: tx.isCredit && !failed,
              color: failed ? AppColors.inkSoft : null,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(child: StatusChip(tx.status.label, tone: txTone(tx.status))),
          const SizedBox(height: AppSpacing.xxl),
          AppCard(
            child: Column(
              children: [
                DetailRow(label: 'Type', value: tx.kind.label),
                const Divider(height: 1),
                DetailRow(label: tx.isCredit ? 'From' : 'To', value: tx.counterparty),
                const Divider(height: 1),
                DetailRow(label: 'Fee', value: AmountText(tx.feeKobo).formatted),
                const Divider(height: 1),
                DetailRow(label: 'Date', value: '${formatShortDate(tx.createdAt)}, ${_time(tx.createdAt)}'),
                const Divider(height: 1),
                DetailRow(label: 'Reference', value: tx.reference, copyable: true),
                if (tx.narration != null) ...[
                  const Divider(height: 1),
                  DetailRow(label: 'Note', value: tx.narration!),
                ],
              ],
            ),
          ),
          if (tx.status == WalletTxStatus.processing) ...[
            const SizedBox(height: AppSpacing.lg),
            Text('This transfer is still on its way. It usually completes within a few minutes.',
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.inkSoft)),
          ],
        ],
      ),
    );
  }

  static String _time(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m ${d.hour < 12 ? 'AM' : 'PM'}';
  }
}
