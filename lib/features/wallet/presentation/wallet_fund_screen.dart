import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/amount_field.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/sub_page.dart';
import '../application/wallet_controller.dart';
import 'wallet_widgets.dart';

/// Screen 16. Shows the wallet's account details. The "simulate" box is a
/// preview-only helper so the flow can be tried; it is removed when live.
class WalletFundScreen extends ConsumerStatefulWidget {
  const WalletFundScreen({super.key});

  @override
  ConsumerState<WalletFundScreen> createState() => _WalletFundScreenState();
}

class _WalletFundScreenState extends ConsumerState<WalletFundScreen> {
  final _amount = TextEditingController();
  int? _kobo;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _simulate() {
    final kobo = _kobo;
    if (kobo == null || kobo <= 0) return;
    ref.read(walletProvider.notifier).fund(kobo);
    _amount.clear();
    setState(() => _kobo = null);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sample transfer received.')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = ref.watch(walletProvider).info;
    return SubPage(
      title: 'Fund wallet',
      fallbackRoute: AppRoutes.wallet,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pageMargin),
        children: [
          const PreviewBanner(),
          const SizedBox(height: AppSpacing.lg),
          Text('Send money from any bank app to this account. It reaches your wallet within minutes.',
              style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              children: [
                DetailRow(label: 'Bank', value: info.bankName),
                const Divider(height: 1),
                DetailRow(label: 'Account number', value: info.accountNumber, copyable: true),
                const Divider(height: 1),
                DetailRow(label: 'Account name', value: info.accountName),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          Text('Try it (preview only)', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          AmountField(
            controller: _amount,
            helper: 'Pretend a transfer arrived.',
            quickAmountsKobo: const [500000, 1000000, 5000000],
            onChangedKobo: (v) => setState(() => _kobo = v),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Simulate transfer',
            style: AppButtonStyle.secondary,
            onPressed: (_kobo ?? 0) > 0 ? _simulate : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Limits and fees will show here once the wallet is live (${info.tierLabel}).',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}
