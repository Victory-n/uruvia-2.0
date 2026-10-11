import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/amount_field.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/pin_prompt.dart';
import '../../../core/widgets/sub_page.dart';
import '../../account/application/account_actions.dart';
import '../application/wallet_controller.dart';
import '../domain/wallet_models.dart';
import 'wallet_widgets.dart';

/// Screen 17. DUMMY: sends to a bank account. Asks for the PIN, then records a sample transaction.
class WalletSendScreen extends ConsumerStatefulWidget {
  const WalletSendScreen({super.key});

  @override
  ConsumerState<WalletSendScreen> createState() => _WalletSendScreenState();
}

class _WalletSendScreenState extends ConsumerState<WalletSendScreen> {
  final _account = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  int? _kobo;
  String? _error;
  bool _busy = false;
  WalletTx? _done;

  @override
  void dispose() {
    _account.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  /// Sample name lookup. A real one asks the bank.
  String get _recipientName => _account.text.length == 10 ? 'Sample Recipient' : '';

  Future<void> _submit() async {
    final info = ref.read(walletProvider).info;
    final problem = validateSend(
      amountKobo: _kobo ?? 0,
      balanceKobo: info.balanceKobo,
      dailyLimitKobo: info.dailySendLimitKobo,
      accountNumber: _account.text.trim(),
    );
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    setState(() => _error = null);
    final confirmed = await showPinPrompt(
      context,
      title: 'Enter your PIN',
      message: 'Confirm this transfer.',
      verify: ref.read(accountActionsProvider).verifyPin,
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    final tx = ref.read(walletProvider.notifier).send(
          amountKobo: _kobo!,
          accountNumber: _account.text.trim(),
          name: _recipientName,
          narration: _note.text.trim().isEmpty ? null : _note.text.trim(),
        );
    if (mounted) setState(() {
      _busy = false;
      _done = tx;
    });
  }

  @override
  Widget build(BuildContext context) {
    final done = _done;
    if (done != null) return _SuccessView(tx: done);

    final theme = Theme.of(context);
    final info = ref.watch(walletProvider).info;
    final kobo = _kobo ?? 0;
    return SubPage(
      title: 'Send money',
      fallbackRoute: AppRoutes.wallet,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pageMargin),
        children: [
          const PreviewBanner(),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Text('Available: ', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft)),
              AmountText(info.balanceKobo),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Account number',
            controller: _account,
            keyboardType: TextInputType.number,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            helper: _recipientName.isEmpty ? 'The 10-digit number' : _recipientName,
            onChanged: (_) => setState(() => _error = null),
          ),
          const SizedBox(height: AppSpacing.lg),
          AmountField(
            controller: _amount,
            onChangedKobo: (v) => setState(() {
              _kobo = v;
              _error = null;
            }),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(label: 'Note (optional)', controller: _note, maxLength: 60),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              children: [
                DetailRow(label: 'Fee', value: formatFee()),
                const Divider(height: 1),
                DetailRow(label: 'Daily limit', value: _limitText(info.dailySendLimitKobo)),
                if (kobo > 0) ...[
                  const Divider(height: 1),
                  DetailRow(label: 'Total', value: _totalText(kobo)),
                ],
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(_error!, style: theme.textTheme.bodySmall?.copyWith(color: StatusColors.errorText)),
          ],
          const SizedBox(height: AppSpacing.xxl),
          AppButton(label: 'Continue', loading: _busy, onPressed: _busy ? null : _submit),
        ],
      ),
    );
  }

  String formatFee() => AmountText(sampleTransferFeeKobo).formatted;
  String _limitText(int kobo) => AmountText(kobo, showKobo: false).formatted;
  String _totalText(int kobo) => AmountText(kobo + sampleTransferFeeKobo).formatted;
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.tx});
  final WalletTx tx;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    return SubPage(
      title: 'Sent',
      fallbackRoute: AppRoutes.wallet,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.pageMargin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: palette.tint,
              child: Icon(Icons.check_rounded, size: 40, color: palette.action),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Transfer sent', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            AmountText(tx.amountKobo, size: AmountSize.l),
            const SizedBox(height: AppSpacing.xs),
            Text('to ${tx.counterparty}',
                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xxxl),
            AppButton(
              label: 'View receipt',
              style: AppButtonStyle.secondary,
              onPressed: () => context.pushReplacement(AppRoutes.walletTransaction(tx.id)),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(label: 'Done', onPressed: () => context.go(AppRoutes.wallet)),
          ],
        ),
      ),
    );
  }
}
