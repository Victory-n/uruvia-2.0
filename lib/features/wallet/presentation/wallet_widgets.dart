import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/status_chip.dart';
import '../domain/wallet_models.dart';

StatusTone txTone(WalletTxStatus s) => switch (s) {
      WalletTxStatus.completed => StatusTone.success,
      WalletTxStatus.processing => StatusTone.warning,
      WalletTxStatus.failed => StatusTone.error,
    };

IconData txIcon(WalletTx t) => switch (t.kind) {
      WalletTxKind.fund => Icons.south_west_rounded,
      WalletTxKind.receive => Icons.south_west_rounded,
      WalletTxKind.send => Icons.north_east_rounded,
      WalletTxKind.fee => Icons.receipt_long_outlined,
    };

/// One row in a transaction list.
class WalletTxTile extends StatelessWidget {
  const WalletTxTile({super.key, required this.tx, this.onTap});
  final WalletTx tx;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final failed = tx.status == WalletTxStatus.failed;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget + 16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: tx.isCredit ? palette.tint : AppColors.neutralBg,
                child: Icon(txIcon(tx), color: tx.isCredit ? palette.action : AppColors.neutralText, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx.kind.label, style: theme.textTheme.bodyLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(
                      '${tx.counterparty} · ${formatRelative(tx.createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.inkSoft),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AmountText(
                    failed ? tx.amountKobo : tx.signedKobo,
                    signed: !failed,
                    color: failed ? AppColors.inkSoft : (tx.isCredit ? StatusColors.success : AppColors.ink),
                  ),
                  if (tx.status != WalletTxStatus.completed) StatusChip(tx.status.label, tone: txTone(tx.status)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A label and value row with an optional copy button.
class DetailRow extends StatelessWidget {
  const DetailRow({super.key, required this.label, required this.value, this.copyable = false});
  final String label;
  final String value;
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft)),
          ),
          Expanded(
            flex: 3,
            child: Text(value, textAlign: TextAlign.end, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          ),
          if (copyable)
            IconButton(
              tooltip: 'Copy $label',
              icon: const Icon(Icons.copy_rounded, size: 18),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: value));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label copied.')));
                }
              },
            ),
        ],
      ),
    );
  }
}

/// Banner that says the wallet is a preview.
class PreviewBanner extends StatelessWidget {
  const PreviewBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(AppRadius.control)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, size: 18, color: StatusColors.warningText),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Preview: sample figures. No real money moves yet.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: StatusColors.warningText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
